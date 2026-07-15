import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/theme_data.dart';
import '../../data/environment.dart';
import '../../models/tip_class.dart';
import '../../models/user_class.dart' as storywood;
import '../../providers/users_provider_riverpod.dart';
import '../../providers/user_profile_screen_providers.dart';
import '../../widgets/android_ios_picker.dart';
import '../../widgets/single_playlist_screen/single_playlist_new_tip_button.dart';
import './post_item.dart';
import './posts_content_type_filter.dart';

class UserProfilePostsGrid extends ConsumerWidget {
  const UserProfilePostsGrid(
      {super.key, required this.profileUser, required this.isMyProfile});
  final storywood.User profileUser;
  final bool isMyProfile;

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
// load current user ID
    String? myUserId = ref.read(userInfoProvider)?.userId;

    String? profileUserId = profileUser.userId;

    Map<String, bool> selectedContentTypesMap =
        ref.watch(contentTypePostFilterProvider);

    List<String> selectedContentTypesQueryInput = [];

    for (var key in selectedContentTypesMap.keys) {
      if (selectedContentTypesMap[key] == true) {
        selectedContentTypesQueryInput.add(key);
      }
    }

    if (selectedContentTypesQueryInput.isEmpty) {
      selectedContentTypesQueryInput = [
        constContentTypeMovie,
        constContentTypeTv,
        constContentTypePodcast,
        constContentTypeBook
      ];
    }

    final query = FirebaseFirestore.instance
        .collection('${ENVIRONMENT}tips')
        .where('sentBy', isEqualTo: profileUserId)
        .where('contentType', whereIn: selectedContentTypesQueryInput)
        .where(Filter.or(Filter('tipPrivacy', isEqualTo: constTipPrivacyPublic),
            Filter('visibleTo', arrayContains: myUserId)))
        .orderBy('timeStampLastUpdated', descending: true)
        .withConverter<Tip>(
          fromFirestore: (snapshot, _) => Tip.fromJson(snapshot.data()!),
          toFirestore: (tip, _) => tip.toJson(),
        );

    return Column(
      children: [
        const UserProfilePostsContentTypeFilter(),
        Expanded(
          child: FirestoreQueryBuilder(
              query: query,
              pageSize: 9,
              builder: (context, snapshot, _) {
                if (snapshot.isFetching) {
                  return Center(
                    child: androidIosPicker(
                        androidVersion: const CircularProgressIndicator(
                          color: constCircularProgressIndicatorWhite,
                        ),
                        iosVersion: const CupertinoActivityIndicator(
                          color: constCircularProgressIndicatorWhite,
                        )),
                  );
                }

                if (snapshot.hasError) {
                  //   print(snapshot
                  //       .error); //uncomment to get the link to create an index for the query
                  return const Center(
                      child: Text(
                          ConstStringUserProfileScreen
                              .futureBuilderNotLoadingMessage,
                          style: constBodySmallLight));
                }
                List<Tip> loadedTips = [];
                for (var doc in snapshot.docs) {
                  Tip tip = doc.data();
                  // if we are loading a podcast we need to add the feedurl to the info
                  if (tip.contentType == constContentTypePodcast) {
                    final String podcastUrl =
                        generatePodcastUrl(currentTip: tip);
                    final info = {'feedUrl': podcastUrl};
                    // add the info
                    tip.setInfo = info;
                  }
                  //add the tipId
                  tip.setTipId = doc.id;
                  //add to loadedTips
                  loadedTips.add(tip);
                }

                //Filter out self-tips for my profile, couldn't do at query stage due to Firestore query limitations
                List<Tip> displayedTips = loadedTips
                    .where((tip) => tip.tipPrivacy != constTipPrivacySelfTip)
                    .toList();

                void fetchMoreIfDisplayedZero(List<Tip> displayedTips) {
                  if (snapshot.hasMore && displayedTips.isEmpty) {
                    snapshot.fetchMore();
                  }
                }

                fetchMoreIfDisplayedZero(displayedTips);

                if (displayedTips.isEmpty && isMyProfile) {
                  return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            ConstStringUserProfileScreen.noPostsToDisplay,
                            style: constBodySmallWhite,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SinglePlaylistNewTipButton(ref: ref)
                      ]);
                } else {
                  return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        //childAspectRatio: 2 / 2.2, //controls the height of grid items
                      ),
                      itemCount: displayedTips.length,
                      //snapshot.docs.length,
                      itemBuilder: (context, index) {
                        // if we reached the end of the currently obtained items, we try to
                        // obtain more items
                        if (snapshot.hasMore &&
                            index + 1 == displayedTips.length) {
                          // Tell FirestoreQueryBuilder to try to obtain more items.
                          // It is safe to call this function from within the build method.
                          snapshot.fetchMore();
                        }

                        final tip = displayedTips[index];

                        return UserProfilePostItem(
                          tip: tip,
                        );
                      });
                }
              }),
        ),
      ],
    );
  }
}
