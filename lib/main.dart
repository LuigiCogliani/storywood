import 'dart:ui';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:upgrader/upgrader.dart';

import 'screens/new_tip_share_screen.dart';
import 'screens/new_tip_search_screen.dart';
import './screens/notification_screen.dart';
import './screens/newsfeed_screen.dart';
import './screens/auth_screen.dart';
import './screens/content_screen.dart';
import './screens/reset_password_screen.dart';
import './screens/verify_email_screen.dart';
import './screens/friends_screen.dart';
import './screens/user_profile_screen.dart';
import './screens/cast_screen.dart';
import './screens/tour_screen.dart';
import './screens/post_screen.dart';
import './screens/playlists_overview_screen.dart';
import './screens/single_playlist_screen.dart';
import './screens/new_tip_save_screen.dart';
import './screens/user_profile_genres_search_screen.dart';
import './screens/user_profile_top_recommendations_search_screen.dart';

import './widgets/android_ios_picker.dart';
import './data/theme_data.dart';
import './providers/navigation_bar_provider.dart';
import './providers/locale_provider.dart';
import './providers/users_provider_riverpod.dart';
import './widgets/newsfeed_screen/configure_notifications.dart';

///compare two software version (as strings)
// bool _isStoreMoreRecent({required String store, required String local}) {
//   // split the Strings into array of integers

//   final List<int> storeArray = [
//     for (var integerStore in store.split('.')) int.parse(integerStore)
//   ];
//   final List<int> localeArray = [
//     for (var integerLocale in local.split('.')) int.parse(integerLocale)
//   ];

//   // compare each of the three different digits
//   if (storeArray[0] > localeArray[0]) {
//     return true;
//   } else if (storeArray[0] == localeArray[0] &&
//       storeArray[1] > localeArray[1]) {
//     return true;
//     //had to add storeArray.length check as apple version was set to 1.0 on the store not 1.0.0
//   } else if (storeArray.length == 3 &&
//       storeArray[0] == localeArray[0] &&
//       storeArray[1] == localeArray[1] &&
//       storeArray[2] > localeArray[2]) {
//     return true;
//   }
//   return false;
// }

/// Check for Storywood app updates in both Google Play store
/// and Apple app store and force user to update before they can use the app
// void _checkVersion({required context}) async {
//   final newVersion = NewVersionPlus(
//     androidId: 'com.storywood.storywood_mvp01',
//     iOSId: 'com.example.storywoodMvp01',
//   );
//   final status = await newVersion.getVersionStatus();

//   if (_isStoreMoreRecent(
//       store: status!.storeVersion, local: status!.localVersion)) {
//     newVersion.showUpdateDialog(
//         context: context, versionStatus: status!, allowDismissal: false);
//   }
// }

//Handles notifications when app is not live
Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

//Set up a global key to be able to navigate to a specific screen from notification if received in background:
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Turning off landscape orientation for the app//
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  //Initialize Firebase app
  await Firebase.initializeApp(
    // name: 'archive-tips',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //Handle notifications when app is not live
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  //Check if tour pages have already been seen
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  /**
   * the first time a user opens the app the instance of share preference will be null,
   * so it will default to false (tour not seen yet).
   * If the user leaves the app before signing up the instance will keep the value to false.
   * Next time the user comes back the instance will load the value "false" and show the tour.
   * After the user logs in a first time the instance will be set to true, next time the user logs in
   * they will not see the tour.
   */
  final bool tourSeenStatus = prefs.getBool('tourSeen') ?? false;
  // this line of code enables crashlytics manual logging
  FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  runApp(ProviderScope(
    child: MyApp(
      tourSeenStatus: tourSeenStatus,
    ),
  ));
  /**
   * The next two lines of code are used to log the fatal errors using 
   * crashlytics (guide here:
   * https://www.youtube.com/watch?v=1wBpX0iFl5E)
   */
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  //check if user authenticated and update unseen notifications
  if (FirebaseAuth.instance.currentUser != null) {
    clearActiveNotifications(); //function defined in configure_notifications.dart
  }
}

