import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/theme_data.dart';
import '../../providers/new_tip_provider.dart';
import '../android_ios_picker.dart';

class MaterialDropdownTipPrivacyStatus extends ConsumerStatefulWidget {
  const MaterialDropdownTipPrivacyStatus({super.key});

  @override
  ConsumerState<MaterialDropdownTipPrivacyStatus> createState() =>
      _MaterialDropdownTipPrivacyStatusState();
}

class _MaterialDropdownTipPrivacyStatusState
    extends ConsumerState<MaterialDropdownTipPrivacyStatus> {
  // the initial value
  String? dropdownValue = ConstNewTipScreen.tipPrivacyStatusDisplayedAllFriends;

  @override
  Widget build(BuildContext context) {
    final double mediaQueryHeight = MediaQuery.of(context).size.height;

    final Map<String, String> tipPrivacyStatusOptions = {
      ConstNewTipScreen.tipPrivacyStatusDisplayedTaggedFriends:
          constTipPrivacyTaggedFriends,
      ConstNewTipScreen.tipPrivacyStatusDisplayedAllFriends:
          constTipPrivacyAllFriends,
      ConstNewTipScreen.tipPrivacyStatusDisplayedPublic: constTipPrivacyPublic
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.0),
      child: DropdownButton<String>(
        isExpanded: false,
        hint: const Padding(
          padding: EdgeInsets.only(right: 10.0),
          child: Text(
            ConstNewTipScreen.tipPrivacyStatusDisplayedTaggedFriends,
            style: constBodyMediumWhite,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // you need to define this dummy container to remove the underline in the dropdown
        underline: Container(),
        dropdownColor: constModalBottomSheetDefaultBackground,
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
                .read(tipPrivacyStatusNewTipProvider.notifier)
                .assignPrivacyStatus(tipPrivacyStatusOptions[value]!);
          });
        },
        items: ConstNewTipScreen.tipPrivacyStatusOptionsDisplayed
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: constBodyMediumWhite,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class CupertinoDropdownTipPrivacyStatus extends ConsumerStatefulWidget {
  const CupertinoDropdownTipPrivacyStatus({super.key});

  @override
  ConsumerState<CupertinoDropdownTipPrivacyStatus> createState() =>
      _CupertinoDropdownTipPrivacyStatusState();
}

class _CupertinoDropdownTipPrivacyStatusState
    extends ConsumerState<CupertinoDropdownTipPrivacyStatus> {
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

  int selectedItemIndex = 1;

  final Map<String, String> tipPrivacyStatusOptions = {
    ConstNewTipScreen.tipPrivacyStatusDisplayedTaggedFriends:
        constTipPrivacyTaggedFriends,
    ConstNewTipScreen.tipPrivacyStatusDisplayedAllFriends:
        constTipPrivacyAllFriends,
    ConstNewTipScreen.tipPrivacyStatusDisplayedPublic: constTipPrivacyPublic
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
                  .read(tipPrivacyStatusNewTipProvider.notifier)
                  .assignPrivacyStatus(tipPrivacyStatusOptions[ConstNewTipScreen
                      .tipPrivacyStatusOptionsDisplayed[selectedItemIndex]]!);
            },
            children: List<Widget>.generate(
                ConstNewTipScreen.tipPrivacyStatusOptionsDisplayed.length,
                (int index) {
              return Center(
                  child: Text(
                ConstNewTipScreen.tipPrivacyStatusOptionsDisplayed[index],
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
              ConstNewTipScreen
                  .tipPrivacyStatusOptionsDisplayed[selectedItemIndex],
              style: constBodyMediumWhite,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 2, 0, 0),
              child: Icon(
                CupertinoIcons.arrowtriangle_down_fill,
                color: constIconColorLight,
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

class TipPrivacyStatusDropdown extends StatelessWidget {
  const TipPrivacyStatusDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return androidIosPicker(
        androidVersion: const MaterialDropdownTipPrivacyStatus(),
        iosVersion: const CupertinoDropdownTipPrivacyStatus());
  }
}
