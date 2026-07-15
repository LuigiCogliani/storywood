import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:irina_storywood_mockup/providers/users_provider_riverpod.dart';

import '../../models/playlist_class.dart';
import '../../data/theme_data.dart';
import '../../providers/playlist_provider.dart';
import '../../screens/playlists_overview_screen.dart';
import './single_playlist_select_friends.dart';

class AndroidSinglePlaylistPopupMenuButton extends ConsumerStatefulWidget {
  const AndroidSinglePlaylistPopupMenuButton(
      {super.key, required this.playlist});
  final Playlist playlist;

  @override
  ConsumerState<AndroidSinglePlaylistPopupMenuButton> createState() =>
      _AndroidSinglePlaylistPopupMenuButtonState();
}

class _AndroidSinglePlaylistPopupMenuButtonState
    extends ConsumerState<AndroidSinglePlaylistPopupMenuButton> {
  late TextEditingController newPlaylistNameController;

  @override
  void initState() {
    super.initState();
    newPlaylistNameController = TextEditingController.fromValue(
        TextEditingValue(text: widget.playlist.name));
  }

  @override
  void dispose() {
    newPlaylistNameController.dispose();
    super.dispose();
  }

  showDeleteDialogAlert(BuildContext context, WidgetRef ref) {
    return showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(
              ConstStringSinglePlaylistScreen.deleteAlertDialogTitle),
          content: const Text(
              ConstStringSinglePlaylistScreen.deleteAlertDialogContent),
          actions: [
            TextButton(
                onPressed: () {
                  String? userId = ref.read(userInfoProvider)?.userId;
                  ref.read(playlistProvider.notifier).deletePlaylist(
                      playlist: widget.playlist, userId: userId);
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .pushNamed(PlaylistsOverviewScreen.routeName);
                },
                child: const Text(
                  ConstStringSinglePlaylistScreen.deleteAlertDialogDelete,
                  style: constTextButtonDark,
                )),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(ConstStringAlertDialog.cancelButton,
                    style: constTextButtonDark)),
          ],
        );
      },
    );
  }

  showRenameCollectionDialogAlert(
      BuildContext context,
      WidgetRef ref,
      mediaQueryHeight,
      TextEditingController newPlaylistNameController,
      String playlistPreviousName) {
    TextEditingController newPlaylistNameController =
        TextEditingController.fromValue(
            TextEditingValue(text: playlistPreviousName));

    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                ConstStringSinglePlaylistScreen.menuButtonItem2,
                style: constNewCollectionAlertTite(mediaQueryHeight),
              ),
              content: TextField(
                autofocus: true,
                autocorrect: true,
                decoration: InputDecoration(
                  hintText:
                      ConstStringPlaylistsScreen.newPlaylistAlertHintMessage,
                  hintStyle:
                      constNewCollectionAlertHintMediumDark(mediaQueryHeight),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                controller: newPlaylistNameController,
                style: constNewCollectionInputMediumDark(mediaQueryHeight),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      if (newPlaylistNameController.text.isNotEmpty) {
                        ref.read(playlistProvider.notifier).updatePlaylistName(
                            playlistId: widget.playlist.id,
                            newName: newPlaylistNameController.text);
                      }
                      Navigator.of(context).pop();
                      newPlaylistNameController.clear();
                    },
                    child: Text(ConstStringPlaylistsScreen.newPlaylistAlertSave,
                        style: constNewCollectionButtons(mediaQueryHeight))),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      newPlaylistNameController.clear();
                    },
                    child: Text(
                        ConstStringPlaylistsScreen.newPlaylistAlertCancel,
                        style: constNewCollectionButtons(mediaQueryHeight)))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    final double mediaQueryHeight = MediaQuery.of(context).size.height;
    const double iconScalingFactor = 0.04;
    const String item1 = ConstStringSinglePlaylistScreen.menuButtonItem1;
    const String item2 = ConstStringSinglePlaylistScreen.menuButtonItem2;
    const String item3 = ConstStringSinglePlaylistScreen.menuButtonItem3;
    return PopupMenuButton(
      color: constIconColorLight,
      iconColor: constIconColorLight,
      iconSize: mediaQueryHeight * iconScalingFactor,
      onSelected: (value) {
        if (value == item1) {
          showDeleteDialogAlert(context, ref);
        } else if (value == item2) {
          showRenameCollectionDialogAlert(context, ref, mediaQueryHeight,
              newPlaylistNameController, widget.playlist.name);
        } else if (value == item3) {
          selectFriendsAndroid(
              context: context,
              screenHeight: mediaQueryHeight,
              ref: ref,
              playlist: widget.playlist);
        }
      },
      itemBuilder: ((BuildContext context) => <PopupMenuEntry>[
            const PopupMenuItem(
              value: ConstStringSinglePlaylistScreen.menuButtonItem1,
              child: Text(
                ConstStringSinglePlaylistScreen.menuButtonItem1,
                style: constLabelSmallDark,
              ),
            ),
            const PopupMenuItem(
              value: ConstStringSinglePlaylistScreen.menuButtonItem2,
              child: Text(
                ConstStringSinglePlaylistScreen.menuButtonItem2,
                style: constLabelSmallDark,
              ),
            ),
            const PopupMenuItem(
              value: ConstStringSinglePlaylistScreen.menuButtonItem3,
              child: Text(
                ConstStringSinglePlaylistScreen.menuButtonItem3,
                style: constLabelSmallDark,
              ),
            ),
          ]),
    );
  }
}

//TODO: see if can organise Cupertino widget code below better

