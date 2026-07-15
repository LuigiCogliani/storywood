import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:get/utils.dart';

import '../data/environment.dart';

import '../providers/users_provider_riverpod.dart';
import '../providers/in_app_tour_storage.dart';
import '../data/theme_data.dart';

import '../models/user_class.dart' as storywood;
import '../models/tip_class.dart';

import '../widgets/newsfeed_screen/newsfeed_appbar.dart';
import '../widgets/newsfeed_screen/drawer.dart';
import '../widgets/newsfeed_screen/configure_notifications.dart';
import '../widgets/newsfeed_screen/post_item.dart';
import '../widgets/android_ios_picker.dart';
import '../widgets/adaptive_circular_loading.dart';
import '../widgets/adaptive_alert_dialog_single_button.dart';
import '../widgets/bottom_navigation_bar.dart';

import '../widgets/newsfeed_screen/in_app_tour_newsfeed.dart';

//TODO: Luigi to review

class NewsfeedScreen extends ConsumerStatefulWidget {
  const NewsfeedScreen({super.key});
  static const routeName = '/newsfeed-screen';

  @override
  ConsumerState<NewsfeedScreen> createState() => _NewsfeedScreenState();
}

class _NewsfeedScreenState extends ConsumerState<NewsfeedScreen> {
  // allows us to navigate between tabs
  static const routeNameNewsfeedFriendsTab = '/newsfeed-screen-friends-tab';
  static const routeNameNewsfeedPublicTab = '/newsfeed-screen-public-tab';

  //variables set up for in-app tour
  final feedTabKey = GlobalKey();
  late TutorialCoachMark tutorialCoachMark;

  ///Function to call new tip share screen in-app tutorial
  void initInAppNewsfeedScreenTour() {
    tutorialCoachMark = TutorialCoachMark(
      targets: newsfeedScreenTargets(
        feedTabKey: feedTabKey,
      ),
      colorShadow: Colors.black,
      paddingFocus: 10,
      hideSkip: true,
      opacityShadow: 0.9,
      onFinish: () {
        //save the flag that tutorial has been seen
        SaveInAppTour().saveNewsfeedScreenTourStatus();
        //print('Completed');
      },
    );
  }

  void showInAppNewsfeedScreenTour() {
    Future.delayed(const Duration(seconds: 1), () {
      SaveInAppTour().getNewsfeedScreenTourStatus().then((value) {
        //only show tutorial if it has not been seen yet on this phone
        if (value == false) {
          tutorialCoachMark.show(context: context);
        }
      });
    });
  }

  //Initialise function to configure push notifications display (function defined in a separate file configure_notifications.dart)
  @override
  void initState() {
    super.initState();
//initialise tutorial function
    initInAppNewsfeedScreenTour();

    //show in-app tutorial
    showInAppNewsfeedScreenTour();
    configureFirebaseNotifications(ref);
    //_checkVersion();
  }

