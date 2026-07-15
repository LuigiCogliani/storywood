import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';

import '../../providers/users_provider_riverpod.dart';
import './search_result_item.dart';
import '../../data/theme_data.dart';
import '../../widgets/android_ios_picker.dart';

class UsersSearchResults extends ConsumerWidget {
  const UsersSearchResults({super.key, this.searchInput});

  final String? searchInput;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (searchInput == '') {
      return Container();
    } else {
      return FutureBuilder(
          future: ref
              .read(userSearchByUsernameProvider.notifier)
              .getUsersByUsername(searchInput),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                  child: Container(
                margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.1),
                child: const Text(
                  textAlign: TextAlign.center,
                  ConstStringFriendsScreen.userSearchErrorMessage,
                  style: constDisplayMediumGrey,
                ),
              ));
            } else if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.1),
                    child: const Text(
                        textAlign: TextAlign.center,
                        ConstStringFriendsScreen.userNotFoundMessage,
                        style: constDisplayMediumGrey),
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return UsersSearchListItem(
                      user: snapshot.data![index],
                    );
                  },
                ); // add list view builder here
              }
            } else {
              return Center(
                child: androidIosPicker(
                    androidVersion: const CircularProgressIndicator(
                      color: constCircularProgressIndicatorWhite,
                    ),
                    iosVersion: const CupertinoActivityIndicator(
                      color: constCircularProgressIndicatorWhite,
                    )),
              );
            } // add loading here,
          });
    }
  }
}

class UsersSearchDelegate extends SearchDelegate {
  // customise the action button in the appbar (the one on the right)
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        // the default behaviour is to clear the search box
        onPressed: () {
          query = '';
        },
        icon: const Icon(constClearTextFieldCupertinoIcon),
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
      icon: const Icon(constBackButtonMaterialIcon),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // map of calls to use depending on the content

    return UsersSearchResults(
      searchInput: query,
    );
  }

  // customise the bahaviour of the suggestions shown as you type
  @override
  Widget buildSuggestions(BuildContext context) {
    // map of calls to use depending on the content

    return UsersSearchResults(
      searchInput: query,
    );
  }
}
