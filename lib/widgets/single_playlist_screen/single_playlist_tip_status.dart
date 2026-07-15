import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:irina_storywood_mockup/providers/users_provider_riverpod.dart';

import '../../models/tip_class.dart';
import '../../data/theme_data.dart';
import '../../providers/single_playlist_view_provider.dart';
import '../android_ios_picker.dart';

class MaterialDropdownTipStatus extends ConsumerStatefulWidget {
  const MaterialDropdownTipStatus(
      {super.key, required this.loadedTip, required this.userId});

  final Tip loadedTip;
  final String? userId;

  @override
  ConsumerState<MaterialDropdownTipStatus> createState() =>
      _MaterialDropdownTipStatusState();
}

class _MaterialDropdownTipStatusState
    extends ConsumerState<MaterialDropdownTipStatus> {
  // the initial value needs to be null in order to show the hint (i.e. in our case the word "Movie")
  String? dropdownValue;

  @override
  Widget build(BuildContext context) {
    final double mediaQueryHeight = MediaQuery.of(context).size.height;
    final double mediaQueryWidth = MediaQuery.of(context).size.width;
    final String? userId = ref.read(userInfoProvider)?.userId;
    return Container(
      color: constFriendsScreenTabBackground,
      height: mediaQueryHeight * 0.035,
      width: mediaQueryWidth * 0.27,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3.0),
        child: DropdownButton<String>(
          isExpanded: false,
          hint: Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Text(
              widget.loadedTip.tipStatus!,
              style: constSinglePlaylistStatusButtonCupertino(mediaQueryHeight),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // you need to define this dummy container to remove the underline in the dropdown
          underline: Container(),
          dropdownColor: constFriendsScreenTabBackground,
          value: dropdownValue,
          icon: const Icon(
            constMaterialDropdownIcon,
            color: constIconColorLight,
          ),
          iconSize: mediaQueryHeight * 0.018,
          elevation: 8,
          onChanged: (String? value) {
            // This is called when the user selects an item.
            setState(() {
              dropdownValue = value!;
              ref
                  .read(tipsSinglePlaylistProvider.notifier)
                  .updateTipsContentStatus(widget.loadedTip.contentId,
                      widget.loadedTip.contentType, dropdownValue, userId);
            });
          },
          items: ConstStringSinglePlaylistScreen.tipStatusOptions
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style:
                    constSinglePlaylistStatusButtonCupertino(mediaQueryHeight),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class CupertinoDropdownTipStatus extends ConsumerStatefulWidget {
  const CupertinoDropdownTipStatus(
      {super.key, required this.loadedTip, required this.userId});

  final Tip loadedTip;
  final String? userId;

  @override
  ConsumerState<CupertinoDropdownTipStatus> createState() =>
      _CupertinoDropdownTipStatusState();
}

class _CupertinoDropdownTipStatusState
    extends ConsumerState<CupertinoDropdownTipStatus> {
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

  @override
  Widget build(BuildContext context) {
    selectedItemIndex =
        widget.loadedTip.tipStatus == ConstTipScreen.tipStatusNotStarted
            ? 0
            : widget.loadedTip.tipStatus == ConstTipScreen.tipStatusInProgress
                ? 1
                : 2;

    final double mediaQueryHeight = MediaQuery.of(context).size.height;
    final double mediaQueryWidth = MediaQuery.of(context).size.width;

    // height of the items in the Cupertino menu
    final double kItemExtent = mediaQueryHeight * 0.03;
    final String? userId = ref.read(userInfoProvider)?.userId;

    return SizedBox(
      height: mediaQueryHeight * 0.035,
      child: Align(
        // align drop down menu within its container
        alignment: Alignment.centerRight,
        child: CupertinoButton(
          color: constFriendsScreenTabBackground,
          minSize: mediaQueryWidth * 0.25,
          padding: EdgeInsets.zero,
          // Display a CupertinoPicker with list of fruits.
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
                    .read(tipsSinglePlaylistProvider.notifier)
                    .updateTipsContentStatus(
                        widget.loadedTip.contentId,
                        widget.loadedTip.contentType,
                        ConstStringSinglePlaylistScreen
                            .tipStatusOptions[selectedItem],
                        userId);
              },
              children: List<Widget>.generate(
                  ConstStringSinglePlaylistScreen.tipStatusOptions.length,
                  (int index) {
                return Center(
                    child: Text(
                  ConstStringSinglePlaylistScreen.tipStatusOptions[index],
                  style: constCupertinoDropdownButton,
                ));
              }),
            ),
          ),
          // This displays the selected name.
          child: Text(
            ConstStringSinglePlaylistScreen.tipStatusOptions[selectedItemIndex],
            style: constSinglePlaylistStatusButtonCupertino(mediaQueryHeight),
          ),
        ),
      ),
    );
  }
}

class SinglePlaylistTipStatusDropdown extends StatelessWidget {
  const SinglePlaylistTipStatusDropdown(
      {super.key, required this.loadedTip, required this.userId});

  final Tip loadedTip;
  final String? userId;
  @override
  Widget build(BuildContext context) {
    return androidIosPicker(
        androidVersion: MaterialDropdownTipStatus(
          loadedTip: loadedTip,
          userId: userId,
        ),
        iosVersion: CupertinoDropdownTipStatus(
          loadedTip: loadedTip,
          userId: userId,
        ));
  }
}
