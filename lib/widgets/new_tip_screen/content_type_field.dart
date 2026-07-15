import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/new_tip_provider.dart';

import '../../data/theme_data.dart';
//import './share_with_content_type_buleprint.dart';

class CupertinoContentType extends ConsumerStatefulWidget {
  const CupertinoContentType({super.key});

  @override
  ConsumerState<CupertinoContentType> createState() =>
      _CupertinoContentTypeState();
}

class _CupertinoContentTypeState extends ConsumerState<CupertinoContentType> {
  // the initial value needs to be null in order to show the hint (i.e. in our case the word "Movie")
  String? dropdownValue;

  int selectedItemIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    final double mediaQueryHeight = MediaQuery.of(context).size.height;

    // height of the items in the Cupertino menu
    final double kItemExtent = mediaQueryHeight * 0.03;

    return SizedBox(
      height: mediaQueryHeight * 0.05,
      child: Align(
        // align drop down menu within its container
        alignment: const Alignment(0, 0),
        child: CupertinoButton(
          color: constNewTipScreenWidgets,
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
                dropdownValue =
                    ConstNewTipScreen.contentTypes[selectedItemIndex];
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
              },
              children: List<Widget>.generate(
                  ConstNewTipScreen.contentTypes.length, (int index) {
                return Center(
                    child: Text(
                  ConstNewTipScreen.contentTypes[index],
                  style: constCupertinoDropdownExpanded,
                ));
              }),
            ),
          ),
          // This displays the selected fruit name.
          child: Text(
            ConstNewTipScreen.contentTypes[selectedItemIndex],
            style: constCupertinoDropdownButton,
          ),
        ),
      ),
    );
  }
}

// class DropdownButtonExample extends ConsumerStatefulWidget {
//   const DropdownButtonExample({super.key});

//   @override
//   ConsumerState<DropdownButtonExample> createState() =>
//       _DropdownButtonExampleState();
// }

// class _DropdownButtonExampleState extends ConsumerState<DropdownButtonExample> {
//   // the initial value needs to be null in order to show the hint (i.e. in our case the word "Movie")
//   String? dropdownValue;

//   @override
//   Widget build(BuildContext context) {
//     final double mediaQueryHeight = MediaQuery.of(context).size.height;
//     return SizedBox(
//       height: mediaQueryHeight * 0.07,
//       child: Align(
//         // align drop down menu within its container
//         alignment: const Alignment(0, 0),
//         child: DropdownButton<String>(
//           isExpanded: true,
//           // change the style of the HINT
//           hint: Text(
//             ref.read(contentTypeSelectionNewTipProvider),
//             style: constMaterialDropdownButton,
//           ),
//           // you need to define this dummy container to remove the underline in the dropdown
//           underline: Container(
//             color: constMaterialDropdownButtonUnderline,
//           ),
//           dropdownColor: constNewTipScreenWidgets,
//           value: dropdownValue,
//           icon: const Icon(constMaterialDropdownIcon),
//           elevation: 16,
//           // change the style of SELECTION
//           style: constMaterialDropdownButton,
//           onChanged: (String? value) {
//             // This is called when the user selects an item.
//             setState(() {
//               dropdownValue = value!;
//             });
//             ref
//                 .read(contentTypeSelectionNewTipProvider.notifier)
//                 .assignContentTypeSelection(dropdownValue!);

//             if (dropdownValue == constContentTypeMovie) {
//               ref
//                   .read(queryResultNewTipProvider.notifier)
//                   .assignQueryResult(ConstNewTipScreen.searchForMovies);
//             } else if (dropdownValue == constContentTypeTv) {
//               ref
//                   .read(queryResultNewTipProvider.notifier)
//                   .assignQueryResult(ConstNewTipScreen.searchForTvSeries);
//             } else if (dropdownValue == constContentTypeBook) {
//               ref
//                   .read(queryResultNewTipProvider.notifier)
//                   .assignQueryResult(ConstNewTipScreen.searchForBooks);
//             } else if (dropdownValue == constContentTypePodcast) {
//               ref
//                   .read(queryResultNewTipProvider.notifier)
//                   .assignQueryResult(ConstNewTipScreen.searchForPodcast);
//             }
//           },
//           items: ConstNewTipScreen.contentTypes
//               .map<DropdownMenuItem<String>>((String value) {
//             return DropdownMenuItem<String>(
//               value: value,
//               child: Text(
//                 value,
//                 style: constMaterialDropdownExpanded,
//               ),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
// }

// class ContentType extends StatelessWidget {
//   const ContentType({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return const ShareWithContentTypeBlueprint(
//         androidVersion: DropdownButtonExample(),
//         iosVersion: CupertinoContentType());
//   }
// }
