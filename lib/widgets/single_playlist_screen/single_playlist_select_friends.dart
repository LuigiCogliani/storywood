import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/theme_data.dart';
import '../../providers/users_provider_riverpod.dart';
import '../../providers/playlist_provider.dart';
import '../../models/user_class.dart' as storywood;
import '../../models/playlist_class.dart';

//TODO: couldn't add Readmoretext to the list of people collection shared with

/// alert dialog called if error loading friends for share collection button (both iso and android)
class NoFriendsAvailableAlertDialog extends StatelessWidget {
  const NoFriendsAvailableAlertDialog({
    super.key,
  });
  final String title = 'Oops...';
  final String message =
      'Unfortunately we could not load your friends list. Please try again later.';
  final String actionMessage = "I'll try again later";

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text(actionMessage),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      );
    } else {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: Text(actionMessage),
            onPressed: () {
              // Navigate to the login page or perform other actions
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    }
  }
}

///support widget which serves as input for friend list in share collection menu
///used by both iOS and Android
class PlaylistCheckboxTile extends ConsumerStatefulWidget {
  const PlaylistCheckboxTile(
      {required this.username,
      required this.userId,
      required this.isChecked,
      super.key});
  final String username;
  final String userId;
  final bool isChecked;

  @override
  ConsumerState<PlaylistCheckboxTile> createState() =>
      _PlaylistCheckboxTileState();
}

class _PlaylistCheckboxTileState extends ConsumerState<PlaylistCheckboxTile> {
  // initialise the status of the playlist
  bool _checkPlaylist = false;

  @override
  void initState() {
    _checkPlaylist = widget.isChecked;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    return CheckboxListTile(
      side: BorderSide(
        // color of the border of the checkbox
        color: constFilterScreenCheckboxBorderBlack,
        width: screenHeight * 0.003,
      ),
      contentPadding:
          EdgeInsets.symmetric(horizontal: screenWidth * 0.045, vertical: 0),
      // color of the tick
      checkColor: constFilterScreenCheckboxMarkWhite,
      // fill color of the checkbox when the checkbox is checked
      activeColor: constFilterScreenCheckboxFillBlack,
      value: _checkPlaylist,
      onChanged: (bool? newValue) {
        ref.read(tagFriendsPlaylistProvider.notifier).updateListOfTaggedFriends(
            checkboxState: newValue!, userId: widget.userId);
        setState(() {
          _checkPlaylist = newValue;
        });
      },
      tileColor: constElevatedButtonBackgroundGrey,
      title: Text(
        widget.username,
        style: constBodyMediumDark,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

///function that builds select friends interface for share collection for iOS
selectFriendsIOS({
  required BuildContext context,
  required WidgetRef ref,
  required screenHeight,
  required Playlist playlist,
}) {
  final friends = ref.read(friendsFutureProvider);
  return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return friends.when(
          data: (snapshot) {
            final List<storywood.User?> loadedFriends =
                snapshot.values.toList();

            //pull usernames for users already on the list
            final List<storywood.User?> friendsWithAccess = loadedFriends
                .where(
                    (friend) => playlist.listOfUsersId.contains(friend!.userId))
                .toList();
            List friendsWithAccessUsernamesList = [];
            for (final user in friendsWithAccess) {
              friendsWithAccessUsernamesList.add(user!.userName.toString());
            }
            final friendsWithAccessUsernamesDisplayed =
                friendsWithAccessUsernamesList.join(', ');

            //initialise provider to track checkboxes
            List<String> listOfTaggedFriends =
                ref.watch(tagFriendsPlaylistProvider);

            final String? myUserId = ref.read(userInfoProvider)?.userId;

            Widget listViewFriends(List<storywood.User?> loadedFriends) {
              //remove friends who already have access to the list
              loadedFriends.removeWhere(
                  (friend) => playlist.listOfUsersId.contains(friend!.userId));

              //sort usernames alphabetically
              loadedFriends.sort((a, b) => a!.userName!
                  .toLowerCase()
                  .compareTo(b!.userName!.toLowerCase()));

              double height = loadedFriends.length * 100 > screenHeight * 0.55
                  ? screenHeight * 0.55
                  : loadedFriends.length * 90;
              return Container(
                color: constElevatedButtonBackgroundGrey,
                height: height,
                child: ListView.separated(
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(height: 1),
                  itemCount: loadedFriends.length,
                  itemBuilder: ((context, index) {
                    final storywood.User? friend = loadedFriends[index];
                    return CupertinoActionSheetAction(
                      onPressed: () {},
                      child: Material(
                        child: PlaylistCheckboxTile(
                          username: friend!.userName!,
                          userId: friend.userId!,
                          isChecked: listOfTaggedFriends.contains(friend.userId)
                              ? true
                              : false,
                        ),
                      ),
                    );
                  }),
                ),
              );
            }

            return CupertinoActionSheet(
              actions: [
                if (friendsWithAccessUsernamesDisplayed.isNotEmpty)
                  Container(
                    color: constElevatedButtonBackgroundGrey,
                    child: CupertinoActionSheetAction(
                      onPressed: () {},
                      child: Text(
                        '${ConstStringSinglePlaylistScreen.titleCollectionSharedWith}$friendsWithAccessUsernamesDisplayed',
                        textAlign: TextAlign.left,
                        style: constBodyMediumDark,
                      ),
                    ),
                  ),
                Container(
                  color: constElevatedButtonBackgroundGrey,
                  child: CupertinoActionSheetAction(
                    onPressed: () {},
                    child: const Text(
                      ConstStringSinglePlaylistScreen.titleChooseFriends,
                      textAlign: TextAlign.start,
                      style: constBodyMediumBoldDark,
                    ),
                  ),
                ),
                listViewFriends(loadedFriends),
                Container(
                    color: constElevatedButtonBackgroundGrey,
                    child: CupertinoActionSheetAction(
                        onPressed: () {
                          ref
                              .read(playlistProvider.notifier)
                              .addUsersToPlaylist(
                                  myUserId: myUserId!,
                                  ref: ref,
                                  playlistId: playlist.id,
                                  userIds: ref.read(
                                    tagFriendsPlaylistProvider,
                                  ));
                          Navigator.pop(context);
                          //removed tagged friends from local memory
                          ref
                              .read(tagFriendsPlaylistProvider.notifier)
                              .resetProvider();
                        },
                        child: const Text(
                          ConstStringSinglePlaylistScreen.shareButton,
                          style: constBodyMediumBoldDark,
                        ))),
              ],
              cancelButton: CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(context);
                    //removed tagged friends from local memory
                    ref
                        .read(tagFriendsPlaylistProvider.notifier)
                        .resetProvider();
                  },
                  child: const Text(
                    ConstStringSinglePlaylistScreen.menuButtonCancel,
                    style: constBodyMediumDark,
                  )),
            );
          },
          loading: () {
            return const Center(
                child: CupertinoActivityIndicator(
              color: constCircularProgressIndicatorWhite,
            ));
          },
          error: (e, st) => const NoFriendsAvailableAlertDialog(),
        );
      });
}

