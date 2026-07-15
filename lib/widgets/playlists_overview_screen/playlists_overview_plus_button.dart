import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/theme_data.dart';
import '../../providers/playlist_provider.dart';
import '../../providers/users_provider_riverpod.dart';
import './playlists_overview_privacy_button.dart';

showCreateNewPlaylistDialog(
    {required context,
    required mediaQueryHeight,
    required newPlaylistNameController,
    required WidgetRef ref,
    required userId}) {
  return showDialog(
      context: context,
      builder: (context) => Platform.isIOS
          ? CupertinoAlertDialog(
              title: Padding(
                padding: const EdgeInsets.only(bottom: 18.0),
                child: Text(
                  ConstStringPlaylistsScreen.newPlaylistAlertTitle,
                  style: constNewCollectionAlertTite(mediaQueryHeight),
                ),
              ),
              content: Column(
                children: [
                  CupertinoTextField(
                    autofocus: true,
                    autocorrect: true,
                    placeholder:
                        ConstStringPlaylistsScreen.newPlaylistAlertHintMessage,
                    placeholderStyle:
                        constNewCollectionAlertHintMediumDark(mediaQueryHeight),
                    decoration: const BoxDecoration(
                      color: Colors.white54,
                    ),
                    controller: newPlaylistNameController,
                    style: constNewCollectionInputMediumDark(mediaQueryHeight),
                  ),
                  const CupertinoDropdownPlaylistPrivacyStatus()
                ],
              ),
              actions: [
                CupertinoDialogAction(
                    onPressed: () {
                      Navigator.of(context).pop();
                      newPlaylistNameController.clear();
                    },
                    child: Text(
                        ConstStringPlaylistsScreen.newPlaylistAlertCancel,
                        style: constNewCollectionButtons(mediaQueryHeight))),
                CupertinoDialogAction(
                    isDefaultAction: true,
                    onPressed: () {
                      if (newPlaylistNameController.text.isNotEmpty) {
                        ref.read(playlistProvider.notifier).createNewPlaylist(
                            name: newPlaylistNameController.text,
                            userId: userId,
                            playlistPrivacyStatus:
                                ref.read(playlistPrivacyStatusNewTipProvider),
                            ref: ref);
                      }
                      Navigator.of(context).pop();
                      newPlaylistNameController.clear();
                      ref
                          .read(playlistPrivacyStatusNewTipProvider.notifier)
                          .assignPrivacyStatus(constPlaylistPrivacyPrivate);
                    },
                    child: Text(ConstStringPlaylistsScreen.newPlaylistAlertSave,
                        style: constNewCollectionButtons(mediaQueryHeight))),
              ],
            )
          : AlertDialog(
              title: Text(
                ConstStringPlaylistsScreen.newPlaylistAlertTitle,
                style: constNewCollectionAlertTite(mediaQueryHeight),
              ),
              content: Container(
                height: mediaQueryHeight * 0.2,
                child: Column(
                  children: [
                    TextField(
                      autofocus: true,
                      autocorrect: true,
                      decoration: InputDecoration(
                        hintText: ConstStringPlaylistsScreen
                            .newPlaylistAlertHintMessage,
                        hintStyle: constNewCollectionAlertHintMediumDark(
                            mediaQueryHeight),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      controller: newPlaylistNameController,
                      style:
                          constNewCollectionInputMediumDark(mediaQueryHeight),
                    ),
                    Expanded(child: MaterialDropdownPlaylistPrivacyStatus()),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      if (newPlaylistNameController.text.isNotEmpty) {
                        ref.read(playlistProvider.notifier).createNewPlaylist(
                            name: newPlaylistNameController.text,
                            userId: userId,
                            playlistPrivacyStatus:
                                ref.read(playlistPrivacyStatusNewTipProvider),
                            ref: ref);
                      }
                      Navigator.of(context).pop();
                      newPlaylistNameController.clear();
                      ref
                          .read(playlistPrivacyStatusNewTipProvider.notifier)
                          .assignPrivacyStatus(constPlaylistPrivacyPrivate);
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

class PlaylistsOverviewPlusButton extends ConsumerStatefulWidget {
  const PlaylistsOverviewPlusButton(
      {super.key, required this.iconScalingFactor});

  final double iconScalingFactor;

  @override
  ConsumerState<PlaylistsOverviewPlusButton> createState() =>
      _PlaylistsOverviewPlusButtonState();
}

class _PlaylistsOverviewPlusButtonState
    extends ConsumerState<PlaylistsOverviewPlusButton> {
  late TextEditingController newPlaylistNameController;

  @override
  void initState() {
    super.initState();
    newPlaylistNameController = TextEditingController();
  }

  @override
  void dispose() {
    newPlaylistNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double mediaQueryHeight = MediaQuery.of(context).size.height;
    final double mediaQueryWidth = MediaQuery.of(context).size.width;
    final String? userId = ref.read(userInfoProvider)?.userId;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: mediaQueryWidth * 0.015),
      child: IconButton(
          onPressed: () => showCreateNewPlaylistDialog(
              context: context,
              mediaQueryHeight: mediaQueryHeight,
              newPlaylistNameController: newPlaylistNameController,
              ref: ref,
              userId: userId),
          icon: Icon(
            constAddMaterialIcon,
            color: constIconColorLight,
            size: mediaQueryHeight * widget.iconScalingFactor,
          )),
    );
  }
}