// define routes (same for android and ios)
Map<String, Widget Function(BuildContext)> routes = {
  NewsfeedScreen.routeName: (context) => const NewsfeedScreen(),
  NotificationScreen.routeName: (context) => const NotificationScreen(),
  // TipScreen.routeName: (context) => const TipScreen(),
  NewTipShareScreen.routeName: (context) => const NewTipShareScreen(),
  AuthScreen.routeName: (context) => const AuthScreen(),
  ContentScreen.routeName: (context) => const ContentScreen(),
  ResetPasswordScreen.routeName: (context) => const ResetPasswordScreen(),
  VerifyEmailScreen.routeName: (context) => const VerifyEmailScreen(),
  FriendsScreen.routeNameYourFriendsTab: (context) =>
      const FriendsScreen(selectedPage: 0),
  FriendsScreen.routeNameRequestsTab: (context) =>
      const FriendsScreen(selectedPage: 1),
  UserProfileScreen.routeName: (context) => const UserProfileScreen(),
  NewTipSearchScreen.routeName: (context) => const NewTipSearchScreen(),
  // TipMenuScreen.routeName: (context) => const TipMenuScreen(),
  CastScreen.routeName: (context) => const CastScreen(),
  TourScreen.routeName: (context) => const TourScreen(),
  //PostScreen.routeName: (context) => PostScreen(),
  PlaylistsOverviewScreen.routeName: (context) =>
      const PlaylistsOverviewScreen(),
  SinglePlaylistScreen.routeName: (context) => const SinglePlaylistScreen(),
  NewTipSaveScreen.routeName: (context) => const NewTipSaveScreen(),
  PostScreen.routeName: (context) => const PostScreen(),
  UserProfileGenresSearchScreen.routeName: (context) =>
      const UserProfileGenresSearchScreen(),

  UserProfileTopRecommendationsSearchScreen.routeName: (context) =>
      const UserProfileTopRecommendationsSearchScreen(),
};

/**
 * We need ths widget to have a provider in order for it to rebuild each time the state changes.
 * This is because of the tour screen. The solution we used before would make the user go into the stream builder
 * and inside an if statement. If the tour was not seen the user would go to the tour screen, which would then
 * lead to the auth screen. After logging in this auth screen would keep loading indefinitely because such authscreen
 * was invoked outside of the streambuilder.
 * Having a provider means that we can trigger the rebuild of the 
 * _Home widget.
 */
/// this function will make sure that the tour runs only once also for old users
/// , i.e. the ones that are already logged in
void _updateTourStatus() async {
  // when the user logs in we can update the tour preferences
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('tourSeen', true);
}

class _Home extends ConsumerWidget {
  const _Home({
    required this.tourSeenStatus,
    required this.analytics,
    required this.analyticsObserver,
  });
  final bool tourSeenStatus;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver analyticsObserver;
  Future<void> analyticsSetUserId(String id) async {
    await analytics.setUserId(id: id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // check whether or not the user already watched the onboarding tutorial
    bool isSeen = tourSeenStatus ? tourSeenStatus : ref.watch(tourProvider);
    // assign the code of the country the users is signing in from
    ref.read(localeProvider.notifier).assignLocale();
    // checks if there is a newer version while the user uses the app
    //_checkVersion(context: context);

    /**
  * Luigi's note on signup error, null error:
  I think this is part of the issue. We check to see if we have a current user,
  but we don't have a fallback for when the check returns null 
  */
    // register userId with analytics if user authenticated
    if (FirebaseAuth.instance.currentUser != null) {
      analyticsSetUserId(FirebaseAuth.instance.currentUser!.uid);
    }
    return isSeen
        ? StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: ((context, snapshot) {
              _updateTourStatus();
              if (snapshot.hasData) {
                return FutureBuilder(
                    future: ref.read(userInfoProvider.notifier).loadUserInfo(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: androidIosPicker(
                              androidVersion: const CircularProgressIndicator(
                                color: constCircularProgressIndicatorWhite,
                              ),
                              iosVersion: const CupertinoActivityIndicator(
                                color: constCircularProgressIndicatorWhite,
                              )),
                        );
                      } else if (snapshot.connectionState ==
                          ConnectionState.done) {
                        if (snapshot.hasError) {
                          // Log the error using Firebase Crashlytics
                          FirebaseCrashlytics.instance
                              .recordError(snapshot.error, StackTrace.current);
                          // TODO this is where the app fails. We need to add a log
                          // https://medium.com/@parthbhanderi01/complete-guide-to-flutter-error-handling-techniques-and-code-examples-37414dd0992f
                          // https://www.youtube.com/watch?v=1wBpX0iFl5E
                          return const Center(
                              child: Text(
                                  ConstStringNewsfeedScreen
                                      .userInfoNotLoadedError,
                                  style: constBodySmallLight));
                        } else {
                          //TODO: figure out where to call friendsProvider properly, quick fix to have
                          //names available for collection sharing
                          final friends = ref.read(friendsFutureProvider);

                          return const VerifyEmailScreen();
                        }
                      } else {
                        return Center(
                          child: Text('State: ${snapshot.connectionState}',
                              style: constBodySmallLight),
                        );
                      }
                    });
              } else if (snapshot.hasError) {
                // Log the error using Firebase Crashlytics
                FirebaseCrashlytics.instance
                    .recordError(snapshot.error, StackTrace.current);
              }
              return const AuthScreen();
            }),
          )
        : const TourScreen();
  }
}

