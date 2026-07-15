import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../providers/users_provider_riverpod.dart';
import '../../data/environment.dart';
import '../../data/theme_data.dart';
import '../../providers/new_tip_provider.dart';

import '../adaptive_circular_loading.dart';
import '../material_wrapped.dart';

/// alert dialog used for content screen and new tip screen (both iso and android)
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

class PlaylistCheckboxTile extends riverpod.ConsumerStatefulWidget {
  const PlaylistCheckboxTile(
      {required this.username,
      required this.userId,
      required this.isChecked,
      super.key});
  final String username;
  final String userId;
  final bool isChecked;

  @override
  riverpod.ConsumerState<PlaylistCheckboxTile> createState() =>
      _PlaylistCheckboxTileState();
}

class _PlaylistCheckboxTileState
    extends riverpod.ConsumerState<PlaylistCheckboxTile> {
  // initialise the status of the playlist
  bool _checkPlaylist = false;

  @override
  void initState() {
    // // initialise a map of playlist id and bool
    //   final playlistCheckbox = ref.read(playlistCheckboxesStatusProvider);
    //   // load the checkbox from the provider

    //   _checkPlaylist = playlistCheckbox[widget.playlistItem.id] ?? false;

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
        ref.read(tagFriendsProvider.notifier).updateListOfTaggedFriends(
            checkboxState: newValue!, userId: widget.userId);
        setState(() {
          _checkPlaylist = newValue;
        });
      },
      tileColor: constElevatedButtonBackgroundGrey,
      title: Text(
        '${widget.username}',
        style: constBodyMediumDark,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

Future<List<Map<String, String>>> fetchFriends(ref) async {
  // get the id of the current user
  String? userId = ref.read(userInfoProvider)?.userId;
  // init an empty list for the friends id
  List<String> listOfFriends = [];
  // init an empty map for username and id
  Map<String, String> userIdToUsername = {};
  Map<String, String> usernameToUserId = {};
  // get list of friends usernames from firebase
  final DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
      .collection('${ENVIRONMENT}users')
      .doc(userId)
      .get();
  // assign the list of friends to variable
  listOfFriends = List.from(docSnapshot['friend_user_ids']);
// get usernames to corresponding userIds
  for (var friendUserId in listOfFriends) {
    await FirebaseFirestore.instance
        .collection('${ENVIRONMENT}users')
        .doc(friendUserId)
        .get()
        .then((DocumentSnapshot doc) {
      userIdToUsername[friendUserId] = doc['username'];
      usernameToUserId[doc['username']] = friendUserId;
    });
  }
// add map to provider
  ref.read(userIdToUsernameProvider.notifier).assignMap(userIdToUsername);
  return [userIdToUsername, usernameToUserId];
}

iosActionSheet(
    {required context,
    required ref,
    required screenHeight,
    required tipId,
    required isFilterScreen,
    required futureFunction}) {
  return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<List<Map<String, String>>>(
            future: fetchFriends(ref),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasError) {
                return const NoFriendsAvailableAlertDialog();
              } else if (snapshot.hasData) {
                // get the list of users from the snapshot
                Map<String, String> userIdToUsername = snapshot.data![0];
                Map<String, String> userInameToUserId = snapshot.data![1];

                List usernameList = userIdToUsername.values.toList();

                List<String> listOfTaggedFriends =
                    ref.watch(tagFriendsProvider);

                // initialise empty list of cupertino action sheet actions
                List userlistActions = [];
                // fill it with checbox tiles
                for (var username in usernameList) {
                  userlistActions.add(Container(
                    color: constElevatedButtonBackgroundGrey,
                    child: CupertinoActionSheetAction(
                        onPressed: () {},
                        child: Material(
                          child: PlaylistCheckboxTile(
                            username: username,
                            userId: userInameToUserId[username]!,
                            isChecked: listOfTaggedFriends
                                    .contains(userInameToUserId[username]!)
                                ? true
                                : false,
                          ),
                        )),
                  ));
                }

                return CupertinoActionSheet(
                  actions: [
                    Container(
                        color: constElevatedButtonBackgroundGrey,
                        child: CupertinoActionSheetAction(
                            onPressed: () {},
                            child: const Text(
                              ConstNewTipScreen.chooseFriendsLabel,
                              style: constBodyMediumDark,
                            ))),
                    ...userlistActions
                  ],
                  cancelButton: CupertinoActionSheetAction(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        ConstStringFiltersScreen.closePlaylist,
                        style: constBodyMediumDark,
                      )),
                );
              } else {
                return adaptiveCircularLoading(
                    color: constCircularProgressIndicatorBlack);
              }
            });
      });
}

