import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/users_provider_riverpod.dart';
import '../../data/environment.dart';
import '../../data/theme_data.dart';
import '../../screens/tour_screen.dart';
import '../../screens/new_tip_search_screen.dart';

import '../home_button.dart';
import '../material_wrapped.dart';

//temporary inputs, to be deleted once retrospective playlist function has been run
import '../../models/playlist_class.dart';

/// get the version of the app
Future<String> _getInfoPressed() async {
  WidgetsFlutterBinding.ensureInitialized();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  return packageInfo.version;
}

void showAboutStorywoodDialog(BuildContext context, screenHeight, screenWidth) {
  _getInfoPressed().then(
    (appVersion) {
      final String appVersionDelivered = appVersion;
      const String title = ConstStringNewsfeedScreen.aboutTitle;
      const String appVersionMessage =
          ConstStringNewsfeedScreen.appVersionMessage;
      const String content = ConstStringNewsfeedScreen.aboutMessage;

      final Image tmdbLogo = Image.asset(
        'assets/images/tmdb_logo.png',
        height: screenHeight * 0.12,
      );
      showDialog(
        context: context,
        builder: (context) => Platform.isIOS
            ? CupertinoAlertDialog(
                title: const Text(title),
                content: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$appVersionMessage $appVersionDelivered $content'),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                        child: tmdbLogo,
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: screenHeight * 0.03),
                        child: GestureDetector(
                          child: const Text(
                            ConstStringNewsfeedScreen.privacyPolicyHyperlink,
                            style: constHyperlink,
                          ),
                          onTap: () {
                            launchUrl(Uri.parse(constStorywoodLegalLink),
                                mode: LaunchMode.externalApplication);
                          },
                        ),
                      )
                    ]),
                actions: [
                  CupertinoDialogAction(
                    child: const Text(ConstStringAlertDialog.okayButton),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              )
            : AlertDialog(
                title: const Text(title),
                content: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$appVersionMessage $appVersionDelivered $content'),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                        child: tmdbLogo,
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: screenHeight * 0.03),
                        child: GestureDetector(
                          child: const Text(
                            ConstStringNewsfeedScreen.privacyPolicyHyperlink,
                            style: constHyperlink,
                          ),
                          onTap: () {
                            launchUrl(Uri.parse(constStorywoodLegalLink),
                                mode: LaunchMode.externalApplication);
                          },
                        ),
                      )
                    ]),
                actions: [
                  TextButton(
                    child: const Text(ConstStringAlertDialog.okayButton),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ),
      );
    },
  );
}