///function that builds select friends interface for share collection for Android
selectFriendsAndroid({
  required BuildContext context,
  required WidgetRef ref,
  required screenHeight,
  required Playlist playlist,
}) {
  final friends = ref.read(friendsFutureProvider);
  return showModalBottomSheet(
      backgroundColor: constModalBottomSheetDefaultBackground,
      // color of the screen showing while the future builder is loading
      barrierColor: constModalBottomSheetDefaultBackground,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return friends.when(
          data: (snapshot) {
            final List<storywood.User?> loadedFriends =
                snapshot.values.toList();

            //pull usernames for users already on the list
            final List<storywood.User?> friendsWithAccess = loadedFriends
                .where(
                    (friend) => playlist.listOfUsersId.contains(friend!.userId))
                .toList();
            List friendsWithAccessUsernamesList = [];
            for (final user in friendsWithAccess) {
              friendsWithAccessUsernamesList.add(user!.userName.toString());
            }
            final friendsWithAccessUsernamesDisplayed =
                friendsWithAccessUsernamesList.join(', ');

            //initialise provider to track checkboxes
            List<String> listOfTaggedFriends =
                ref.watch(tagFriendsPlaylistProvider);

            //remove friends who already have access to the list
            loadedFriends.removeWhere(
                (friend) => playlist.listOfUsersId.contains(friend!.userId));

            //sort usernames alphabetically
            loadedFriends.sort((a, b) => a!.userName!
                .toLowerCase()
                .compareTo(b!.userName!.toLowerCase()));

            final String? myUserId = ref.read(userInfoProvider)?.userId;

            return SizedBox(
              height: screenHeight * 0.9,
              child: Center(
                child: Column(
                  children: [
                    if (friendsWithAccessUsernamesDisplayed.isNotEmpty)
                      Container(
                        width: double.infinity,
                        height: screenHeight * 0.05,
                        color: constElevatedButtonBackgroundGrey,
                        child: Center(
                          child: Text(
                            '${ConstStringSinglePlaylistScreen.titleCollectionSharedWith}$friendsWithAccessUsernamesDisplayed',
                            textAlign: TextAlign.center,
                            style: constBodyMediumDark,
                          ),
                        ),
                      ),
                    const Divider(height: 1),
                    Container(
                      width: double.infinity,
                      height: screenHeight * 0.05,
                      color: constElevatedButtonBackgroundGrey,
                      child: const Center(
                        child: Text(
                          ConstStringSinglePlaylistScreen.titleChooseFriends,
                          textAlign: TextAlign.center,
                          style: constBodyMediumBoldDark,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.separated(
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(height: 1),
                        itemCount: loadedFriends.length,
                        itemBuilder: (BuildContext context, int index) {
                          final storywood.User? friend = loadedFriends[index];
                          return PlaylistCheckboxTile(
                              username: friend!.userName!,
                              userId: friend.userId!,
                              isChecked:
                                  listOfTaggedFriends.contains(friend.userId)
                                      ? true
                                      : false);
                        },
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  constElevatedButtonBackgroundLight),
                          onPressed: () {
                            ref
                                .read(playlistProvider.notifier)
                                .addUsersToPlaylist(
                                    myUserId: myUserId!,
                                    ref: ref,
                                    playlistId: playlist.id,
                                    userIds:
                                        ref.read(tagFriendsPlaylistProvider));
                            Navigator.pop(context);
                            //removed tagged friends from local memory
                            ref
                                .read(tagFriendsPlaylistProvider.notifier)
                                .resetProvider();
                          },
                          child: const Text(
                            ConstStringSinglePlaylistScreen.shareButton,
                            style: constBodyMediumDark,
                          )),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  constElevatedButtonBackgroundLight),
                          onPressed: () {
                            Navigator.pop(context);
                            //removed tagged friends from local memory
                            ref
                                .read(tagFriendsPlaylistProvider.notifier)
                                .resetProvider();
                          },
                          child: const Text(
                            ConstStringSinglePlaylistScreen.menuButtonCancel,
                            style: constBodyMediumDark,
                          )),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () {
            return const Center(
                child: CircularProgressIndicator(
              color: constCircularProgressIndicatorWhite,
            ));
          },
          error: (e, st) => const NoFriendsAvailableAlertDialog(),
        );
      });
}