/// shows the playlist modal bottom sheet for android and ios
playlists(
    {required context,
    required screenHeight,
    required ref,
    required tipId,
    required isFilterScreen,
    required futureFunction}) {
  return Platform.isIOS
      ? iosActionSheet(
          context: context,
          isFilterScreen: isFilterScreen,
          ref: ref,
          screenHeight: screenHeight,
          tipId: tipId,
          futureFunction: futureFunction)
      : showModalBottomSheet(
          backgroundColor: constModalBottomSheetDefaultBackground,
          // color of the screen showing while the future builder is loading
          barrierColor: constModalBottomSheetDefaultBackground,
          isScrollControlled: true,
          context: context,
          builder: (BuildContext context) {
            return FutureBuilder<List<Map<String, String>>>(
                future: fetchFriends(ref),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasError) {
                    return const NoFriendsAvailableAlertDialog();
                  } else if (snapshot.hasData) {
                    // get the list of users from the snapshot
                    Map<String, String> userIdToUsername = snapshot.data![0];
                    Map<String, String> userInameToUserId = snapshot.data![1];

                    List usernameList = userIdToUsername.values.toList();

                    List<String> listOfTaggedFriends =
                        ref.watch(tagFriendsProvider);

                    return SizedBox(
                      height: screenHeight * 0.9,
                      child: Center(
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(screenHeight * 0.001),
                              child: Text(
                                ConstNewTipScreen.chooseFriendsLabel,
                                style: constTitleSmallLightBold,
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: usernameList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  String username = usernameList[index];
                                  return PlaylistCheckboxTile(
                                      username: username,
                                      userId: userInameToUserId[username]!,
                                      isChecked: listOfTaggedFriends.contains(
                                              userInameToUserId[username]!)
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
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    ConstStringFiltersScreen.closePlaylist,
                                    style: constBodyMediumDark,
                                  )),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return adaptiveCircularLoading(
                        color: constCircularProgressIndicatorWhite);
                  }
                });
          });
}

/// tile that will open a modal bottom sheet (android) or a cupertino action
/// sheet (ios) with list of checkbox tiles of friends to tag in the tip
class TagFriendsTile extends riverpod.ConsumerWidget {
  const TagFriendsTile(
      {super.key,
      required this.mediaQueryHeight,
      required this.isFilterScreen,
      required this.tipId,
      required this.futureFunction});
  final String tipId;
  final double mediaQueryHeight;
  final bool isFilterScreen;
  final futureFunction;

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        playlists(
            context: context,
            screenHeight: mediaQueryHeight,
            ref: ref,
            tipId: tipId,
            isFilterScreen: isFilterScreen,
            futureFunction: futureFunction);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: mediaQueryHeight * 0.005),
        child: ListTile(
          tileColor: constTileBackground,
          leading: Icon(
            Platform.isIOS
                ? constTagFriendsCupertinoIcon
                : constTagFriendsMaterialIcon,
            color: constIconColorLight,
          ),
          title: const Text(
            ConstNewTipScreen.tagFriendsLabel,
            style: constBodyMediumWhite,
          ),
          subtitle: PlaylistNames(),
        ),
      ),
    );
  }
}

class PlaylistNames extends riverpod.ConsumerWidget {
  const PlaylistNames({super.key});

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    Map<String, String> userIdToUsernames = ref.watch(userIdToUsernameProvider);
    if (userIdToUsernames.isEmpty) {
      return SizedBox(
        width: 1,
      );
    } else {
      List listOfIds = ref.watch(tagFriendsProvider);

      List listOfNames = [];
      for (var id in listOfIds) {
        listOfNames.add(userIdToUsernames[id]);
      }
      String stringOfNames = listOfNames.join(', ');
      return Text(
        stringOfNames,
        style: constDisplayMediumLight,
        overflow: TextOverflow.ellipsis,
      );
    }
  }
}