void showContactUsDialog(
    {required BuildContext context,
    required double screenHeight,
    required double screenWidth,
    required String title,
    required String content,
    bool hasLinkToExternalForm = false,
    String hyperlink = '',
    String hyperlinkText = ''}) {
  final List<Widget> body = [
    Text(content),
    hasLinkToExternalForm
        ? Padding(
            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.03),
            child: GestureDetector(
              child: Text(
                hyperlinkText,
                style: constHyperlink,
              ),
              onTap: () {
                launchUrl(Uri.parse(hyperlink),
                    mode: LaunchMode.externalApplication);
              },
            ),
          )
        : const SelectableText(constContactEmail)
  ];
  showDialog(
    context: context,
    builder: (context) => Platform.isIOS
        ? CupertinoAlertDialog(
            title: Text(title),
            content: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: body),
            actions: [
              CupertinoDialogAction(
                child: const Text(ConstStringAlertDialog.okayButton),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          )
        : AlertDialog(
            title: Text(title),
            content: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: body),
            actions: [
              TextButton(
                child: const Text(ConstStringAlertDialog.okayButton),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
  );
}

class DrawerStorywood extends ConsumerWidget {
  const DrawerStorywood({super.key});

  // //TODO: remove once run on Production conductRetrospectivePlaylistDatabaseAdjustments
  Future<void> conductRetrospectivePlaylistDatabaseAdjustments() async {
    String ENVIRONMENT_Function = 'production/production/';
    //pull all existing playlists
    // init empty list of playlist
    final List<Playlist> loadedPlaylists = [];

    var filteredPlaylists = await FirebaseFirestore.instance
        .collection('${ENVIRONMENT_Function}playlists')
        .get();

    // fill the local playlist list with the data from firebase
    for (var doc in filteredPlaylists.docs) {
      List<String> listOfUsersIdAsStrings = [];
      for (var sentToString in doc['listOfUsersId']) {
        listOfUsersIdAsStrings.add(sentToString);
      }
      List<String> visibleToAsStrings = [];
      if (doc.data().toString().contains('visibleToUserIds'))
        for (var visibleToString in doc['visibleToUserIds']) {
          visibleToAsStrings.add(visibleToString);
        }

      loadedPlaylists.add(Playlist(
        id: doc.id,
        name: doc['name'],
        createdBy: doc['createdBy'],
        listOfTipsId: doc['listOfTipsId'],
        listOfUsersId: doc['listOfUsersId'],
        imageUrl:
            doc.data().toString().contains('imageUrl') ? doc['imageUrl'] : null,
        imageTipId: doc.data().toString().contains('imageTipId')
            ? doc['imageTipId']
            : null,
        playlistPrivacy: doc.data().toString().contains('playlistPrivacy')
            ? doc['playlistPrivacy']
            //if legacy playlist choose privacy based on listOfUsersId length
            : listOfUsersIdAsStrings.length == 1
                ? constPlaylistPrivacyPrivate
                : constPlaylistPrivacyTaggedFriends,
        //check if visibleTo field available
        visibleToUserIds: doc.data().toString().contains('visibleToUserIds')
            ? visibleToAsStrings
            //if legacy tip fill in with sentTo
            : listOfUsersIdAsStrings,
        playlistStatus: doc.data().toString().contains('playlistStatus')
            ? doc['playlistStatus']
            //if legacy playlist choose privacy based on listOfUsersId length
            : listOfUsersIdAsStrings.isEmpty
                ? constPlaylistStatusDeleted
                : constPlaylistStatusActive,
        timeStampCreated: doc.data().toString().contains('timeStampCreated')
            ? doc['timeStampCreated']
            : DateTime.now().toUtc().toString(),
      ));
    }

    //run the updates for each playlist
    for (var playlist in loadedPlaylists) {
      //update Firebase playlist record to include new fields
      FirebaseFirestore.instance
          .doc('${ENVIRONMENT_Function}playlists/${playlist.id}')
          .set({
        'playlistStatus': playlist.playlistStatus,
        'timeStampCreated': playlist.timeStampCreated,
      }, SetOptions(merge: true));
    }
  }

//TODO: remove once Run function in production
  Widget _buildTemporaryPlaylistPopulateTile(
      context, mediaQueryHeight, mediaQueryWidth, iconScalingFactor) {
    return ListTile(
      title: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: mediaQueryWidth * 0.02),
            child: Icon(
              constDeletAccountCupertinoIcon,
              color: constIconColorLight,
              size: mediaQueryHeight * iconScalingFactor,
            ),
          ),
          const Text(
            ' DO not press',
            style: constBodyMediumWhite,
          )
        ],
      ),
      onTap: () {
        Navigator.of(context).pop();

        conductRetrospectivePlaylistDatabaseAdjustments();
      },
    );
  }

  Widget _buildDiscoverTile(
      context, mediaQueryHeight, mediaQueryWidth, iconScalingFactor, ref) {
    const bool isNewTipScreen = false;
    return ListTile(
      title: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: mediaQueryWidth * 0.02),
            child: Icon(
              constSearchCupertinoIcon,
              color: constIconColorLight,
              size: mediaQueryHeight * iconScalingFactor,
            ),
          ),
          const Text('Discover',
              //ConstStringNewsfeedScreen.drawerLogout,
              style: constBodyMediumWhite)
        ],
      ),
      onTap: () {
        resetProviders(ref);
        Navigator.of(context).pushNamed(NewTipSearchScreen.routeName,
            arguments: [isNewTipScreen]);
      },
    );
  }

  Widget _buildLogoutTile(
      context, screenHeight, screenWidth, iconScalingFactor, WidgetRef ref) {
    String userId = ref.read(userInfoProvider)?.userId ?? '';
    return ListTile(
      title: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
            child: Icon(
              constLogoutMaterialIcon,
              color: constIconColorLight,
              size: screenHeight * iconScalingFactor,
            ),
          ),
          const Text(ConstStringNewsfeedScreen.drawerLogout,
              style: constBodyMediumWhite)
        ],
      ),
      onTap: () {
        FirebaseFirestore.instance
            .collection('${ENVIRONMENT}users')
            .doc(userId)
            .set({
          'token': '',
        }, SetOptions(merge: true));
        FirebaseAuth.instance.signOut();
        //clean up userInfoProvider and friend providers
        ref.invalidate(userInfoProvider);
        ref.invalidate(friendsFutureProvider);
        ref.invalidate(friendRequestsFutureProvider);

        Navigator.of(context).pushReplacementNamed(
            '/'); //Logout would stop working without this line from time to time without obvious reason
      },
    );
  }

  Widget _buildAboutTile(
      context, screenHeight, screenWidth, iconScalingFactor) {
    return ListTile(
      title: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
            child: Icon(
              constAboutCupertinoIcon,
              color: constIconColorLight,
              size: screenHeight * iconScalingFactor,
            ),
          ),
          const Text(
            ConstStringNewsfeedScreen.aboutTitle,
            style: constBodyMediumWhite,
          )
        ],
      ),
      onTap: () {
        Navigator.of(context).pop();

        showAboutStorywoodDialog(context, screenHeight, screenWidth);
      },
    );
  }

  Widget _buildContactUsTile(
      context, screenHeight, screenWidth, iconScalingFactor) {
    return ListTile(
      title: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
            child: Icon(
              constContactUsCupertinoIcon,
              color: constIconColorLight,
              size: screenHeight * iconScalingFactor,
            ),
          ),
          const Text(
            ConstStringNewsfeedScreen.contactUsTitle,
            style: constBodyMediumWhite,
          )
        ],
      ),
      onTap: () {
        Navigator.of(context).pop();

        showContactUsDialog(
            context: context,
            screenHeight: screenHeight,
            screenWidth: screenHeight,
            content: ConstStringNewsfeedScreen.contactUsMessage,
            title: ConstStringNewsfeedScreen.contactUsTitle);
      },
    );
  }

  Widget _buildReportTile(
      context, screenHeight, screenWidth, iconScalingFactor) {
    return ListTile(
      title: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
            child: Icon(
              constReportCupertinoIcon,
              color: constIconColorLight,
              size: screenHeight * iconScalingFactor,
            ),
          ),
          const Text(
            ConstStringNewsfeedScreen.reportTitle,
            style: constBodyMediumWhite,
          )
        ],
      ),
      onTap: () {
        Navigator.of(context).pop();

        showContactUsDialog(
            context: context,
            screenHeight: screenHeight,
            screenWidth: screenHeight,
            content: ConstStringNewsfeedScreen.reportMessage,
            title: ConstStringNewsfeedScreen.reportTitle,
            hasLinkToExternalForm: true,
            hyperlink: constStorywoodReportIssueFormLink,
            hyperlinkText: ConstStringNewsfeedScreen.reportTitle);
      },
    );
  }

  Widget _buildDeleteAccountTile(
      context, screenHeight, screenWidth, iconScalingFactor) {
    return ListTile(
      title: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
            child: Icon(
              constDeletAccountCupertinoIcon,
              color: constIconColorLight,
              size: screenHeight * iconScalingFactor,
            ),
          ),
          const Text(
            ConstStringNewsfeedScreen.deleteAccountTitle,
            style: constBodyMediumWhite,
          )
        ],
      ),
      onTap: () {
        Navigator.of(context).pop();

        showContactUsDialog(
            context: context,
            screenHeight: screenHeight,
            screenWidth: screenHeight,
            content: ConstStringNewsfeedScreen.deleteAccountMessage,
            title: ConstStringNewsfeedScreen.deleteAccountTitle,
            hasLinkToExternalForm: true,
            hyperlink: constStorywoodDeleteAccountFormLink,
            hyperlinkText:
                ConstStringNewsfeedScreen.deleteAccountHyperlinkText);
      },
    );
  }

  Widget _buildTourTile(context, screenHeight, screenWidth, iconScalingFactor) {
    return ListTile(
      title: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
            child: Icon(
              constTourCupertinoIcon,
              color: constIconColorLight,
              size: screenHeight * iconScalingFactor,
            ),
          ),
          const Text(
            ConstStringNewsfeedScreen.tourTitle,
            style: constBodyMediumWhite,
          )
        ],
      ),
      onTap: () {
        Navigator.of(context).pushNamed(TourScreen.routeName);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String username = ref.read(userInfoProvider)?.userName ??
        ConstStringNewsfeedScreen.drawerNotFound;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    const double iconScalingFactor = 0.03;
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: Container(
        color: constScaffoldBackground,
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: screenHeight * 0.15,
              child: DrawerHeader(
                decoration: const BoxDecoration(
                  color: constHintColor,
                ),
                child: Text(
                  'Hi, $username',
                  style: constBodyLargeLight,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            _buildDiscoverTile(
                context, screenHeight, screenWidth, iconScalingFactor, ref),
            //tour tiles
            _buildTourTile(
                context, screenHeight, screenWidth, iconScalingFactor),
            // about section
            _buildAboutTile(
                context, screenHeight, screenWidth, iconScalingFactor),
            // contatc us section
            _buildContactUsTile(
                context, screenHeight, screenWidth, iconScalingFactor),
            // report section
            _buildReportTile(
                context, screenHeight, screenWidth, iconScalingFactor),
            // delete account section
            _buildDeleteAccountTile(
                context, screenHeight, screenWidth, iconScalingFactor),
            // logout section
            _buildLogoutTile(
                context, screenHeight, screenWidth, iconScalingFactor, ref),

            // _buildTemporaryPlaylistPopulateTile(
            //     context, screenHeight, screenWidth, iconScalingFactor),
          ],
        ),
      ),
    );
  }
}
