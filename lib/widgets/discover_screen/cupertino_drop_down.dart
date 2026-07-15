import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/new_tip_provider.dart';

import '../../data/theme_data.dart';

/// mid-Jul 2023: required in the current new tip screen and discovery screen
class CupertinoContentType extends ConsumerStatefulWidget {
  const CupertinoContentType({super.key});

  @override
  ConsumerState<CupertinoContentType> createState() =>
      _CupertinoContentTypeState();
}

class _CupertinoContentTypeState extends ConsumerState<CupertinoContentType> {
  // the initial value needs to be null in order to show the hint (i.e. in our case the word "Movie")
  String? dropdownValue;
  int? _sliding = 0;
  int selectedItemIndex = 0;

  // This shows a CupertinoModalPopup with a reasonable fixed height which hosts CupertinoPicker.
  // void _showDialog(mediaQueryHeight, Widget child) {
  //   showCupertinoModalPopup<void>(
  //     context: context,
  //     builder: (BuildContext context) => Container(
  //       height: mediaQueryHeight * 0.20,
  //       padding: EdgeInsets.only(top: mediaQueryHeight * 0.01),
  //       // The Bottom margin is provided to align the popup above the system navigation bar.
  //       margin: EdgeInsets.only(
  //         bottom: MediaQuery.of(context).viewInsets.bottom,
  //       ),
  //       // Provide a background color for the popup.
  //       color: CupertinoColors.systemBackground.resolveFrom(context),
  //       // Use a SafeArea widget to avoid system overlaps.
  //       child: SafeArea(
  //         top: false,
  //         child: child,
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final double mediaQueryHeight = MediaQuery.of(context).size.height;

    // height of the items in the Cupertino menu
    final double kItemExtent = mediaQueryHeight * 0.03;

    Widget buildSegment(int index) {
      return Text(
        ConstNewTipScreen.contentTypes[index],
        style: constCupertinoSegmentedControl,
      );
    }

    return CupertinoSlidingSegmentedControl(
        // color of the idget background
        backgroundColor: constHintColor,
        // color of the highlithed section
        thumbColor: constCupertinoSlidingSegmentedControlThumb,
        children: {
          0: buildSegment(0),
          1: buildSegment(1),
          2: buildSegment(2),
          3: buildSegment(3),
        },
        groupValue: _sliding,
        onValueChanged: (int? newValue) {
          setState(() {
            _sliding = newValue;
          });
          dropdownValue = ConstNewTipScreen.contentTypes[_sliding!];
          ref
              .read(contentTypeSelectionNewTipProvider.notifier)
              .assignContentTypeSelection(dropdownValue!);

          if (dropdownValue == constContentTypeMovie) {
            ref
                .read(queryResultNewTipProvider.notifier)
                .assignQueryResult(ConstNewTipScreen.searchForMovies);
          } else if (dropdownValue == constContentTypeTv) {
            ref
                .read(queryResultNewTipProvider.notifier)
                .assignQueryResult(ConstNewTipScreen.searchForTvSeries);
          } else if (dropdownValue == constContentTypeBook) {
            ref
                .read(queryResultNewTipProvider.notifier)
                .assignQueryResult(ConstNewTipScreen.searchForBooks);
          } else if (dropdownValue == constContentTypePodcast) {
            ref
                .read(queryResultNewTipProvider.notifier)
                .assignQueryResult(ConstNewTipScreen.searchForPodcast);
          }
        });

    // CupertinoButton(
    //   color: constNewTipScreenWidgets,
    //   padding: EdgeInsets.zero,
    //   // Display a CupertinoPicker with list of fruits.
    //   onPressed: () => _showDialog(
    //     mediaQueryHeight,
    //     CupertinoPicker(
    //       magnification: 1.22,
    //       squeeze: 1.2,
    //       useMagnifier: true,
    //       itemExtent: kItemExtent,
    //       // This sets the initial item.
    //       scrollController: FixedExtentScrollController(
    //         initialItem: selectedItemIndex,
    //       ),
    //       // This is called when selected item is changed.
    //       onSelectedItemChanged: (int selectedItem) {
    //         setState(() {
    //           selectedItemIndex = selectedItem;
    //         });
    //         dropdownValue = ConstNewTipScreen.contentTypes[selectedItemIndex];
    //         ref
    //             .read(contentTypeSelectionNewTipProvider.notifier)
    //             .assignContentTypeSelection(dropdownValue!);

    //         if (dropdownValue == constContentTypeMovie) {
    //           ref
    //               .read(queryResultNewTipProvider.notifier)
    //               .assignQueryResult(ConstNewTipScreen.searchForMovies);
    //         } else if (dropdownValue == constContentTypeTv) {
    //           ref
    //               .read(queryResultNewTipProvider.notifier)
    //               .assignQueryResult(ConstNewTipScreen.searchForTvSeries);
    //         } else if (dropdownValue == constContentTypeBook) {
    //           ref
    //               .read(queryResultNewTipProvider.notifier)
    //               .assignQueryResult(ConstNewTipScreen.searchForBooks);
    //         } else if (dropdownValue == constContentTypePodcast) {
    //           ref
    //               .read(queryResultNewTipProvider.notifier)
    //               .assignQueryResult(ConstNewTipScreen.searchForPodcast);
    //         }
    //       },
    //       children: List<Widget>.generate(ConstNewTipScreen.contentTypes.length,
    //           (int index) {
    //         return Center(
    //             child: Text(
    //           ConstNewTipScreen.contentTypes[index],
    //           style: constCupertinoDropdownExpanded,
    //         ));
    //       }),
    //     ),
    //   ),
    //   // This displays the selected fruit name.
    //   child: Text(
    //     ConstNewTipScreen.contentTypes[selectedItemIndex],
    //     style: constCupertinoDropdownButton,
    //   ),
    // );
  }
}
