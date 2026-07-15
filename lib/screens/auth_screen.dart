import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api_constants.dart';
import '../widgets/auth_screen/auth_card.dart';
import '../widgets/android_ios_picker.dart';
import '../screens/reset_password_screen.dart';
import '../data/environment.dart';
import '../data/theme_data.dart';
import '../data/welcome_tips.dart';
import '../providers/users_provider_riverpod.dart';

void sendWelcomeTips({
  required String txTitle,
  required String comment,
  required List<String> sentTo,
  required String contentType,
  required String tipType,
  required String imageUrl,
  required String contentId,
  required Map<dynamic, dynamic> info,
}) async {
  String userId = constStorywoodDummyUserId;
  // initialise the timestampe in utc (as string)
  final dateCreated = DateTime.now().toUtc().toString();
  //keep only unique users
  List<String> sendToSelectedBuffer = sentTo.toSet().toList();
  /**
       * NOTE: this code snippet is also in tip_menu_screen, future builder, when we load a legacy tip
       * (i.e. a tip that has no votes in Firebase)
       */
  // inititliase the uservotes default values
  Map<String, bool> userVotesDefault = {'isCastVote': false, 'isPoop': false};
  // initialise the user votes
  Map<String, Map<String, bool>> userVotes = Map.fromIterable(
      sendToSelectedBuffer,
      key: (e) => e,
      value: (e) => userVotesDefault);
  // add the sender vote
  userVotes[userId!] = {
    'isCastVote': true,
    // if the tipType is a recommendation than isPoop must be false
    'isPoop': tipType == ConstNewTipScreen.tipTypeRecommendation ? false : true
  };
  /**
     * end code snippet. NOTE: we cannot just add it into a function because the next line of code requires
     * userVotes, defined here, but the second part of the replicated code requires the tipId, which is not
     * available until we send the tip to firebase
     */

  // send the tip to Firebase
  await FirebaseFirestore.instance.collection('${ENVIRONMENT}tips').add({
    'title': txTitle,
    'originalComment': comment,
    'imageUrl': imageUrl,
    'contentType': contentType,
    'tipType': tipType,
    'tipPrivacy': constTipPrivacyTaggedFriends,
    'sentBy': userId,
    'sentTo': sendToSelectedBuffer,
    'visibleTo': sendToSelectedBuffer,
    'timeStampCreated': dateCreated,
    'contentId': contentId,
    'timeStampLastUpdated': dateCreated,
    'info': info,
  }).then((docRef) {
    // Record original comment as first chat message in the chat collection on Firebase
    var _tipId = docRef.id.toString();
    FirebaseFirestore.instance
        .collection('${ENVIRONMENT}chats/$_tipId/messages')
        .add({
      'text': comment,
      'createdAt': DateTime.now().toUtc().toString(),
      'userId': userId,
    });
    /**
       * NOTE: this for loop is also in tip_menu_screen, future builder, when we load a legacy tip
       * (i.e. a tip that has no votes in Firebase)
       */
    // add the original tip type as vote on firebase
    for (var user in userVotes.keys) {
      // if the sender already sent the tip then overwrite the vote
      var votesToSet = userVotes[user]!;
      FirebaseFirestore.instance
          .collection('${ENVIRONMENT}userVotes/$contentType$contentId/$user')
          .doc(_tipId)
          .set(votesToSet);
    }

    // update the user preferences
    for (var userLoop in sentTo) {
      // by default the tip is not archived
      FirebaseFirestore.instance
          .collection('${ENVIRONMENT}userPreferences/$userLoop/archived')
          .doc(_tipId)
          .set({
        _tipId: false,
      });
      // by default the tip is not muted
      FirebaseFirestore.instance
          .collection('${ENVIRONMENT}userPreferences/$userLoop/muted')
          .doc(_tipId)
          .set({
        _tipId: false,
      });
    }
  }).catchError((error) {
    throw error;
  });
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  static const routeName = '/auth';

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

/**
 * signup crash signup error
 * We should be able to prevent a dispose of the states by adding
 * @override
  void dispose() {
    // TODO: implement dispose
    
  }
 */

  ///Function produces pop-up error box with a message
  void _showErrorDialog(
      {required String message,
      required String title,
      required String closeButton}) {
    showDialog(
      context: context,
      builder: (ctx) => Platform.isIOS
          ? CupertinoAlertDialog(
              title: Text(
                title,
                style: ConstCupertinoDialog.title,
              ),
              content: Text(
                message,
                style: ConstCupertinoDialog.message,
              ),
              actions: [
                CupertinoDialogAction(
                  child: Text(closeButton,
                      style: ConstCupertinoDialog.closeButton),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                )
              ],
            )
          : AlertDialog(
              title: Text(
                title,
                style: ConstMaterialDialog.title,
              ),
              content: Text(message, style: ConstMaterialDialog.message),
              actions: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(
                          constMaterialAlertDialogButton)),
                  child:
                      Text(closeButton, style: ConstMaterialDialog.closeButton),
                )
              ],
            ),
    );
  }

  /// check if the username is already in the collection of users
  Future<bool> _checkUserNameAvailability(String username) async {
    final result = await FirebaseFirestore.instance
        .collection('usernames')
        .where('__name__', isEqualTo: username.toLowerCase())
        .get();
    return result.docs.isEmpty;
  }

  ///Function that authenticates a user on Firebase (either sign-in or sign-up)
  void _submitAuthForm(
    String? email,
    String? password,
    String? usernameNotLowerCase,
    AuthMode? authMode,
    WidgetRef ref,
  ) async {
    UserCredential userCredentials;
    final String username = usernameNotLowerCase!.toLowerCase();
    //Trigger spinner in auth_card during sign-in/sign-up after credentials were submitted
    try {
      setState(() {
        _isLoading = true;
      });

      //Use Firebase defined functions to sign in or sign up
      if (authMode == AuthMode.Login) {
        userCredentials = await _auth
            .signInWithEmailAndPassword(email: email!, password: password!)
            .timeout(const Duration(seconds: timeout));
        //load data into userInfoProvider to have userId availabel throughout the app
        ref.read(userInfoProvider.notifier).loadUserInfo();
      } else {
        await _checkUserNameAvailability(username ?? '')
            .then((isUsernameAvailable) async {
          if (isUsernameAvailable) {
            userCredentials = await _auth
                .createUserWithEmailAndPassword(
                    email: email!, password: password!)
                .timeout(const Duration(seconds: timeout));

            //Create new record in Firestore for the new user during sign up
            await FirebaseFirestore.instance
                .collection('${ENVIRONMENT}users')
                .doc(userCredentials.user!.uid)
                .set({
              'username': username ?? email.substring(0, email.indexOf('@')),
              'email': email,
            });
            //Create new record of username in usernames collection
            await FirebaseFirestore.instance
                .collection('usernames')
                .doc(username)
                .set({});
// 03 Mar 2024 we commented out the send welcome tips because now we have the "Explore" tab
            // send the welcome tips
            // for (var tip in welcomeTips) {
            //   // this is because we have a different comment for ios and android, but only for tha rchive tip
            //   // which goes together with the book tip
            //   final String comment = tip['contentType'] != constContentTypeBook
            //       ? tip['comment']
            //       : Platform.isIOS
            //           ? tip['comment_ios']
            //           : tip['comment_android'];

            //   sendWelcomeTips(
            //       txTitle: tip['txTitle'],
            //       comment: comment,
            //       sentTo: [
            //         userCredentials.user!.uid,
            //         constStorywoodDummyUserId
            //       ],
            //       contentType: tip['contentType'],
            //       tipType: tip['tipType'],
            //       imageUrl: tip['imageUrl'],
            //       contentId: tip['contentId'],
            //       info: tip['info']);
            // }
            //load data into userInfoProvider to have userId available throughout the app
            ref.read(userInfoProvider.notifier).loadUserInfo();
            /**
             * we dinetified the signup error crash with this state. We decided to move it
             * at the end of the statement so even if it crashe it should 
             * record all the user info
             */
            // stop the loading spinner
            setState(() {
              _isLoading = false;
            });
          } else {
            _showErrorDialog(
                message: ConstStringAuthScreen.checkUsernameAlertMessage,
                title: ConstStringAuthScreen.alertDialogGenericTitle,
                closeButton:
                    ConstStringAuthScreen.alertDialogGenericCloseButton);
            setState(() {
              _isLoading = false;
            });
          }
        });
      }
    } on FirebaseAuthException catch (error) {
      _showErrorDialog(
          message: error.message != null
              ? error.message!
              : ConstStringAuthScreen.checkCredentialsAlertMessage,
          title: ConstStringAuthScreen.alertDialogGenericTitle,
          closeButton: ConstStringAuthScreen.alertDialogGenericCloseButton);
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      /**
       * signup crash signup error This is where the error happens:
       * setState() called after dispose()
       * Null check operator used on a null value.
       * At some point we uidentified the issue here and we added a catch statement so it would be added
       * to crashlytics.
       * This could be a simple case of adding a initState or similar at the beginning of AuthForm, or
       * adding an empty dispose method,
       * or initialise a new state inside this setState
       */
      setState(() {
        //_isLoading = false;
      });
    }
  }

  Widget _buildWelcomeMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 94),
      child: const AutoSizeText(
        ConstStringAuthScreen.welcomeMessage,
        maxLines: 2,
        style: constAuthScreenWelcomeToStorywood,
      ),
    );
  }

  Widget _buildPasswordResetWidget(mediaQueryHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: mediaQueryHeight * 0.03),
      child: GestureDetector(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: const Text(
            ConstStringAuthScreen.forgotPasswordButton,
            style: constTextButtonLightUnderline,
          ),
        ),
        onTap: () {
          Navigator.of(context).pushNamed(ResetPasswordScreen.routeName);
        },
      ),
    );
  }

  /// center widget (same for android and ios)
  Widget _buildAuthScreenCenter(mediaQueryHeight) {
    return Center(
      child: SingleChildScrollView(
        reverse: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _buildWelcomeMessage(),
            AuthCard(
                passDataToSubmitAuthScreenFunction: _submitAuthForm,
                isLoading: _isLoading),
            _buildPasswordResetWidget(mediaQueryHeight),
          ],
        ),
      ),
    );
  }

  /// android scaffold
  Widget _buildMaterialScaffold(mediaQueryHeight) {
    return Scaffold(
        backgroundColor: constScaffoldBackground,
        body: _buildAuthScreenCenter(mediaQueryHeight));
  }

  /// cupertino scaffold
  Widget _buildCupertinoScaffold(mediaQueryHeight) {
    return CupertinoPageScaffold(
        backgroundColor: constScaffoldBackground,
        child: _buildAuthScreenCenter(mediaQueryHeight));
  }

  @override
  Widget build(BuildContext context) {
    final double mediaQueryHeight = MediaQuery.of(context).size.width;
    return androidIosPicker(
        androidVersion: _buildMaterialScaffold(mediaQueryHeight),
        iosVersion: _buildCupertinoScaffold(mediaQueryHeight));
  }
}