  //Configure future variable that is used for FutureBuilder below
  var _isInit = true;
  late Future<void> fetchUsernamesFuture;
  late Future<storywood.User?> loadUserInfoFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      fetchUsernamesFuture =
          ref.read(usernameProvider.notifier).fetchAllUsernameFromFirebase();
      //  loadUserInfoFuture = ref.read(userInfoProvider.notifier).loadUserInfo();
    }
    _isInit = false;
  }

  /// we need have a podcastUrl, even if only an empty string
  String generatePodcastUrl({required Tip currentTip}) {
    try {
      return currentTip.contentType == constContentTypePodcast
          ? currentTip.info!['feedUrl']
          : '';
    } catch (error) {
      return '';
    }
  }

  Widget feed(
      {required MediaQueryData mediaQuery,
      required Query<Tip> query,
      required bool isPublicFeed,
      required String myUserId,
      required List<String>? friendUserIds}) {
    return SizedBox(
        height: (mediaQuery.size.height - mediaQuery.padding.top) * 0.88,
        child: FutureBuilder(
            future: fetchUsernamesFuture,
            builder: (context, fetchUsernamesFutureSnapshot) {
              if (fetchUsernamesFutureSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return Center(
                  child: androidIosPicker(
                      androidVersion: const CircularProgressIndicator(
                        color: constCircularProgressIndicatorWhite,
                      ),
                      iosVersion: const CupertinoActivityIndicator(
                        color: constCircularProgressIndicatorWhite,
                      )),
                );
              } else if (fetchUsernamesFutureSnapshot.connectionState ==
                  ConnectionState.done) {
                if (fetchUsernamesFutureSnapshot.hasError) {
                  return const Center(
                      child: Text(
                          ConstStringNewsfeedScreen
                              .futureBuilderNotLoadingMessage,
                          style: constBodySmallLight));
                } else {
                  return Material(
                      child: Container(
                          color: constScaffoldBackground,
                          child: FirestoreListView(
                              loadingBuilder: (context) {
                                return adaptiveCircularLoading(
                                    color: constCircularProgressIndicatorWhite);
                              },
                              errorBuilder: (context, error, stackTrace) {
                                //print(error);
                                return const AdaptiveAlertDialogSingleButton(
                                    title: ConstStringNewsfeedScreen
                                        .futureBuilderNotLoadingTitle,
                                    message: ConstStringNewsfeedScreen
                                        .futureBuilderNotLoadingMessage,
                                    actionMessage:
                                        ConstStringAlertDialog.okayButton);
                              },
                              emptyBuilder: (context) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(50, 25, 50, 0),
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Text(
                                      ConstStringNewsfeedScreen.zeroFriends,
                                      style: constPlaylistGridTextLight(
                                          mediaQuery.size.height),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              },
                              query: query,
                              pageSize: 3,
                              itemBuilder: (context, queryBuildersnapshot) {
                                Tip currentTip = queryBuildersnapshot.data();
                                // if we are loading a podcast we need to add the feedurl to the info
                                if (currentTip.contentType ==
                                    constContentTypePodcast) {
                                  final String podcastUrl = generatePodcastUrl(
                                      currentTip: currentTip);
                                  final info = {'feedUrl': podcastUrl};
                                  // add the info
                                  currentTip.setInfo = info;
                                }
                                //add the tipId
                                currentTip.setTipId = queryBuildersnapshot.id;

                                // check if the tip is a self tip (we don't want to see them in the newsfeed)
                                final bool isSelfTip = currentTip.tipPrivacy ==
                                    constTipPrivacySelfTip;

                                //check if the tip is from yourself or from friends for public feed:
                                bool filterFromPublic =
                                    false; //variable remains false for friends feed
                                if (isPublicFeed) {
                                  if (currentTip.sentBy == myUserId ||
                                      (friendUserIds != null &&
                                          friendUserIds
                                              .contains(currentTip.sentBy))) {
                                    filterFromPublic = true;
                                  }
                                }

                                return isSelfTip ||
                                        filterFromPublic //filterFromPublic always set to false for friends feed
                                    /** We want to show only tips shared with other people, but the item builder
                                                     * needs to return a value even when the current tip is a self tip.
                                                     * The simplest widget is a sized box with height 1
                                                     */
                                    ? const SizedBox(
                                        height: 1,
                                      )
                                    : Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical:
                                                mediaQuery.size.height * 0.01),
                                        child: PostItem(
                                          tip: currentTip,
                                          callFromNewsfeed: true,
                                        ),
                                      );
                              })));
                }
              } else {
                return Center(
                  child: Text(
                      'State: ${fetchUsernamesFutureSnapshot.connectionState}',
                      style: constBodySmallLight),
                );
              }
            }));
  }

  @override
  Widget build(BuildContext context) {
    // load current user ID
    String? userId = ref.read(userInfoProvider)?.userId;
    List<String>? friendUserIds = ref.read(userInfoProvider)?.friendsUserIds;
    bool zeroFriends = ref.read(userInfoProvider)?.friendsUserIds == null
        ? true
        : ref.read(userInfoProvider)!.friendsUserIds!.isEmpty
            ? true
            : false;
    final mediaQuery = MediaQuery.of(context);
    final friendsQuery = FirebaseFirestore.instance
        .collection('${ENVIRONMENT}tips')
        .where(Filter.or(
            Filter('visibleTo', arrayContains: userId),
            //the second part only needed to be backwards compliant, maybe we can remove it once everyone has version older than 2.3.1 and we add visibleTo for every old tip
            Filter('sentTo', arrayContains: userId)))
        .orderBy('timeStampLastUpdated', descending: true)
        .withConverter<Tip>(
          fromFirestore: (snapshot, _) => Tip.fromJson(snapshot.data()!),
          toFirestore: (tip, _) => tip.toJson(),
        );

    final publicQuery = FirebaseFirestore.instance
        .collection('${ENVIRONMENT}tips')
        //TODO: shall we filter out self-tips at this stage instead?
        .where(Filter('tipPrivacy', isEqualTo: 'Public'))
        .orderBy('timeStampLastUpdated', descending: true)
        .withConverter<Tip>(
          fromFirestore: (snapshot, _) => Tip.fromJson(snapshot.data()!),
          toFirestore: (tip, _) => tip.toJson(),
        );
    int initialIndex({required bool zeroFriends}) {
      if (zeroFriends) {
        return 1;
      } else {
        return 0;
      }
    }

    Widget zeroFriendsFunnyMessage({required double mediaQueryHeight}) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(50, 25, 50, 0),
        child: Align(
          alignment: Alignment.topCenter,
          child: Text(
            ConstStringNewsfeedScreen.zeroFriends,
            style: constPlaylistGridTextLight(mediaQueryHeight),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      initialIndex: initialIndex(zeroFriends: zeroFriends),
      child: Scaffold(
          bottomNavigationBar: const StorywoodBottomNavigationBar(),
          backgroundColor: constScaffoldBackground,
          appBar: buildNewsfeedAppBar(feedTabKey, mediaQuery, context, ref),
          drawer: const DrawerStorywood(),
          body: TabBarView(
            children: [
              // zeroFriends
              //     ? zeroFriendsFunnyMessage(
              //         mediaQueryHeight: mediaQuery.size.height)
              //     :
              feed(
                  mediaQuery: mediaQuery,
                  query: friendsQuery,
                  isPublicFeed: false,
                  myUserId: userId!,
                  friendUserIds: friendUserIds),
              feed(
                  mediaQuery: mediaQuery,
                  query: publicQuery,
                  isPublicFeed: true,
                  myUserId: userId!,
                  friendUserIds: friendUserIds)
            ],
          )),
    );
  }
}
