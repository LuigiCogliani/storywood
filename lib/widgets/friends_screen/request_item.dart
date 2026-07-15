import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/user_class.dart' as storywood;
import '../../providers/users_provider_riverpod.dart';
import '../../providers/notifications_functions.dart';
import '../../providers/tips_list_provider_riverpod.dart';
import '../../providers/playlist_provider.dart';
import '../../data/environment.dart';
import '../../data/theme_data.dart';
import '../../screens/user_profile_screen.dart';

class CupertinoRequestsListItem extends riverpod.ConsumerStatefulWidget {
  const CupertinoRequestsListItem({super.key, required this.friendRequest});
  final storywood.User friendRequest;
  @override
  riverpod.ConsumerState<CupertinoRequestsListItem> createState() =>
      _CupertinoRequestsListItemState();
}

class _CupertinoRequestsListItemState
    extends riverpod.ConsumerState<CupertinoRequestsListItem> {
  final String subtitle = 'feature coming soon';

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    //final friendRequest = Provider.of<storywood.User>(context);
    final String username = widget.friendRequest.userName!;
    final String? imageUrl = widget.friendRequest.imageUrl;
    widget.friendRequest.imageUrl;
    NetworkImage? storedImageFile =
        imageUrl != null ? NetworkImage(imageUrl) : null;
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final double spaceBetweenItems = screenHeight * 0.03;
    final double spaceBeforeAvatar = screenWidth * 0.03;
    final avatarRadius = screenWidth * 0.09;
    final spaceBetweenAvatarAndUsername = screenWidth * 0.05;
    final double spaceBeweenUsernameAndButtons = screenWidth * 0.025;
    final double buttonWidth = screenWidth * 0.3;
    final double buttonHeight = screenHeight * 0.035;
    final spaceBetweenButtons = screenWidth * 0.03;

    Future<void> rejectFriendRequest(String friendRequestUserId) async {
      final List<String>? friendRequestUserIds =
          ref.read(userInfoProvider)!.friendRequestsUserIds;
      String? myUserId = ref.read(userInfoProvider)?.userId;

      friendRequestUserIds!.remove(friendRequestUserId);

      FirebaseFirestore.instance
          .collection('${ENVIRONMENT}users')
          .doc(myUserId)
          .set({
        'friend_requests_user_ids': friendRequestUserIds,
      }, SetOptions(merge: true));

      ref.invalidate(friendRequestsFutureProvider);
    }

    Future<void> acceptFriendRequest(String friendRequestUserId) async {
      //Remove from friend requests
      final List<String> friendRequestUserIds =
          ref.read(userInfoProvider)!.friendRequestsUserIds ?? [];

      String myUserId = ref.read(userInfoProvider)?.userId ?? '';

      friendRequestUserIds.remove(friendRequestUserId);

      FirebaseFirestore.instance
          .collection('${ENVIRONMENT}users')
          .doc(myUserId)
          .set({
        'friend_requests_user_ids': friendRequestUserIds,
      }, SetOptions(merge: true));

      ref.invalidate(friendRequestsFutureProvider);

      //Add to friends if not already there

      final List<String> friendsUserIds =
          ref.read(userInfoProvider)!.friendsUserIds ?? [];

      if (friendsUserIds.contains(friendRequestUserId) != true) {
        friendsUserIds.add(friendRequestUserId);

        FirebaseFirestore.instance
            .collection('${ENVIRONMENT}users')
            .doc(myUserId)
            .set({
          'friend_user_ids': friendsUserIds,
        }, SetOptions(merge: true));
      }

      ref.invalidate(friendsFutureProvider);

      //Add to friends on the other user's side
      List<String> otherSideFriendUserIds = [];
      List<String> otherSideFriendRequestUserIds = [];

      String myImageUrl = ref.read(userInfoProvider)?.imageUrl ??
          constDefaultImageMisingPlaceholder;

      FirebaseFirestore.instance
          .collection('${ENVIRONMENT}users')
          .doc(friendRequestUserId)
          .get()
          .then((DocumentSnapshot doc) {
        otherSideFriendUserIds =
            doc.data().toString().contains('friend_user_ids')
                ? List.from(doc['friend_user_ids'])
                : [];
        otherSideFriendRequestUserIds =
            doc.data().toString().contains('friend_requests_user_ids')
                ? List.from(doc['friend_requests_user_ids'])
                : [];
        //Add to friends if not already a friend
        if (otherSideFriendUserIds.contains(myUserId) == false) {
          otherSideFriendUserIds.add(myUserId);
        }

        //Remove your request from other friend requests if you happened to send one too
        if (otherSideFriendRequestUserIds.contains(myUserId) == true) {
          otherSideFriendRequestUserIds.remove(myUserId);
        }

        FirebaseFirestore.instance
            .collection('${ENVIRONMENT}users')
            .doc(friendRequestUserId)
            .set({
          'friend_user_ids': otherSideFriendUserIds,
          'friend_requests_user_ids': otherSideFriendRequestUserIds,
        }, SetOptions(merge: true));
      });

      //Send notification that request was approved
      addNewNotification(
          timeStampCreated: DateTime.now().toUtc().toString(),
          tipId: '',
          notificationType: constNotifTypeNewFriendRequestApproved,
          sentBy: myUserId,
          sentTo: [friendRequestUserId],
          imageUrl: myImageUrl,
          ref: ref);

      //Make all friends and public tips visible on each other's newsfeeds
      addVisibleToUserIdToTipsBySentByUserId(
          sentByUserId: myUserId, visibleToUserId: friendRequestUserId);
      addVisibleToUserIdToTipsBySentByUserId(
          sentByUserId: friendRequestUserId, visibleToUserId: myUserId);

      //Make all friends and public collections visible to each other
      addVisibleToUserIdToPlaylistsCreatedByUserId(
          createdByUserId: myUserId, visibleToUserId: friendRequestUserId);
      addVisibleToUserIdToPlaylistsCreatedByUserId(
          createdByUserId: friendRequestUserId, visibleToUserId: myUserId);
    }

    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(UserProfileScreen.routeName,
            arguments: [false, widget.friendRequest]);
      },
      child: Column(
        children: [
          SizedBox(
            height: spaceBetweenItems,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: spaceBeforeAvatar,
              ),
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
                    username,
                    style: constLabelSmallLight,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  height: spaceBeweenUsernameAndButtons,
                ),
                SizedBox(
                  width: screenWidth * 0.67,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                          width: buttonWidth,
                          height: buttonHeight,
                          child: ElevatedButton(
                            onPressed: () {
                              acceptFriendRequest(widget.friendRequest.userId!);
                            },
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                )),
                                backgroundColor: MaterialStateProperty.all(
                                    constElevatedButtonBackgroundLight)),
                            child: const Text(
                              ConstStringFriendsScreen.approveButton,
                              style: constTextButtonDarkSmall,
                            ),
                          )),
                      SizedBox(
                        width: spaceBetweenButtons,
                      ),
                      SizedBox(
                        width: buttonWidth,
                        height: buttonHeight,
                        child: ElevatedButton(
                          onPressed: () {
                            rejectFriendRequest(widget.friendRequest.userId!);
                          },
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              )),
                              backgroundColor: MaterialStateProperty.all(
                                  constRejectFriendRequestButtonBackground)),
                          child: const Text(
                            ConstStringFriendsScreen.rejectButton,
                            style: constSmallTextButtonLight,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ]),
            ],
          )
        ],
      ),
    );
  }
}

