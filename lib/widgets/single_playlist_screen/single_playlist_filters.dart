import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/theme_data.dart';
import '../../providers/single_playlist_view_provider.dart';

class SinglePlaylistFilters extends ConsumerStatefulWidget {
  const SinglePlaylistFilters({super.key});

  @override
  ConsumerState<SinglePlaylistFilters> createState() =>
      _SinglePlaylistFiltersState();
}

class _SinglePlaylistFiltersState extends ConsumerState<SinglePlaylistFilters> {
  // initialise a list of widgets with the content status types
  final List<Widget> contentStatusOptions = <Widget>[
    const Text(
      ConstTipScreen.tipStatusNotStarted,
      style: constSinglePlaylistFilterLight,
      textAlign: TextAlign.center,
    ),
    const Text(
      ConstTipScreen.tipStatusInProgress,
      style: constSinglePlaylistFilterLight,
      textAlign: TextAlign.center,
    ),
    const Text(
      ConstTipScreen.tipStatusFinished,
      style: constSinglePlaylistFilterLight,
      textAlign: TextAlign.center,
    ),
  ];

  // initialise a list of bool filters for the content status options
  List<bool> isSelectedContentStatus = <bool>[false, false, false];

  @override
  Widget build(BuildContext context) {
    final double mediaQueryHeight = MediaQuery.of(context).size.height;
    final double mediaQueryWidth = MediaQuery.of(context).size.width;
    return ToggleButtons(
      borderWidth: mediaQueryWidth * 0.03,
      /*
                    when we press on one of the widgets (i.e. content) in the list this function will receive 
                    the list index in input and update the bool status of the corresponding content
                    */
      onPressed: (int index) {
        setState(() {
          isSelectedContentStatus[index] = !isSelectedContentStatus[index];
          // update the content status filters in the provider
          ref
              .read(contentStatusSinglePlaylistFilterProvider.notifier)
              .setContentStatusFilters(
                isSelectedContentStatus[0],
                isSelectedContentStatus[1],
                isSelectedContentStatus[2],
              );
        });
      },
      // the selection state of each toggle button
      isSelected: isSelectedContentStatus,
      // text color of the selected buttons
      selectedColor: constFilterScreenToggleActiveText,
      // fill color of the selected buttons
      fillColor: constFilterScreenToggleActiveFill,
      // text color when the button is not selected
      color: constFilterScreenToggleInactiveText,
      constraints: BoxConstraints(
        minHeight: mediaQueryHeight * 0.05,
        minWidth: mediaQueryWidth * 0.85 / 3,
        maxWidth: mediaQueryWidth * 0.85 / 3,
      ),
      // the list of widget that are part of the toggle button
      children: contentStatusOptions,
    );
  }
}
