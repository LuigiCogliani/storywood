import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/user_class.dart' as storywood;
import '../../providers/users_provider_riverpod.dart';
import '../../providers/tips_list_provider_riverpod.dart';
import '../../providers/playlist_provider.dart';
import '../../data/environment.dart';
import '../../data/theme_data.dart';
import './remove_friend_alert_dialog.dart';
import '../../screens/user_profile_screen.dart';

//TODO: Irina to optimise functions to be set up once and not duplicated

class CupertinoFriendsListItem extends riverpod.ConsumerWidget {
  const CupertinoFriendsListItem(
      {super.key, required this.friend, required this.isLast});
  final storywood.User friend;
  final bool isLast;
  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    final double spaceBetweenItems = screenHeight * 0.012;
    final avatarRadius = screenWidth * 0.09;
    final spaceBetweenAvatarAndUsername = screenWidth * 0.05;

    final String? imageUrl = friend.imageUrl;

    NetworkImage? storedImageFile =
        imageUrl != null ? NetworkImage(imageUrl) : null;
    const String subtitle = 'feature coming soon';
    const String popUpMenuItem1 = ConstStringFriendsScreen.removeFriendMenuItem;

    Future<void> removeFriend({required String friendUserId}) async {
      //Remove on own account
      ref.read(userInfoProvider.notifier).loadUserInfo();
      String? myUserId = ref.read(userInfoProvider)?.userId;
      final List<String>? friendUserIds =
          ref.read(userInfoProvider)!.friendsUserIds;

      friendUserIds!.remove(friendUserId);

      FirebaseFirestore.instance
          .collection('${ENVIRONMENT}users')
          .doc(myUserId)
          .set({
        'friend_user_ids': friendUserIds,
      }, SetOptions(merge: true));

      ref.invalidate(friendsFutureProvider);

      //Remove on former friend's account
      List<String> otherSideFriendUserIds = [];

      FirebaseFirestore.instance
          .collection('${ENVIRONMENT}users')
          .doc(friendUserId)
          .get()
          .then((DocumentSnapshot doc) {
        otherSideFriendUserIds =
            doc.data().toString().contains('friend_user_ids')
                ? List.from(doc['friend_user_ids'])
                : [];

        otherSideFriendUserIds.remove(myUserId);

        FirebaseFirestore.instance
            .collection('${ENVIRONMENT}users')
            .doc(friendUserId)
            .set({
          'friend_user_ids': otherSideFriendUserIds,
        }, SetOptions(merge: true));
      });

      //Remove tip visibility from each other
      removeVisibleToUserIdFromTipsBySentByUserId(
          sentByUserId: friendUserId, visibleToUserId: myUserId!);
      removeVisibleToUserIdFromTipsBySentByUserId(
          sentByUserId: myUserId!, visibleToUserId: friendUserId);
      removeVisibleToUserIdToPlaylistsCreatedByUserId(
          createdByUserId: friendUserId, visibleToUserId: myUserId!);
      removeVisibleToUserIdToPlaylistsCreatedByUserId(
          createdByUserId: myUserId!, visibleToUserId: friendUserId);
    }

    return GenericFriendsListItem(
        spaceBetweenItems: spaceBetweenItems,
        avatarRadius: avatarRadius,
        storedImageFile: storedImageFile,
        spaceBetweenAvatarAndUsername: spaceBetweenAvatarAndUsername,
        subtitle: subtitle,
        popUpMenuItem1: popUpMenuItem1,
        friend: friend,
        removeFriend: removeFriend,
        isLast: isLast);
  }
}

class FriendsListItem extends riverpod.ConsumerWidget {
  const FriendsListItem(
      {super.key, required this.isLast, required this.friend});
  final bool isLast;
  final storywood.User friend;

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    final double spaceBetweenItems = screenHeight * 0.012;
    final avatarRadius = screenWidth * 0.09;
    final spaceBetweenAvatarAndUsername = screenWidth * 0.05;

    final String? imageUrl = friend.imageUrl;

    NetworkImage? storedImageFile =
        imageUrl != null ? NetworkImage(imageUrl) : null;
    const String subtitle = 'feature coming soon';
    const String popUpMenuItem1 = ConstStringFriendsScreen.removeFriendMenuItem;

