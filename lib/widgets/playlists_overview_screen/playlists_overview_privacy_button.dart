import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/theme_data.dart';
import '../../providers/playlist_provider.dart';

class CupertinoDropdownPlaylistPrivacyStatus extends ConsumerStatefulWidget {
  const CupertinoDropdownPlaylistPrivacyStatus({super.key});

  @override
  ConsumerState<CupertinoDropdownPlaylistPrivacyStatus> createState() =>
      _CupertinoDropdownPlaylistPrivacyStatusState();
}

class _CupertinoDropdownPlaylistPrivacyStatusState
    extends ConsumerState<CupertinoDropdownPlaylistPrivacyStatus> {
  // This shows a CupertinoModalPopup with a reasonable fixed height which hosts CupertinoPicker.
  void _showDialog(mediaQueryHeight, Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: mediaQueryHeight * 0.20,
        padding: EdgeInsets.only(top: mediaQueryHeight * 0.01),
        // The Bottom margin is provided to align the popup above the system navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  int selectedItemIndex = 0;

  final Map<String, String> playlistPrivacyStatusOptions = {
    ConstStringPlaylistsScreen.playlistPrivacyStatusDisplayedPrivate:
        constPlaylistPrivacyPrivate,
    ConstStringPlaylistsScreen.playlistPrivacyStatusDisplayedAllFriends:
        constPlaylistPrivacyAllFriends,
    ConstStringPlaylistsScreen.playlistPrivacyStatusDisplayedPublic:
        constPlaylistPrivacyPublic
  };

  @override
  Widget build(BuildContext context) {
    final double mediaQueryHeight = MediaQuery.of(context).size.height;

    // height of the items in the Cupertino menu
    final double kItemExtent = mediaQueryHeight * 0.03;

    return Align(
      // align drop down menu within its container
      alignment: Alignment.center,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        // Display a CupertinoPicker with list of privacy status options.
        onPressed: () => _showDialog(
          mediaQueryHeight,
          CupertinoPicker(
            magnification: 1.22,
            squeeze: 1.2,
            useMagnifier: true,
            itemExtent: kItemExtent,
            // This sets the initial item.
            scrollController: FixedExtentScrollController(
              initialItem: selectedItemIndex,
            ),
            // This is called when selected item is changed.
            onSelectedItemChanged: (int selectedItem) {
              setState(() {
                selectedItemIndex = selectedItem;
              });
              ref
                  .read(playlistPrivacyStatusNewTipProvider.notifier)
                  .assignPrivacyStatus(playlistPrivacyStatusOptions[
                      ConstStringPlaylistsScreen
                              .playlistPrivacyStatusOptionsDisplayed[
                          selectedItemIndex]]!);
            },
            children: List<Widget>.generate(
                ConstStringPlaylistsScreen
                    .playlistPrivacyStatusOptionsDisplayed.length, (int index) {
              return Center(
                  child: Text(
                ConstStringPlaylistsScreen
                    .playlistPrivacyStatusOptionsDisplayed[index],
                style: constCupertinoDropdownButton,
              ));
            }),
          ),
        ),
        // This displays the selected name.
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              ConstStringPlaylistsScreen
                  .playlistPrivacyStatusOptionsDisplayed[selectedItemIndex],
              style: constBodyMediumDark,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 2, 0, 0),
              child: Icon(
                CupertinoIcons.arrowtriangle_down_fill,
                color: constIconColorDark,
                size: mediaQueryHeight * 0.015,
              ),
            )
          ],
        ),
      ),
      // ),
    );
  }
}

class MaterialDropdownPlaylistPrivacyStatus extends ConsumerStatefulWidget {
  const MaterialDropdownPlaylistPrivacyStatus({super.key});

  @override
  ConsumerState<MaterialDropdownPlaylistPrivacyStatus> createState() =>
      _MaterialDropdownPlaylistPrivacyStatusState();
}

class _MaterialDropdownPlaylistPrivacyStatusState
    extends ConsumerState<MaterialDropdownPlaylistPrivacyStatus> {
  // the initial value
  String? dropdownValue =
      ConstStringPlaylistsScreen.playlistPrivacyStatusDisplayedPrivate;

  @override
  Widget build(BuildContext context) {
    final double mediaQueryHeight = MediaQuery.of(context).size.height;

    final Map<String, String> playlistPrivacyStatusOptions = {
      ConstStringPlaylistsScreen.playlistPrivacyStatusDisplayedPrivate:
          constPlaylistPrivacyPrivate,
      ConstStringPlaylistsScreen.playlistPrivacyStatusDisplayedAllFriends:
          constPlaylistPrivacyAllFriends,
      ConstStringPlaylistsScreen.playlistPrivacyStatusDisplayedPublic:
          constPlaylistPrivacyPublic
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.0),
      child: DropdownButton<String>(
        isExpanded: false,
        hint: Padding(
          padding: EdgeInsets.only(right: 10.0),
          child: Text(
            ConstStringPlaylistsScreen.playlistPrivacyStatusDisplayedPrivate,
            style: constNewCollectionInputMediumDark(mediaQueryHeight),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // you need to define this dummy container to remove the underline in the dropdown
        underline: Container(),
        //  dropdownColor: ,
        value: dropdownValue,
        icon: const Icon(
          constMaterialDropdownIcon,
          color: constIconColorDark,
        ),
        iconSize: mediaQueryHeight * 0.018,
        elevation: 8,
        onChanged: (String? value) {
          // This is called when the user selects an item.
          setState(() {
            dropdownValue = value!;
            ref
                .read(playlistPrivacyStatusNewTipProvider.notifier)
                .assignPrivacyStatus(playlistPrivacyStatusOptions[value]!);
          });
        },
        items: ConstStringPlaylistsScreen.playlistPrivacyStatusOptionsDisplayed
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: constNewCollectionInputMediumDark(mediaQueryHeight),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
      ),
    );
  }
}