class RequestsListItem extends riverpod.ConsumerStatefulWidget {
  const RequestsListItem({super.key});

  @override
  riverpod.ConsumerState<RequestsListItem> createState() =>
      _RequestsListItemState();
}

class _RequestsListItemState extends riverpod.ConsumerState<RequestsListItem> {
  final String subtitle = 'feature coming soon';

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final friendRequest = Provider.of<storywood.User>(context);
    final String username = friendRequest.userName!;
    final String? imageUrl = friendRequest.imageUrl;
    friendRequest.imageUrl;
    NetworkImage? storedImageFile =
        imageUrl != null ? NetworkImage(imageUrl) : null;
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final double spaceBetweenItems = screenHeight * 0.03;
    final double spaceBeforeAvatar = screenWidth * 0.03;
    final avatarRadius = screenWidth * 0.09;
    final spaceBetweenAvatarAndUsername = screenWidth * 0.05;
    final double spaceBeweenUsernameAndButtons = screenWidth * 0.025;
    final double buttonWidth = screenWidth * 0.25;
    final double buttonHeight = screenHeight * 0.035;
    final spaceBetweenButtons = screenWidth * 0.03;

    Future<void> rejectFriendRequest(String friendRequestUserId) async {
      final List<String>? friendRequestUserIds =
          ref.read(userInfoProvider)!.friendRequestsUserIds;
      String myUserId = ref.read(userInfoProvider)?.userId ?? '';

      friendRequestUserIds!.remove(friendRequestUserId);

      FirebaseFirestore.instance
          .collection('${ENVIRONMENT}users')
          .doc(myUserId)
          .set({
        'friend_requests_user_ids': friendRequestUserIds,
      }, SetOptions(merge: true));

      // ignore: unused_result
      ref.refresh(friendRequestsFutureProvider);
    }

