import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:overlay_support/overlay_support.dart';

import '../../data/environment.dart';
import '../../data/theme_data.dart';
import '../../providers/navigation_bar_provider.dart';
import '../../providers/users_provider_riverpod.dart';
import '../../main.dart';
import '../../screens/post_screen.dart';
import '../../screens/friends_screen.dart';
import '../../screens/single_playlist_screen.dart';

import '../material_wrapped.dart';

///Support function to update number of unseen notifications (also referenced in main.dart)
void clearActiveNotifications() async {
  //clear the app badge
  FlutterAppBadger.removeBadge();
  //clear firebase record
  await FirebaseFirestore.instance
      .collection('${ENVIRONMENT}users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .set({
    'active_notifications': 0,
  }, SetOptions(merge: true));
}

///Configures FirebaseMessageing service to allow notifications (ios) and notifications behaviour
Future<void> configureFirebaseNotifications(WidgetRef ref) async {
  var messaging = FirebaseMessaging.instance;
  String? notificationTitle, notificationBody;

  //Register device token in the users database (to be used to receive notifications by this user)
  messaging.getToken().then((value) {
    FirebaseFirestore.instance
        .collection('${ENVIRONMENT}users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .set({
      'token': value,
    }, SetOptions(merge: true));
  });

  // Settings to allow badge, alerts, sounds
  messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  //Request notifications to be allowed in iOS
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  ///Support function that defines screen for redirection on tap depending on notification type
  void selectOnTapRedirectScreen(
      String notificationType, String tipIdNotification) {
    if (notificationType == constNotifTypeNewFriendRequestReceived) {
      ref.invalidate(friendRequestsFutureProvider);
      ref
          .read(bottomNavigationBarIndexProvider.notifier)
          .updatebottomNavigationBarIndexNotifier(
              constFriendsScreenBottomNavigationBarIndex);
      Navigator.of(navigatorKey.currentState!.context)
          .pushNamed(FriendsScreen.routeNameRequestsTab);
    } else if (notificationType == constNotifTypeNewFriendRequestApproved) {
      ref.invalidate(friendsFutureProvider);
      ref
          .read(bottomNavigationBarIndexProvider.notifier)
          .updatebottomNavigationBarIndexNotifier(
              constFriendsScreenBottomNavigationBarIndex);
      Navigator.of(navigatorKey.currentState!.context)
          .pushNamed(FriendsScreen.routeNameYourFriendsTab);
    } else if (notificationType == constNotifTypeCollectionShared) {
      Navigator.of(navigatorKey.currentState!.context).pushNamed(
        SinglePlaylistScreen.routeName,
        arguments: [tipIdNotification, null, true],
      );
    } else {
      Navigator.of(navigatorKey.currentState!.context).pushNamed(
        PostScreen.routeName,
        arguments: [tipIdNotification, null],
      );
    }
  }

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    //Configure notifications behaviour when app is active (foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      String tipIdNotification = message.data['tipId'].toString();
      String notificationType = message.data['notificationType'].toString();

      if (message.notification != null) {
        notificationTitle = message.notification!.title;
        notificationBody = message.notification!.body;

        //Configure overlay widget to shown notification
        OverlaySupportEntry showNotificationForeground() {
          return showSimpleNotification(
            MaterialWrapped(
              child: InkWell(
                  onTap: () {
                    selectOnTapRedirectScreen(
                        notificationType, tipIdNotification);
                  },
                  child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$notificationTitle',
                            style: constNotificationBodyLightBold,
                          ),
                          Text(
                            '$notificationBody',
                            style: constNotificationBodyLight,
                          ),
                        ],
                      ))),
            ),
            background: constSimpleNotificationBackground,
            duration: const Duration(seconds: 4),
            foreground: constSimpleNotificationForeground,
          );
        }

        //Show notification after refreshing relevant data
        if (notificationType == constNotifTypeNewTip) {
          if (Platform.isAndroid) {
            showNotificationForeground();
          }
        } else if (notificationType == constNotifTypeNewFriendRequestReceived) {
          ref.invalidate(friendRequestsFutureProvider);
          if (Platform.isAndroid) {
            showNotificationForeground();
          }
        } else if (notificationType == constNotifTypeNewFriendRequestApproved) {
          ref.invalidate(friendsFutureProvider);
          if (Platform.isAndroid) {
            showNotificationForeground();
          }
        } else {
          if (Platform.isAndroid) {
            showNotificationForeground();
          }
        }
      }
      clearActiveNotifications();
    });

    //Configure notifications behaviour when app is in the background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      clearActiveNotifications();

      if (message.notification != null) {
        String tipIdNotification = message.data['tipId'].toString();
        String notificationType = message.data['notificationType'].toString();
        notificationTitle = message.notification!.title;
        notificationBody = message.notification!.body;

        if (navigatorKey.currentState != null) {
          selectOnTapRedirectScreen(notificationType, tipIdNotification);
        }
      }
    });

    //Configure notifications behaviour when app was terminated
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      notificationTitle = initialMessage.notification!.title;
      notificationBody = initialMessage.notification!.body;

      clearActiveNotifications();

      String tipIdNotification = initialMessage.data['tipId'].toString();
      String notificationType =
          initialMessage.data['notificationType'].toString();
      if (navigatorKey.currentState != null) {
        selectOnTapRedirectScreen(notificationType, tipIdNotification);
      }
    }
  } else {
    /*This block is a placeholder for when user declined or has not 
      *accepted permission for notifications
      */
  }
}
