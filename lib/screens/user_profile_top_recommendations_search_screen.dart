import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/theme_data.dart';
import '../../data/environment.dart';
import '../../models/tip_class.dart';
import '../../providers/users_provider_riverpod.dart';
import '../../widgets/android_ios_picker.dart';
import '../../widgets/user_profile_top_recommendations_screen/post_search_tile.dart';

class UserProfileTopRecommendationsSearchScreen extends ConsumerStatefulWidget {
  const UserProfileTopRecommendationsSearchScreen({super.key});
  static const routeName = '/user-profile-top-recommendations-search-screen';

  @override
  ConsumerState<UserProfileTopRecommendationsSearchScreen> createState() =>
      _UserProfileTopRecommendationsSearchScreenState();
}

class _UserProfileTopRecommendationsSearchScreenState
    extends ConsumerState<UserProfileTopRecommendationsSearchScreen> {
  List<Tip> snapshotTips = [];
  List<Tip> displayedTips = [];

  @override
  Widget build(BuildContext context) {
// load current user ID
    String? userId = ref.read(userInfoProvider)?.userId;

    final query = FirebaseFirestore.instance
        .collection('${ENVIRONMENT}tips')
        .where('sentBy', isEqualTo: userId)
        .where('tipPrivacy',
            whereIn: [constTipPrivacyAllFriends, constTipPrivacyPublic])
        .orderBy('timeStampLastUpdated', descending: true)
        .withConverter<Tip>(
          fromFirestore: (snapshot, _) => Tip.fromJson(snapshot.data()!),
          toFirestore: (tip, _) => tip.toJson(),
        );

    return Scaffold(
      backgroundColor: constTopBarBackgroundColor,
      appBar: AppBar(
        backgroundColor: constTopBarBackgroundColor,
        centerTitle: constIsAppBarTitleNotCentered,
        title: const Text(
          ConstStringUserProfileScreen.selectTopRecommendationsScreenTitle,
          style: constBodyLargeLight,
        ),
        iconTheme: const IconThemeData(color: constIconColorLight),
      ),
      body: FirestoreQueryBuilder(
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
              //  print(snapshot
              //      .error); //uncomment to get the link to create an index for the query
              return const Center(
                  child: Text(
                      ConstStringUserProfileScreen
                          .snapshotErrorFetchTipsToChooseTop,
                      style: constBodySmallLight));
            }

            return SafeArea(
              child: Column(children: [
                const SizedBox(
                  child: Text(
                    ConstStringUserProfileScreen
                        .topRecommendationsTipPrivacyWarning,
                    style: constBodySmallWhite,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                      ),
                      itemCount: snapshot.docs.length,
                      itemBuilder: (context, index) {
                        // if we reached the end of the currently obtained items, we try to
                        // obtain more items
                        //TODO: update condition to account for filtering
                        if (snapshot.hasMore &&
                            index + 1 == snapshot.docs.length) {
                          // Tell FirestoreQueryBuilder to try to obtain more items.
                          // It is safe to call this function from within the build method.

                          snapshot.fetchMore();
                        }

                        final tip = snapshot.docs[index].data();
                        //add the tipId
                        tip.setTipId = snapshot.docs[index].id;

                        return UserProfilePostSearchTile(
                          tip: tip,
                        );
                      }),
                ),
              ]),
            );
          }),
    );
  }
}
