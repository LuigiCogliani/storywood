import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/theme_data.dart';
import '../../models/tip_class.dart';
import '../../models/user_class.dart' as storywood;
import '../../providers/tips_list_provider_riverpod.dart';
import '../../providers/users_provider_riverpod.dart';
import '../../widgets/adaptive_circular_loading.dart';
import '../../widgets/adaptive_alert_dialog_single_button.dart';
import './top_recommendation_item.dart';
import '../../screens/user_profile_top_recommendations_search_screen.dart';

class UserProfileTopRecommendations extends ConsumerWidget {
  const UserProfileTopRecommendations(
      {super.key, required this.profileUser, required this.isMyProfile});
  final storywood.User profileUser;
  final bool isMyProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> topTipIds = profileUser.topRecommendationIds ?? [];
    // load current user ID
    String myUserId = ref.read(userInfoProvider)?.userId ?? 'placeholder';
    final double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              ConstStringUserProfileScreen.tabNameTopRecommendations,
              style: constTourButtonLight,
              textAlign: TextAlign.start,
            ),
            if (isMyProfile)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                        UserProfileTopRecommendationsSearchScreen.routeName);
                  },
                  child: Icon(
                    CupertinoIcons.pencil_ellipsis_rectangle,
                    color: Colors.white,
                    size: screenHeight * 0.025,
                  ),
                ),
              ),
          ],
        ),
        if (topTipIds.isNotEmpty)
          Expanded(
            child: FutureBuilder(
                future: fetchTipsFromFirebaseByTipIdVisibleToMyUserId(
                    topTipIds, myUserId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return adaptiveCircularLoading(
                        color: constCircularProgressIndicatorWhite);
                  } else {
                    if (snapshot.hasError) {
                      return const AdaptiveAlertDialogSingleButton(
                          title: ConstStringPostScreen.loadingError,
                          message: ConstStringPostScreen.errorMessage1,
                          actionMessage: ConstStringAlertDialog.okayButton);
                    }
                    if (snapshot.hasData && snapshot.data != null) {
                      final List<Tip> snapshotTips = snapshot.data as List<Tip>;

                      return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshotTips.length,
                          itemBuilder: (BuildContext context, int index) {
                            final tip = snapshotTips[index];
                            return UserProfileTopRecommendationItem(tip: tip);
                          });
                    }
                    return const AdaptiveAlertDialogSingleButton(
                        title: ConstStringPostScreen.loadingError,
                        message: ConstStringPostScreen.errorMessage2,
                        actionMessage: ConstStringAlertDialog.okayButton);
                  }
                }),
          ),
        if (topTipIds.isEmpty)
          const Expanded(
              child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    ConstStringUserProfileScreen.noTopTipsMessageMyProfile,
                    style: constBodySmallWhite,
                    textAlign: TextAlign.center,
                  )))
      ],
    );
  }
}
