import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:irina_storywood_mockup/providers/users_provider_riverpod.dart';

import '../../data/theme_data.dart';
import '../../models/playlist_class.dart';
import '../../models/tip_class.dart';
import '../../providers/playlist_provider.dart';
import '../adaptive_circular_loading.dart';
import '../adaptive_alert_dialog_single_button.dart';

class PlaylistsNotAvailableAlertDialog extends StatelessWidget {
  const PlaylistsNotAvailableAlertDialog({
    super.key,
  });
  final String title = 'Oops...';
  final String message =
      'Unfortunately we could not load your collections. Please try again later.';
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

class CupertinoPlaylistSwitch extends ConsumerStatefulWidget {
  const CupertinoPlaylistSwitch(
      {required this.playlistItem,
      required this.tip,
      required this.screenPlaylistId,
      super.key});
  final Playlist playlistItem;
  final Tip tip;
  final String? screenPlaylistId;

  @override
  ConsumerState<CupertinoPlaylistSwitch> createState() =>
      _CupertinoPlaylistSwitchState();
}

class _CupertinoPlaylistSwitchState
    extends ConsumerState<CupertinoPlaylistSwitch> {
  bool _currentValue = false;

  @override
  void initState() {
    // initialise checkbox with the latest tip status
    _currentValue = widget.playlistItem.listOfTipsId.contains(widget.tip.id);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //check below required to see if we are removing tip from playlist
    //in that playlist screen (to make the tip disappear straight away if it's deleted)
    bool removeTipSinglePlaylistProvider =
        widget.playlistItem.id == widget.screenPlaylistId ? true : false;
    // Tip tip = ref.read(tipListProvider.notifier).findById(widget.tipId);
    return Switch.adaptive(
      // This bool value toggles the switch.
      value: _currentValue,
      activeColor: constTipMenuScreenPlaylistCupertinoActiveSwitch,
      inactiveTrackColor: constTipMenuScreenPlaylistCupertinoInactiveSwitch,
      onChanged: (bool? newValue) {
        ref.read(playlistProvider.notifier).updatePlaylistInFirebase(
              playlistId: widget.playlistItem.id,
              tipId: widget.tip.id!,
              checkboxState: newValue!,
              tipImageUrl: widget.tip.imageUrl!,
              ref: ref,
              removeTipSinglePlaylistProvider: removeTipSinglePlaylistProvider,
            );

        setState(() {
          _currentValue = newValue;
        });
      },
    );
  }
}

class CupertinoPlaylistCheckboxTile extends StatelessWidget {
  const CupertinoPlaylistCheckboxTile(
      {required this.playlistItem,
      required this.tip,
      required this.screenPlaylistId,
      super.key});
  final Playlist playlistItem;
  final Tip tip;
  final String? screenPlaylistId;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: constElevatedButtonBackgroundGrey,
      title: Text(
        playlistItem.name,
        style: constBodyMediumDark,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: CupertinoPlaylistSwitch(
        playlistItem: playlistItem,
        tip: tip,
        screenPlaylistId: screenPlaylistId,
      ),
    );
  }
}

class MaterialPlaylistCheckboxTile extends ConsumerStatefulWidget {
  const MaterialPlaylistCheckboxTile(
      {required this.playlistItem,
      required this.tip,
      required this.screenPlaylistId,
      super.key});
  final Playlist playlistItem;
  final Tip tip;
  final String? screenPlaylistId;

  @override
  ConsumerState<MaterialPlaylistCheckboxTile> createState() =>
      _MaterialPlaylistCheckboxTileState();
}

