import 'dart:async';

/*
Decided to keep the unused imports, because in the auth screen there is an import flagged as unused
that Irina says is necessary (better be safe than sorry)
*/
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screens/newsfeed_screen.dart';

import '../widgets/android_ios_picker.dart';
import '../data/theme_data.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});
  static const routeName = '/verifyEmail';

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    if (!isEmailVerified) {
      _sendVerificationEmail();
      /*
      this will check every 3 seconds if the email has been verified
      And will stop checking after the verification occurred.
      */
      Timer.periodic(const Duration(seconds: 3), (_) {
        /*
        The linter says the return is not necessary because the function is of type void,
        But decided to keep it as it is because it is working 
         */
        return _checkEmailVerified();
      });
    }
  }

  // dispose of the timer once you are not using it anymore
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  /// check if the email address has been verified
  _checkEmailVerified() async {
    // call after email verification
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
    // dispose of the timer once the email has been verified
    if (isEmailVerified) {
      timer?.cancel();
    }
  }

  // send verification email
  Future _sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
      setState(() {
        canResendEmail = false;
      });
      // wait 5 seconds before letting the user send another verification email
      await Future.delayed(const Duration(seconds: 5));
      setState(() {
        canResendEmail = true;
      });
    } catch (e) {}
  }

  Widget _buildCupertinoVerifyEmailScreen(mediaQueryWidth) {
    return CupertinoPageScaffold(
      backgroundColor: constScaffoldBackground,
      navigationBar: const CupertinoNavigationBar(
          backgroundColor: constTopBarBackgroundColor,
          middle: Text(
            ConstStringVerifyEmailScreen.screenTitle,
            style: constTopBar,
          )),
      child: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 8.0,
          child: Container(
              padding: const EdgeInsets.all(16),
              constraints: BoxConstraints(
                  maxHeight: 300, maxWidth: mediaQueryWidth * 0.60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    ConstStringVerifyEmailScreen.screenBody,
                    textAlign: TextAlign.center,
                    style: constBodyLargeDark,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CupertinoButton.filled(
                    onPressed: () {
                      if (canResendEmail) {
                        _sendVerificationEmail();
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          constEmailCupertinoIcon,
                          color: constIconColorLight,
                          size: constButtonFontSize,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          ConstStringVerifyEmailScreen.resendEmailButton,
                          style: constCupertinoElevatedButtonLightText,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  CupertinoButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                    },
                    child: const Text(
                      ConstStringVerifyEmailScreen.cancelButton,
                      style: constCupertinoElevatedButtonDarkText,
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Widget _buildVerifyEmailScreen(mediaQueryWidth) {
    return Scaffold(
      backgroundColor: constScaffoldBackground,
      appBar: AppBar(
          centerTitle: constIsAppBarTitleNotCentered,
          backgroundColor: constTopBarBackgroundColor,
          title: const Text(
            ConstStringVerifyEmailScreen.screenTitle,
            textAlign: TextAlign.center,
            style: constTopBar,
          )),
      body: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 8.0,
          child: Container(
              padding: const EdgeInsets.all(16),
              constraints: BoxConstraints(
                  maxHeight: 300, maxWidth: mediaQueryWidth * 0.60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    ConstStringVerifyEmailScreen.screenTitle,
                    textAlign: TextAlign.center,
                    style: constBodyLargeDark,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: constElevatedButtonBackgroundDark),
                    icon: const Icon(
                      constEmailCupertinoIcon,
                      size: constButtonFontSize,
                      color: constIconColorLight,
                    ),
                    label: const Text(
                      ConstStringVerifyEmailScreen.resendEmailButton,
                      style: constMaterialElevatedButtonLightText,
                    ),
                    onPressed: () {
                      if (canResendEmail) {
                        _sendVerificationEmail();
                      }
                    },
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TextButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50)),
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                      },
                      child: const Text(
                        ConstStringVerifyEmailScreen.cancelButton,
                        style: constMaterialElevatedButtonDarkText,
                      ))
                ],
              )),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryWidth = MediaQuery.of(context).size.height;
    return isEmailVerified
        ? const NewsfeedScreen()
        : androidIosPicker(
            androidVersion: _buildVerifyEmailScreen(mediaQueryWidth),
            iosVersion: _buildCupertinoVerifyEmailScreen(mediaQueryWidth));
  }
}
