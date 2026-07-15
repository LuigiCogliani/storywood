import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/new_tip_provider.dart';
import './search_result_lists.dart';

import '../../data/theme_data.dart';

class CustomSearchDelegate extends SearchDelegate {
  CustomSearchDelegate({
    required this.contentSelected,
  });

  String? contentSelected;
  Map<String, dynamic> searchVariables({
    required String query,
    required double screenHeight,
    required double screenWidth,
  }) {
    return {
      constContentTypeMovie: ListOfMovieResults(
        query: query,
        screenHeight: screenHeight,
        screenWidth: screenWidth,
      ),
      constContentTypeTv: ListOfTvResults(
        query: query,
        screenHeight: screenHeight,
        screenWidth: screenWidth,
      ),
      constContentTypeBook: ListOfBookResults(
        query: query,
        screenHeight: screenHeight,
        screenWidth: screenWidth,
      ),
      constContentTypePodcast: ListOfPodcastResults(
        query: query,
        screenHeight: screenHeight,
        screenWidth: screenWidth,
      ),
    };
  }

  // customise the action button in the appbar (the one on the right)
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        // the default behaviour is to clear the search box
        onPressed: () {
          query = '';
        },
        icon: Icon(Platform.isIOS
            ? constClearTextFieldCupertinoIcon
            : constClearTextFieldMaterialIcon),
      ),
    ];
  }

  // customise the return button in the appbar (the one on the left)
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Platform.isIOS
          ? constBackButtonCupertinoIcon
          : constBackButtonMaterialIcon),
    );
  }

  // customise the behaviour of the query result (what happens when you click the
  // magnifing glass icon in the floating keyboard)
  @override
  Widget buildResults(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    // map of calls to use depending on the content

    return searchVariables(
        query: query,
        screenHeight: screenHeight,
        screenWidth: screenWidth)[contentSelected];
  }

  // customise the bahaviour of the suggestions shown as you type
  @override
  Widget buildSuggestions(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    // map of calls to use depending on the content

    return searchVariables(
        query: query,
        screenHeight: screenHeight,
        screenWidth: screenWidth)[contentSelected];
  }
}

// label for the title search widget
class TitleSearchText extends ConsumerWidget {
  const TitleSearchText({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text(
      ref.watch(
          queryResultNewTipProvider), //Update this to watch to update searchtext

      style: constBodyLargeLight, overflow: TextOverflow.ellipsis,
    );
  }
}

// title search widget
class TitleSearchAPI extends ConsumerStatefulWidget {
  const TitleSearchAPI({
    super.key,
  });

  @override
  ConsumerState<TitleSearchAPI> createState() => _TitleSearchAPIState();
}

class _TitleSearchAPIState extends ConsumerState<TitleSearchAPI> {
  // initialise the search result as an empty string
  String searchResult = '';
  @override
  Widget build(BuildContext context) {
    // get the selected content from the provider
    String contentSelected = ref.watch(contentTypeSelectionNewTipProvider);
    final double screenWidth = MediaQuery.of(context).size.width;

    return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
            color: constHintColor,
            child: Container(
                margin: EdgeInsets.all(screenWidth * 0.02),
                child: SizedBox(
                  width: double.infinity,
                  child: Platform.isIOS
                      ? CupertinoButton(
                          color: constHintColor,
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.01),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(screenWidth * 0.01),
                                child: Icon(
                                  constContentIcons[contentSelected],
                                  color: constIconColorLight,
                                ),
                              ),
                              const TitleSearchText()
                            ],
                          ),
                          onPressed: () async {
                            String searchResult = await showSearch(
                                context: context,
                                delegate: CustomSearchDelegate(
                                  contentSelected: ref.read(
                                    contentTypeSelectionNewTipProvider,
                                  ),
                                ));
                          })
                      : ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              alignment: Alignment.centerLeft,
                              backgroundColor: constHintColor),
                          onPressed: () async {
                            searchResult = await showSearch(
                                context: context,
                                delegate: CustomSearchDelegate(
                                  contentSelected: ref
                                      .read(contentTypeSelectionNewTipProvider),
                                ));
                          },
                          icon: Icon(
                            constContentIcons[contentSelected],
                            color: constIconColorLight,
                          ),
                          label: const TitleSearchText()),
                ))));
  }
}