class _MaterialPlaylistCheckboxTileState
    extends ConsumerState<MaterialPlaylistCheckboxTile> {
  // initialise the status of the playlist
  bool _checkPlaylist = false;

  @override
  void initState() {
    // if we are not in the filter screen load the checkbox from firebase
    _checkPlaylist = widget.playlistItem.listOfTipsId.contains(widget.tip.id);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    bool removeTipSinglePlaylistProvider =
        widget.playlistItem.id == widget.screenPlaylistId ? true : false;

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
        ref.read(playlistProvider.notifier).updatePlaylistInFirebase(
              playlistId: widget.playlistItem.id,
              tipId: widget.tip.id!,
              checkboxState: newValue!,
              tipImageUrl: widget.tip.imageUrl!,
              ref: ref,
              removeTipSinglePlaylistProvider: removeTipSinglePlaylistProvider,
            );

        setState(() {
          _checkPlaylist = newValue;
        });
      },
      tileColor: constElevatedButtonBackgroundGrey,
      title: Text(
        widget.playlistItem.name,
        style: constBodyMediumDark,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class MaterialCreateNewPlaylist extends ConsumerStatefulWidget {
  const MaterialCreateNewPlaylist({required this.existingPlaylists, super.key});
  final List existingPlaylists;

  @override
  ConsumerState<MaterialCreateNewPlaylist> createState() =>
      _MaterialCreateNewPlaylistState();
}

class _MaterialCreateNewPlaylistState
    extends ConsumerState<MaterialCreateNewPlaylist> {
  final _controller = TextEditingController();
  var _enteredMessage = '';

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final String? userId = ref.read(userInfoProvider)?.userId;

    return Container(
      color: constElevatedButtonBackgroundGrey,
      child: Column(
        children: [
          Container(
              padding: EdgeInsets.only(
                  left: screenWidth * 0.055,
                  right: screenWidth * 0.045,
                  top: screenHeight * 0.015,
                  bottom: 0),
              alignment: Alignment.centerLeft,
              child: const Text(
                ConstStringSinglePlaylistScreen
                    .bookmarkPopupCreateCollectionTitle,
                style: constBodyMediumDark,
              )),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
                  height: screenHeight * 0.04,
                  margin: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.055,
                      vertical: screenHeight * 0.015),
                  color: constElevatedButtonBackgroundLight,
                  child: TextField(
                    cursorColor: constCursorColorDark,
                    maxLines: 1,
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: ConstStringSinglePlaylistScreen
                          .bookmarkPopupCreateCollectionHint,
                      hintStyle: constMaterialDropdownExpanded,
                    ),
                    style: constBodyMediumDark,
                    onChanged: (value) {
                      setState(() {
                        _enteredMessage = value;
                      });
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: screenWidth * 0.02),
                child: TextButton(
                  onPressed: ((_enteredMessage.trim().isEmpty) ||
                          (widget.existingPlaylists
                              .contains(_enteredMessage.trim())))
                      ? () {
                          showDialog(
                              context: context,
                              builder: (ctx) {
                                return const AdaptiveAlertDialogSingleButton(
                                    title: ConstStringAlertDialog
                                        .newPlaylistErrorTitle,
                                    message: ConstStringAlertDialog
                                        .newPlaylistErrorMessage,
                                    actionMessage:
                                        ConstStringAlertDialog.okayButton);
                              });
                        }
                      : () {
                          FocusScope.of(context).unfocus();
                          ref.read(playlistProvider.notifier).createNewPlaylist(
                              name: _enteredMessage,
                              userId: userId,
                              playlistPrivacyStatus:
                                  ref.read(playlistPrivacyStatusNewTipProvider),
                              ref: ref);
                          _controller.clear();
                          setState(() {
                            _enteredMessage = '';
                          });

                          Navigator.of(context).pop();
                        },
                  child: const Text(
                    ConstStringSinglePlaylistScreen
                        .bookmarkPopupCreateCollectionSave,
                    style: constCupertinoCreateCollectionSaveButton,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class CupertinoCreateNewPlaylist extends ConsumerStatefulWidget {
  const CupertinoCreateNewPlaylist(
      {required this.existingPlaylists, super.key});
  final List existingPlaylists;
  @override
  ConsumerState<CupertinoCreateNewPlaylist> createState() =>
      _CupertinoCreateNewPlaylistState();
}

class _CupertinoCreateNewPlaylistState
    extends ConsumerState<CupertinoCreateNewPlaylist> {
  final _controller = TextEditingController();
  var _enteredMessage = '';
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final String? userId = ref.read(userInfoProvider)?.userId;
    return Column(
      children: [
        Container(
            padding: EdgeInsets.only(
                left: screenWidth * 0.055,
                right: screenWidth * 0.045,
                top: screenHeight * 0.02,
                bottom: screenHeight * 0.01),
            alignment: Alignment.centerLeft,
            child: const Text(
              ConstStringSinglePlaylistScreen
                  .bookmarkPopupCreateCollectionTitle,
              style: constBodyMediumDark,
            )),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: screenWidth * 0.055,
            ),
            Expanded(
              child: CupertinoTextField(
                placeholder: ConstStringSinglePlaylistScreen
                    .bookmarkPopupCreateCollectionHint,
                maxLines: 1,
                cursorColor: constCursorColorDark,
                controller: _controller,
                style: constBodyMediumDark,
                onChanged: (value) {
                  setState(() {
                    _enteredMessage = value;
                  });
                },
              ),
            ),
            CupertinoButton(
              onPressed: ((_enteredMessage.trim().isEmpty) ||
                      (widget.existingPlaylists
                          .contains(_enteredMessage.trim())))
                  ? () {
                      showDialog(
                          context: context,
                          builder: (ctx) {
                            return const AdaptiveAlertDialogSingleButton(
                                title: ConstStringAlertDialog
                                    .newPlaylistErrorTitle,
                                message: ConstStringAlertDialog
                                    .newPlaylistErrorMessage,
                                actionMessage:
                                    ConstStringAlertDialog.okayButton);
                          });
                    }
                  : () {
                      FocusScope.of(context).unfocus();
                      ref.read(playlistProvider.notifier).createNewPlaylist(
                          name: _enteredMessage,
                          userId: userId,
                          playlistPrivacyStatus:
                              ref.read(playlistPrivacyStatusNewTipProvider),
                          ref: ref);
                      _controller.clear();
                      setState(() {
                        _enteredMessage = '';
                      });
                      Navigator.of(context).pop();
                    },
              child: const Text(
                ConstStringSinglePlaylistScreen
                    .bookmarkPopupCreateCollectionSave,
                style: constCupertinoCreateCollectionSaveButton,
              ),
            ),
            SizedBox(
              width: screenWidth * 0.042,
            )
          ],
        ),
      ],
    );
  }
}

class CupertinoPlaylistActions extends ConsumerStatefulWidget {
  const CupertinoPlaylistActions({
    super.key,
    required this.tip,
    required this.screenHeight,
    required this.screenPlaylistId,
  });
  final Tip tip;
  final double screenHeight;
  final String? screenPlaylistId;

  @override
  ConsumerState<CupertinoPlaylistActions> createState() =>
      _CupertinoPlaylistActionsState();
}

class _CupertinoPlaylistActionsState
    extends ConsumerState<CupertinoPlaylistActions> {
  //Define future variable to be used for Future Builder
  var _isInit = true;
  List playlistList = [];
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      playlistList = ref.watch(playlistProvider);
    }
    _isInit = false;
  }

  @override
  Widget build(BuildContext context) {
    final playlistList = ref.watch(playlistProvider);
    double height = playlistList.length * 100 > widget.screenHeight * 0.8
        ? widget.screenHeight * 0.8
        : playlistList.length * 90;
    return Container(
      color: constElevatedButtonBackgroundGrey,
      height: height,
      child: ListView.builder(
        itemCount: playlistList.length,
        itemBuilder: (BuildContext context, int index) {
          final Playlist playlistItem = playlistList[index];

          return CupertinoActionSheetAction(
              onPressed: () {},
              child: Material(
                child: CupertinoPlaylistCheckboxTile(
                  playlistItem: playlistItem,
                  tip: widget.tip,
                  screenPlaylistId: widget.screenPlaylistId,
                ),
              ));
        },
      ),
    );
  }
}

class SinglePlaylistBookmark extends ConsumerStatefulWidget {
  const SinglePlaylistBookmark(
      {super.key,
      required this.tip,
      this.screenPlaylistId,
      required this.iconScalingFactor});

  final Tip tip;
  final String? screenPlaylistId;
  final double iconScalingFactor;

  @override
  ConsumerState<SinglePlaylistBookmark> createState() =>
      _SinglePlaylistBookmarkState();
}

class _SinglePlaylistBookmarkState
    extends ConsumerState<SinglePlaylistBookmark> {
  buildCupertinoModalPopupPullFirebasePlaylists(
      {required context,
      required ref,
      required screenHeight,
      required tip,
      required futureFunction,
      required screenPlaylistId}) {
    List<Playlist> playlistList = ref.watch(playlistProvider);

    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return FutureBuilder<List<Playlist>>(
              future: futureFunction,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return const PlaylistsNotAvailableAlertDialog();
                } else if (snapshot.hasData) {
                  List existingPlaylists = [];
                  // create list of names of existing playlists
                  for (var playlist in playlistList) {
                    existingPlaylists.add(playlist.name);
                  }

                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context)
                            .viewInsets
                            .bottom), //to make sure it moves with the keyboard
                    child: CupertinoActionSheet(
                      actions: [
                        Container(
                          color: constElevatedButtonBackgroundGrey,
                          child: CupertinoActionSheetAction(
                            onPressed: () {},
                            child: const Text(
                              ConstStringSinglePlaylistScreen
                                  .bookmarkPopupTitle,
                              textAlign: TextAlign.start,
                              style: constBodyMediumBoldDark,
                            ),
                          ),
                        ),
                        Container(
                          color: constElevatedButtonBackgroundGrey,
                          child: CupertinoCreateNewPlaylist(
                              existingPlaylists: existingPlaylists),
                        ),
                        CupertinoPlaylistActions(
                          tip: tip,
                          screenHeight: screenHeight,
                          screenPlaylistId: screenPlaylistId,
                        )
                      ],
                      cancelButton: CupertinoActionSheetAction(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            ConstStringFiltersScreen.closePlaylist,
                            style: constBodyMediumDark,
                          )),
                    ),
                  );
                } else {
                  return adaptiveCircularLoading(
                      color: constCircularProgressIndicatorBlack);
                }
              });
        });
  }

  buildMaterialModalBottomSheetPullFirebasePlaylists(
      {required context,
      required ref,
      required screenHeight,
      required tip,
      required futureFunction,
      required screenPlaylistId}) {
    return showModalBottomSheet(
        backgroundColor: constModalBottomSheetDefaultBackground,
        context: context,
        builder: (BuildContext context) {
          //TODO: FutureBuilder is only required if we access not via Collections but via Newsfeed interface
          //adjust accordingly to save backend requests
          return FutureBuilder<List<Playlist>>(
              future: futureFunction,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return const PlaylistsNotAvailableAlertDialog();
                } else if (snapshot.hasData) {
                  List<Playlist> playlistList = snapshot.data;
                  // sort playlists by name
                  playlistList.sort((a, b) => a.name.compareTo(b.name));
                  List existingPlaylists = [];
                  for (var playlist in playlistList) {
                    existingPlaylists.add(playlist.name);
                  }
                  return SizedBox(
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            width: double.infinity,
                            height: 50,
                            color: constElevatedButtonBackgroundGrey,
                            child: const Text(
                              ConstStringSinglePlaylistScreen
                                  .bookmarkPopupTitle,
                              textAlign: TextAlign.start,
                              style: constBodyMediumBoldDark,
                            ),
                          ),
                          const Divider(
                            color: constListDivider,
                            height: 0.5,
                            thickness: 0.5,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom),
                            child: MaterialCreateNewPlaylist(
                                existingPlaylists: existingPlaylists),
                          ),
                          const Divider(
                            color: constListDivider,
                            height: 0.5,
                            thickness: 0.5,
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: playlistList.length,
                              itemBuilder: (BuildContext context, int index) {
                                final Playlist playlistItem =
                                    playlistList[index];

                                return MaterialPlaylistCheckboxTile(
                                  playlistItem: playlistItem,
                                  tip: tip,
                                  screenPlaylistId: screenPlaylistId,
                                );
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

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final String? userId = ref.read(userInfoProvider)?.userId;
    return IconButton(
      onPressed: () {
        Platform.isIOS
            ? buildCupertinoModalPopupPullFirebasePlaylists(
                context: context,
                ref: ref,
                screenHeight: screenHeight,
                tip: widget.tip,
                screenPlaylistId: widget.screenPlaylistId,
                futureFunction: ref
                    .read(playlistProvider.notifier)
                    .fetchPlaylistsFromFirebase(userId))
            : buildMaterialModalBottomSheetPullFirebasePlaylists(
                context: context,
                ref: ref,
                screenHeight: screenHeight,
                tip: widget.tip,
                screenPlaylistId: widget.screenPlaylistId,
                futureFunction: ref
                    .read(playlistProvider.notifier)
                    .fetchPlaylistsFromFirebase(userId));
      },
      icon: Icon(
        Icons.bookmark,
        color: Colors.white,
        size: screenHeight * widget.iconScalingFactor,
      ),
    );
  }
}