class MySpanishMessages extends UpgraderMessages {
  /// Override the message function to provide custom language localization.
  @override
  String message(UpgraderMessage messageKey) {
    if (languageCode == 'es') {
      switch (messageKey) {
        case UpgraderMessage.body:
          return 'es A new version of {{appName}} is available!';
        case UpgraderMessage.buttonTitleIgnore:
          return 'es Ignore';
        case UpgraderMessage.buttonTitleLater:
          return 'es Later';
        case UpgraderMessage.buttonTitleUpdate:
          return 'es Update Now';
        case UpgraderMessage.prompt:
          return 'es Want to update?';
        case UpgraderMessage.releaseNotes:
          return 'es Release Notes';
        case UpgraderMessage.title:
          return 'es Update App?';
      }
    }
    // Messages that are not provided above can still use the default values.
    return super.message(messageKey)!;
  }
}

/// code to use in android
Widget _buildMaterialApp(
  bool tourSeenStatus,
  FirebaseAnalytics analytics,
  FirebaseAnalyticsObserver analyticsObserver,
) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    title: constAppName,
    theme: ThemeData(
      primaryColor: Colors.black,
      hintColor: Colors.white12,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
          backgroundColor: constTopBarBackgroundColor,
          titleTextStyle: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          iconTheme: IconThemeData(color: constIconColorLight)),
    ),

    home: UpgradeAlert(
      dialogStyle: Platform.isIOS
          ? UpgradeDialogStyle.cupertino
          : UpgradeDialogStyle.material,
      canDismissDialog: false,
      showIgnore: false,
      showLater: false,
      showReleaseNotes: false,
      child: _Home(
          tourSeenStatus: tourSeenStatus,
          analytics: analytics,
          analyticsObserver: analyticsObserver),
    ),
    routes: routes,
    navigatorKey: navigatorKey,
    // required for the hero transitions to work with the routeNamed navigator
    navigatorObservers: [
      HeroController(),
      analyticsObserver,
    ],
  );
}

/// code to use in ios
Widget _buildCupertinoApp(
  bool tourSeenStatus,
  FirebaseAnalytics analytics,
  FirebaseAnalyticsObserver analyticsObserver,
) {
  return CupertinoApp(
    debugShowCheckedModeBanner: false,
    // this is required in ios to prevent "No MaterialLocalizations found."
    localizationsDelegates: const [
      DefaultMaterialLocalizations.delegate,
      DefaultCupertinoLocalizations.delegate,
      DefaultWidgetsLocalizations.delegate,
    ],
    title: constAppName,
    theme: const CupertinoThemeData(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.black,
        primaryContrastingColor: Colors.white12,
        barBackgroundColor: constTopBarBackgroundColor,
        textTheme: CupertinoTextThemeData(
          // color of the leading icon in navigation bar (among other things)
          primaryColor: Colors.white,
          navLargeTitleTextStyle: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        )),
    home: UpgradeAlert(
      showIgnore: false,
      showLater: false,
      child: _Home(
        tourSeenStatus: tourSeenStatus,
        analytics: analytics,
        analyticsObserver: analyticsObserver,
      ),
    ),
    routes: routes,
    navigatorKey: navigatorKey,
    // required for the hero transitions to work with the routeNamed navigator
    navigatorObservers: [HeroController(), analyticsObserver],
  );
}

//Widget was set up to be stateful to be able to add observer to detect
//the switch between foreground and background modes (at the moment used to
//update notifications count on the badge)

class MyApp extends StatefulWidget {
  MyApp({super.key, required this.tourSeenStatus});
  final bool tourSeenStatus;
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAnalyticsObserver analyticsObserver =
        FirebaseAnalyticsObserver(analytics: widget.analytics);
    // checks when accessing the app from a notification
    //_checkVersion(context: context);
    return OverlaySupport.global(
        child: androidIosPicker(
            androidVersion: _buildMaterialApp(
                widget.tourSeenStatus, widget.analytics, analyticsObserver),
            iosVersion: _buildCupertinoApp(
                widget.tourSeenStatus, widget.analytics, analyticsObserver)));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (AppLifecycleState.resumed == state) {
      clearActiveNotifications(); //function defined in configure_notifications.dart
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