    Future<void> acceptFriendRequest(String friendRequestUserId) async {
      //Remove from friend requests
      final List<String> friendRequestUserIds =
          ref.read(userInfoProvider)!.friendRequestsUserIds ?? [];
      final String myUserId = ref.read(userInfoProvider)?.userId ?? '';

      friendRequestUserIds.remove(friendRequestUserId);

      FirebaseFirestore.instance
          .collection('${ENVIRONMENT}users')
          .doc(myUserId)
          .set({
        'friend_requests_user_ids': friendRequestUserIds,
      }, SetOptions(merge: true));

      ref.invalidate(friendRequestsFutureProvider);

      //Add to friends if not already there

      final List<String> friendsUserIds =
          ref.read(userInfoProvider)!.friendsUserIds ?? [];

      if (friendsUserIds.contains(friendRequestUserId) != true) {
        friendsUserIds.add(friendRequestUserId);

        FirebaseFirestore.instance
            .collection('${ENVIRONMENT}users')
            .doc(myUserId)
            .set({
          'friend_user_ids': friendsUserIds,
        }, SetOptions(merge: true));
      }

      ref.invalidate(friendsFutureProvider);

      //Add to friends on the other user's side
      List<String> otherSideFriendUserIds = [];
      List<String> otherSideFriendRequestUserIds = [];

      String myImageUrl = ref.read(userInfoProvider)?.imageUrl ??
          constDefaultImageMisingPlaceholder;

      FirebaseFirestore.instance
          .collection('${ENVIRONMENT}users')
          .doc(friendRequestUserId)
          .get()
          .then((DocumentSnapshot doc) {
        otherSideFriendUserIds =
            doc.data().toString().contains('friend_user_ids')
                ? List.from(doc['friend_user_ids'])
                : [];
        otherSideFriendRequestUserIds =
            doc.data().toString().contains('friend_requests_user_ids')
                ? List.from(doc['friend_requests_user_ids'])
                : [];
        //Add to friends if not already a friend
        if (otherSideFriendUserIds.contains(myUserId) == false) {
          otherSideFriendUserIds.add(myUserId);
        }

        //Remove your request from other friend requests if you happened to send one too
        if (otherSideFriendRequestUserIds.contains(myUserId) == true) {
          otherSideFriendRequestUserIds.remove(myUserId);
        }

        FirebaseFirestore.instance
            .collection('${ENVIRONMENT}users')
            .doc(friendRequestUserId)
            .set({
          'friend_user_ids': otherSideFriendUserIds,
          'friend_requests_user_ids': otherSideFriendRequestUserIds,
        }, SetOptions(merge: true));
      });

      //Send notification that request was approved
      addNewNotification(
          timeStampCreated: DateTime.now().toUtc().toString(),
          tipId: '',
          notificationType: constNotifTypeNewFriendRequestApproved,
          sentBy: myUserId,
          sentTo: [friendRequestUserId],
          imageUrl: myImageUrl,
          ref: ref);

      //Make all friends and public tips visible on each other's newsfeeds
      addVisibleToUserIdToTipsBySentByUserId(
          sentByUserId: myUserId, visibleToUserId: friendRequestUserId);
      addVisibleToUserIdToTipsBySentByUserId(
          sentByUserId: friendRequestUserId, visibleToUserId: myUserId);

      //Make all friends and public collections visible to each other
      addVisibleToUserIdToPlaylistsCreatedByUserId(
          createdByUserId: myUserId, visibleToUserId: friendRequestUserId);
      addVisibleToUserIdToPlaylistsCreatedByUserId(
          createdByUserId: friendRequestUserId, visibleToUserId: myUserId);
    }

    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(UserProfileScreen.routeName,
            arguments: [false, friendRequest]);
      },
      child: Column(
        children: [
          SizedBox(
            height: spaceBetweenItems,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: spaceBeforeAvatar,
              ),
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
                    username,
                    style: constLabelSmallLight,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  height: spaceBeweenUsernameAndButtons,
                ),
                SizedBox(
                  width: screenWidth * 0.67,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                          width: buttonWidth,
                          height: buttonHeight,
                          child: ElevatedButton(
                            onPressed: () {
                              acceptFriendRequest(friendRequest.userId!);
                            },
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                )),
                                backgroundColor: MaterialStateProperty.all(
                                    constElevatedButtonBackgroundLight)),
                            child: Text(
                              ConstStringFriendsScreen.approveButton,
                              style: constTextButtonDarkSmallMediaQuery(
                                  mediaQuerywidth: screenWidth),
                            ),
                          )),
                      SizedBox(
                        width: spaceBetweenButtons,
                      ),
                      SizedBox(
                        width: buttonWidth,
                        height: buttonHeight,
                        child: ElevatedButton(
                          onPressed: () {
                            rejectFriendRequest(friendRequest.userId!);
                          },
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              )),
                              backgroundColor: MaterialStateProperty.all(
                                  constRejectFriendRequestButtonBackground)),
                          child: Text(
                            ConstStringFriendsScreen.rejectButton,
                            style: constSmallTextButtonLightMediaQuery(
                                mediaQuerywidth: screenWidth),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ]),
            ],
          )
        ],
      ),
    );
  }
}