    Future<void> removeFriend({required String friendUserId}) async {
      //Remove on own account
      ref.read(userInfoProvider.notifier).loadUserInfo();
      final List<String>? friendUserIds =
          ref.read(userInfoProvider)!.friendsUserIds;
      String? myUserId = ref.read(userInfoProvider)?.userId;

      friendUserIds!.remove(friendUserId);

      FirebaseFirestore.instance
          .collection('${ENVIRONMENT}users')
          .doc(myUserId)
          .set({
        'friend_user_ids': friendUserIds,
      }, SetOptions(merge: true));

      ref.invalidate(friendsFutureProvider);

      //Remove on former friend's account
      List<String> otherSideFriendUserIds = [];

      FirebaseFirestore.instance
          .collection('${ENVIRONMENT}users')
          .doc(friendUserId)
          .get()
          .then((DocumentSnapshot doc) {
        otherSideFriendUserIds =
            doc.data().toString().contains('friend_user_ids')
                ? List.from(doc['friend_user_ids'])
                : [];

        otherSideFriendUserIds.remove(myUserId);

        FirebaseFirestore.instance
            .collection('${ENVIRONMENT}users')
            .doc(friendUserId)
            .set({
          'friend_user_ids': otherSideFriendUserIds,
        }, SetOptions(merge: true));
      });

      //Remove tip visibility from each other
      removeVisibleToUserIdFromTipsBySentByUserId(
          sentByUserId: friendUserId, visibleToUserId: myUserId!);
      removeVisibleToUserIdFromTipsBySentByUserId(
          sentByUserId: myUserId!, visibleToUserId: friendUserId);
      removeVisibleToUserIdToPlaylistsCreatedByUserId(
          createdByUserId: friendUserId, visibleToUserId: myUserId!);
      removeVisibleToUserIdToPlaylistsCreatedByUserId(
          createdByUserId: myUserId!, visibleToUserId: friendUserId);
    }

    return GenericFriendsListItem(
      spaceBetweenItems: spaceBetweenItems,
      avatarRadius: avatarRadius,
      storedImageFile: storedImageFile,
      spaceBetweenAvatarAndUsername: spaceBetweenAvatarAndUsername,
      subtitle: subtitle,
      popUpMenuItem1: popUpMenuItem1,
      friend: friend,
      removeFriend: removeFriend,
      isLast: isLast,
    );
  }
}

class GenericFriendsListItem extends StatelessWidget {
  const GenericFriendsListItem(
      {super.key,
      required this.spaceBetweenItems,
      required this.avatarRadius,
      required this.storedImageFile,
      required this.spaceBetweenAvatarAndUsername,
      required this.subtitle,
      required this.popUpMenuItem1,
      required this.friend,
      required this.removeFriend,
      required this.isLast});

  final double spaceBetweenItems;
  final double avatarRadius;
  final NetworkImage? storedImageFile;
  final double spaceBetweenAvatarAndUsername;
  final String subtitle;
  final String popUpMenuItem1;
  final storywood.User friend;
  final Function removeFriend;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context)
            .pushNamed(UserProfileScreen.routeName, arguments: [false, friend]);
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: constCircleAvatarBackgroundLight,
                  radius: avatarRadius,
                  foregroundImage: storedImageFile != null
                      ? storedImageFile as ImageProvider
                      : null,
                ),
                SizedBox(
                  width: spaceBetweenAvatarAndUsername,
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                    child: Text(
                      friend.userName!,
                      style: constLabelSmallLight,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  //DO NOT REMOVE, commented out for now until we have something to display

                  // SizedBox(
                  //   child: Text(
                  //     subtitle,
                  //     style: constDisplayMediumGrey,
                  //     overflow: TextOverflow.ellipsis,
                  //   ),
                  // )
                ]),
                const Spacer(),
                PopupMenuButton(
                    iconColor: constIconColorLight,
                    onSelected: (value) {
                      if (value == popUpMenuItem1) {
                        removeFriendAlertDialog(
                            context: context,
                            friendUserId: friend.userId,
                            friendUserName: friend.userName,
                            removeFriend: removeFriend);
                      }
                    },
                    itemBuilder: ((BuildContext context) => <PopupMenuEntry>[
                          PopupMenuItem(
                            value: popUpMenuItem1,
                            child: Text(
                              popUpMenuItem1,
                              style: constLabelSmallDark,
                            ),
                          )
                        ])),
              ],
            ),
          ),
          Divider(
            color: isLast ? constScaffoldBackground : constListDivider,
          )
        ],
      ),
    );
  }
}
