import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/bottom_navigation_bar.dart';
import './user_profile_tabs.dart';
import './image_section.dart';
import './favourite_genres.dart';
import './top_recommendations.dart';

import '../../data/theme_data.dart';
import '../../models/user_class.dart' as storywood;
import '../../providers/users_provider_riverpod.dart';
import '../../providers/friends_functions.dart';

class UserProfileScreenBody extends ConsumerWidget {
  const UserProfileScreenBody(
      {super.key, required this.profileUser, required this.isMyProfile});
  final storywood.User? profileUser;
  final bool isMyProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> favouriteGenreIds = profileUser!.favouriteGenreIds ?? [];
    final List<String> topTipIds = profileUser!.topRecommendationIds ?? [];
    final double screenHeight = MediaQuery.of(context).size.height;
    bool isStrangerProfile = false;
    bool isFriendRequestSent = false;
    final String myUserId = ref.read(userInfoProvider)!.userId!;

    //check if stranger profile should be set to true to show "send friend request" button
    if (isMyProfile) {
      isStrangerProfile = false;
    } else if (profileUser!.userId == myUserId) {
      isStrangerProfile = false;
      //check friend user ids
    } else if (ref.read(userInfoProvider)!.friendsUserIds != null &&
        ref
            .read(userInfoProvider)!
            .friendsUserIds!
            .contains(profileUser!.userId)) {
      isStrangerProfile = false;
    } else {
      isStrangerProfile = true;
    }

    //check if you already sent a friend request to the stranger
    if (isStrangerProfile &&
        profileUser!.friendRequestsUserIds!.contains(myUserId)) {
      isFriendRequestSent = true;
    } else {
      isFriendRequestSent = false;
    }

    Widget buildFriendRequestButton() {
      if (isFriendRequestSent == true) {
        return ElevatedButton(
          onPressed: () {},
          style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              )),
              backgroundColor: MaterialStateProperty.all(
                  constElevatedButtonBackgroundLight)),
          child: const Text(
            ConstStringFriendsScreen.requestSentDummyButton,
            style: constTextButtonDark,
          ),
        );
      } else {
        return ElevatedButton(
          onPressed: () {
            sendFriendRequest(ref: ref, foundUser: profileUser!);
            Navigator.of(context).pop();
          },
          style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              )),
              backgroundColor: MaterialStateProperty.all(
                  constElevatedButtonBackgroundLight)),
          child: const Text(
            ConstStringFriendsScreen.sendFriendRequestButton,
            style: constTextButtonDark,
          ),
        );
      }
    }

    return Scaffold(
        backgroundColor: constScaffoldBackground,
        appBar: AppBar(
          backgroundColor: constTopBarBackgroundColor,
          centerTitle: constIsAppBarTitleNotCentered,
          automaticallyImplyLeading: !isMyProfile,
          iconTheme: const IconThemeData(color: constIconColorLight),
          title: Text(
            profileUser!.userName!,
            style: constTopBar,
          ),
        ),
        body: Column(
          children: [
            SizedBox(
              height: screenHeight * 0.008,
            ),
            Flexible(
              fit: FlexFit.tight,
              flex: 2,
              child: Row(
                children: [
                  Flexible(
                      fit: FlexFit.tight,
                      flex: 2,
                      child: UserProfileImageSection(
                        profileUser: profileUser!,
                        isMyProfile: isMyProfile,
                      )),
                  if (isMyProfile)
                    Flexible(
                        fit: FlexFit.tight,
                        flex: 3,
                        child: UserProfileFavouriteGenres(
                          profileUser: profileUser!,
                          isMyProfile: isMyProfile,
                        )),
                  if (!isMyProfile && favouriteGenreIds.isNotEmpty)
                    Flexible(
                        fit: FlexFit.tight,
                        flex: 3,
                        child: UserProfileFavouriteGenres(
                          profileUser: profileUser!,
                          isMyProfile: isMyProfile,
                        )),
                ],
              ),
            ),
            SizedBox(
              height: screenHeight * 0.008,
            ),
            if (isStrangerProfile) buildFriendRequestButton(),
            if (isStrangerProfile)
              SizedBox(
                height: screenHeight * 0.008,
              ),
            if (isMyProfile)
              Flexible(
                  fit: FlexFit.tight,
                  flex: 2,
                  child: UserProfileTopRecommendations(
                    profileUser: profileUser!,
                    isMyProfile: isMyProfile,
                  )),
            if (!isMyProfile && topTipIds.isNotEmpty)
              Flexible(
                  fit: FlexFit.tight,
                  flex: 2,
                  child: UserProfileTopRecommendations(
                    profileUser: profileUser!,
                    isMyProfile: isMyProfile,
                  )),
            Flexible(
                fit: FlexFit.tight,
                flex: 5,
                child: UserProfileTabs(
                  profileUser: profileUser!,
                  isMyProfile: isMyProfile,
                )),
          ],
        ),
        bottomNavigationBar: const StorywoodBottomNavigationBar());
  }
}
