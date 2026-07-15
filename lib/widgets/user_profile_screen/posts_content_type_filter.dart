import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/theme_data.dart';
import '../../providers/user_profile_screen_providers.dart';

class UserProfilePostsContentTypeFilter extends ConsumerStatefulWidget {
  const UserProfilePostsContentTypeFilter({super.key});

  @override
  ConsumerState<UserProfilePostsContentTypeFilter> createState() =>
      _UserProfilePostsContentTypeFilterState();
}

class _UserProfilePostsContentTypeFilterState
    extends ConsumerState<UserProfilePostsContentTypeFilter> {
// initialise a list of widgets with the content types
  List<Widget> contentTypeOptions = <Widget>[
    const Text(
      constContentTypeMovie,
      style: constChatNewMessageLight,
      textAlign: TextAlign.center,
    ),
    const Text(
      constContentTypeTv,
      style: constChatNewMessageLight,
      textAlign: TextAlign.center,
    ),
    const Text(
      constContentTypePodcast,
      style: constChatNewMessageLight,
      textAlign: TextAlign.center,
    ),
    const Text(
      constContentTypeBook,
      style: constChatNewMessageLight,
      textAlign: TextAlign.center,
    ),
  ];

  List<bool> isSelectedContentType = <bool>[false, false, false, false];

  @override
  void initState() {
    super.initState();

    // initialise a list of bool filters for the content type options
    Map<String, bool> selectedContentTypesMap =
        ref.read(contentTypePostFilterProvider);
    isSelectedContentType = [
      selectedContentTypesMap[constContentTypeMovie]!,
      selectedContentTypesMap[constContentTypeTv]!,
      selectedContentTypesMap[constContentTypePodcast]!,
      selectedContentTypesMap[constContentTypeBook]!
    ];
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      height: screenHeight * 0.04,
      child: ToggleButtons(
        isSelected: isSelectedContentType,
        // text color of the selected buttons
        selectedColor: constFilterScreenToggleActiveText,
        // fill color of the selected buttons
        fillColor: constFilterScreenToggleActiveFill,
        // text color when the button is not selected
        color: constFilterScreenToggleInactiveText,
        constraints: BoxConstraints(
          minHeight: screenHeight * 0.03,
          minWidth: screenWidth * 0.9 / 4,
          maxWidth: screenWidth * 0.9 / 4,
        ),
        onPressed: (int index) {
          setState(() {
            isSelectedContentType[index] = !isSelectedContentType[index];

            // update the content status filters in the provider
            ref
                .read(contentTypePostFilterProvider.notifier)
                .setContentTypeFilters(
                  isSelectedContentType[0],
                  isSelectedContentType[1],
                  isSelectedContentType[2],
                  isSelectedContentType[3],
                );
          });
        },
        children: contentTypeOptions,
      ),
    );
  }
}
