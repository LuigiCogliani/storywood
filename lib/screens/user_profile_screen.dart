import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/user_profile_screen/user_profile_screen_body.dart';
import '../widgets/adaptive_circular_loading.dart';
import '../widgets/adaptive_alert_dialog_single_button.dart';
import '../providers/users_provider_riverpod.dart';
import '../models/user_class.dart' as storywood;
import '../data/theme_data.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});
  static const routeName = '/userprofile-screen';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modalRouteArguments =
        ModalRoute.of(context)!.settings.arguments as List;
    final bool isMyProfile = modalRouteArguments[0];

    final storywood.User? routeProfileUser =
        modalRouteArguments[1] as storywood.User?;
    // this is used when we access the user profile by clicking on the avatar in the newsfeed
    if (routeProfileUser == null) {
      final String userId = modalRouteArguments[2];
      Future<storywood.User?> future = fetchSingleUserFromFirebase(userId);
      return FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return adaptiveCircularLoading(
                  color: constCircularProgressIndicatorWhite);
            } else {
              if (snapshot.hasError || snapshot.data == null) {
                return const AdaptiveAlertDialogSingleButton(
                    title: ConstStringUserProfileScreen.errorDialogTitle,
                    message: ConstStringUserProfileScreen.centerErrorMessage,
                    actionMessage: ConstStringAlertDialog.okayButton);
              }
              if (snapshot.hasData && snapshot.data != null) {
                final storywood.User profileUser =
                    snapshot.data as storywood.User;

                return UserProfileScreenBody(
                  profileUser: profileUser,
                  isMyProfile: isMyProfile,
                );
              }
              return const AdaptiveAlertDialogSingleButton(
                  title: ConstStringUserProfileScreen.errorDialogTitle,
                  message: ConstStringUserProfileScreen.centerErrorMessage,
                  actionMessage: ConstStringAlertDialog.okayButton);
            }
          });
    } else {
      storywood.User? profileUser;
      if (isMyProfile) {
        profileUser = ref.watch(userInfoProvider);
      } else if (routeProfileUser != null) {
        profileUser = routeProfileUser;
      }
      return UserProfileScreenBody(
        profileUser: profileUser,
        isMyProfile: isMyProfile,
      );
    }

    //Future<storywood.User?> future = fetchSingleUserFromFirebase(userId);

    // if (isMyProfile) {
    //   profileUser = ref.watch(userInfoProvider);
    // } else if (routeProfileUser != null) {
    //   profileUser = routeProfileUser;
    // }

    // return
    // routeProfileUser==null
    // ?
    // FutureBuilder(
    //     future: future,
    //     builder: (context, snapshot) {
    //       if (snapshot.connectionState == ConnectionState.waiting) {
    //         return adaptiveCircularLoading(
    //             color: constCircularProgressIndicatorWhite);
    //       } else {
    //         if (snapshot.hasError || snapshot.data == null) {
    //           return const AdaptiveAlertDialogSingleButton(
    //               title: ConstStringUserProfileScreen.errorDialogTitle,
    //               message: ConstStringUserProfileScreen.centerErrorMessage,
    //               actionMessage: ConstStringAlertDialog.okayButton);
    //         }
    //         if (snapshot.hasData && snapshot.data != null) {
    //           final storywood.User profileUser =
    //               snapshot.data as storywood.User;

    //           return UserProfileScreenBody(
    //             profileUser: profileUser,
    //             isMyProfile: isMyProfile,
    //           );
    //         }
    //         return const AdaptiveAlertDialogSingleButton(
    //             title: ConstStringUserProfileScreen.errorDialogTitle,
    //             message: ConstStringUserProfileScreen.centerErrorMessage,
    //             actionMessage: ConstStringAlertDialog.okayButton);
    //       }
    //     })
// : UserProfileScreenBody(
//                 profileUser: profileUser,
//                 isMyProfile: isMyProfile,
//               );
  }
}
