import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import '../../providers/users_provider_riverpod.dart';
import '../../providers/friends_functions.dart';
import '../../data/theme_data.dart';
import '../../models/user_class.dart' as storywood;
import '../../screens/user_profile_screen.dart';

class UsersSearchListItem extends riverpod.ConsumerStatefulWidget {
  const UsersSearchListItem({super.key, required this.user});
  final storywood.User user;

  @override
  riverpod.ConsumerState<UsersSearchListItem> createState() =>
      _UsersSearchListItemState();
}

class _UsersSearchListItemState
    extends riverpod.ConsumerState<UsersSearchListItem> {
  final String subtitle = 'feature coming soon';

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final foundUser = widget.user;
    final String username = foundUser.userName!;
    final String? imageUrl = foundUser.imageUrl;

    final bool? isMe =
        ref.watch(userInfoProvider)?.userId!.contains(foundUser.userId!);
    final bool? isFriendAlready;
    if (ref.watch(userInfoProvider)?.friendsUserIds != null) {
      isFriendAlready = ref
          .watch(userInfoProvider)
          ?.friendsUserIds
          ?.contains(foundUser.userId);
    } else {
      isFriendAlready = null;
    }
    final bool? friendRequestSentAlready;
    if (foundUser.friendRequestsUserIds != null) {
      friendRequestSentAlready = foundUser.friendRequestsUserIds
          ?.contains(ref.watch(userInfoProvider)?.userId);
    } else {
      friendRequestSentAlready = null;
    }
    NetworkImage? storedImageFile =
        imageUrl != null ? NetworkImage(imageUrl) : null;
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final double spaceBetweenItems = screenHeight * 0.03;
    final double spaceBeforeAvatar = screenWidth * 0.03;
    final avatarRadius = screenWidth * 0.09;
    final spaceBetweenAvatarAndUsername = screenWidth * 0.05;
    final double spaceBeweenUsernameAndButtons = screenWidth * 0.025;
    final double buttonHeight = screenHeight * 0.035;

    // Future<void> sendFriendRequest(String friendRequestUserId) async {
    //   //Load existing friend requests for that user
    //   final List<String>? friendRequestUserIds =
    //       foundUser.friendRequestsUserIds ?? [];

    //   //Add my user id to the friend requests list
    //   String myUserId = ref.read(userInfoProvider)?.userId ?? '';
    //   friendRequestUserIds?.add(myUserId);

    //   String myImageUrl = ref.read(userInfoProvider)?.imageUrl ??
    //       constDefaultImageMisingPlaceholder;

    //   FirebaseFirestore.instance
    //       .collection('${ENVIRONMENT}users')
    //       .doc(friendRequestUserId)
    //       .set({
    //     'friend_requests_user_ids': friendRequestUserIds,
    //   }, SetOptions(merge: true));

    //   //Send notification to the request receiver
    //   addNewNotification(
    //       timeStampCreated: DateTime.now().toUtc().toString(),
    //       tipId: '',
    //       notificationType: constNotifTypeNewFriendRequestReceived,
    //       sentBy: myUserId,
    //       sentTo: [friendRequestUserId],
    //       imageUrl: myImageUrl,
    //       ref: ref);
    // }

    Widget buildButton() {
      if (isMe == true) {
        return ElevatedButton(
          onPressed: () {},
          style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              )),
              backgroundColor: MaterialStateProperty.all(
                  constElevatedButtonBackgroundLight)),
          child: const Text(
            ConstStringFriendsScreen.youDummyButton,
            style: constTextButtonDark,
          ),
        );
      } else if (isFriendAlready == true) {
        return ElevatedButton(
          onPressed: () {},
          style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              )),
              backgroundColor: MaterialStateProperty.all(
                  constElevatedButtonBackgroundLight)),
          child: const Text(
            ConstStringFriendsScreen.yourFriendDummyButton,
            style: constTextButtonDark,
          ),
        );
      } else if (friendRequestSentAlready == true) {
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
            sendFriendRequest(ref: ref, foundUser: foundUser);
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

    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(UserProfileScreen.routeName,
            arguments: [false, foundUser]);
      },
      child: Container(
        color: constTileBackground,
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
                    width: screenWidth * 0.65,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          // width: buttonWidth,
                          height: buttonHeight,
                          child: buildButton(),
                        ),
                      ],
                    ),
                  ),
                ]),
              ],
            )
          ],
        ),
      ),
    );
  }
}