class CupertinoSinglePlaylistMenuButton extends ConsumerStatefulWidget {
  const CupertinoSinglePlaylistMenuButton({super.key, required this.playlist});

  final Playlist playlist;

  @override
  ConsumerState<CupertinoSinglePlaylistMenuButton> createState() =>
      _CupertinoSinglePlaylistMenuButtonState();
}

class _CupertinoSinglePlaylistMenuButtonState
    extends ConsumerState<CupertinoSinglePlaylistMenuButton> {
  late TextEditingController newPlaylistNameController;
  String newPlaylistName = '';

  @override
  void initState() {
    super.initState();
    newPlaylistNameController = TextEditingController.fromValue(
        TextEditingValue(text: widget.playlist.name));
  }

  @override
  void dispose() {
    newPlaylistNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double mediaQueryHeight = MediaQuery.of(context).size.height;
    const double iconScalingFactor = 0.04;
    final String? userId = ref.read(userInfoProvider)?.userId;

    return CupertinoButton(
      onPressed: () {
        showCupertinoModalPopup(
            context: context,
            builder: (ctx) {
              return CupertinoActionSheet(
                actions: [
                  Container(
                    color: Colors.white,
                    child: CupertinoActionSheetAction(
                        onPressed: () {
                          Navigator.of(context).pop();
                          showDialog(
                              context: context,
                              builder: (context) => CupertinoAlertDialog(
                                    title: const Text(
                                        ConstStringSinglePlaylistScreen
                                            .deleteAlertDialogTitle),
                                    content: const Text(
                                        ConstStringSinglePlaylistScreen
                                            .deleteAlertDialogContent),
                                    actions: [
                                      CupertinoDialogAction(
                                        isDestructiveAction: true,
                                        onPressed: () {
                                          // in cupertino we need to call this function explicitly
                                          ref
                                              .read(playlistProvider.notifier)
                                              .deletePlaylist(
                                                  playlist: widget.playlist,
                                                  userId: userId);
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pushNamed(
                                              PlaylistsOverviewScreen
                                                  .routeName);
                                        },
                                        child: const Text(
                                          ConstStringAlertDialog.yesButton,
                                        ),
                                      ),
                                      CupertinoDialogAction(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text(
                                            ConstStringAlertDialog.noButton),
                                      ),
                                    ],
                                  ));
                        },
                        isDestructiveAction: true,
                        child: const Text(
                            ConstStringSinglePlaylistScreen.menuButtonItem1)),
                  ),
                  Container(
                    color: Colors.white,
                    child: CupertinoActionSheetAction(
                        onPressed: () {
                          Navigator.of(context).pop();
                          showDialog(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: Padding(
                                padding: const EdgeInsets.only(bottom: 18.0),
                                child: Text(
                                  ConstStringSinglePlaylistScreen
                                      .menuButtonItem2,
                                  style: constNewCollectionAlertTite(
                                      mediaQueryHeight),
                                ),
                              ),
                              content: CupertinoTextField(
                                autofocus: true,
                                autocorrect: true,
                                placeholder: ConstStringPlaylistsScreen
                                    .newPlaylistAlertHintMessage,
                                placeholderStyle:
                                    constNewCollectionAlertHintMediumDark(
                                        mediaQueryHeight),
                                decoration: const BoxDecoration(
                                  color: Colors.white54,
                                ),
                                controller: newPlaylistNameController,
                                style: constNewCollectionInputMediumDark(
                                    mediaQueryHeight),
                                onChanged: (value) {
                                  setState(() {
                                    newPlaylistName = value;
                                  });
                                },
                              ),
                              actions: [
                                CupertinoDialogAction(
                                    isDefaultAction: true,
                                    onPressed: () {
                                      if (newPlaylistNameController
                                          .text.isNotEmpty) {
                                        ref
                                            .read(playlistProvider.notifier)
                                            .updatePlaylistName(
                                                playlistId: widget.playlist.id,
                                                newName:
                                                    newPlaylistNameController
                                                        .text);
                                        setState(() {});
                                      }
                                      Navigator.of(context).pop();
                                      newPlaylistNameController.clear();
                                    },
                                    child: Text(
                                        ConstStringPlaylistsScreen
                                            .newPlaylistAlertSave,
                                        style: constNewCollectionButtons(
                                            mediaQueryHeight))),
                                CupertinoDialogAction(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      newPlaylistNameController.clear();
                                    },
                                    child: Text(
                                        ConstStringPlaylistsScreen
                                            .newPlaylistAlertCancel,
                                        style: constNewCollectionButtons(
                                            mediaQueryHeight)))
                              ],
                            ),
                          );
                        },
                        child: const Text(
                            ConstStringSinglePlaylistScreen.menuButtonItem2)),
                  ),
                  //new container
                  Container(
                    color: Colors.white,
                    child: CupertinoActionSheetAction(
                        onPressed: () {
                          Navigator.of(context).pop();

                          selectFriendsIOS(
                              context: context,
                              screenHeight: mediaQueryHeight,
                              ref: ref,
                              playlist: widget.playlist);
                        },
                        child: const Text(
                            ConstStringSinglePlaylistScreen.menuButtonItem3)),
                  ),
                ],
                cancelButton: CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                        ConstStringSinglePlaylistScreen.menuButtonCancel)),
              );
            });
      },
      child: Icon(
        constThreeDotsHorizontalMaterialIcon,
        color: Colors.white,
        size: mediaQueryHeight * iconScalingFactor,
      ),
    );
  }
}
