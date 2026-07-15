import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/friends_screen/friends_list.dart';
import '../widgets/friends_screen/requests_list.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/friends_screen/search_users.dart';
import '../data/theme_data.dart';
import '../providers/users_provider_riverpod.dart';

class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key, required this.selectedPage});

  // allows us to navigate between tabs
  static const routeNameYourFriendsTab = '/friends-screen-your-friends-tab';
  static const routeNameRequestsTab = '/friends-screen-requests-tab';
  final int selectedPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double mediaQueryHeight = MediaQuery.of(context).size.height;
    final List<String>? friendRequests =
        ref.watch(userInfoProvider)!.friendRequestsUserIds;
    int friendRequestsNumber;
    String requestsTabName;
    if (friendRequests == null) {
      friendRequestsNumber = 0;
    } else {
      friendRequestsNumber = friendRequests.length;
    }
    if (friendRequestsNumber == 0) {
      requestsTabName = ConstStringFriendsScreen.requestsTabLabel;
    } else {
      requestsTabName =
          '${ConstStringFriendsScreen.requestsTabLabel} ($friendRequestsNumber)';
    }

    return DefaultTabController(
        initialIndex: selectedPage,
        length: 2,
        child: Scaffold(
            backgroundColor: constScaffoldBackground,
            appBar: AppBar(
              backgroundColor: constTopBarBackgroundColor,
              centerTitle: constIsAppBarTitleNotCentered,
              automaticallyImplyLeading: false,
              title: const Text(
                ConstStringFriendsScreen.screenTitle,
                style: constTopBar,
              ),
              actions: <Widget>[
                IconButton(
                  onPressed: () async {
                    await showSearch(
                        context: context, delegate: UsersSearchDelegate());
                  },
                  icon: Icon(
                    constSearchMaterialIcon,
                    color: constIconColorLight,
                    size: mediaQueryHeight * 0.04,
                  ),
                ),
              ],
              bottom: TabBar(
                  dividerColor: constScaffoldBackground,
                  indicatorColor: Colors.white,
                  // indicatorPadding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  // indicatorSize: TabBarIndicatorSize.label,
                  // indicator: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(5),
                  //     color: constCupertinoSlidingSegmentedControlThumb),
                  tabs: [
                    Tab(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Align(
                          alignment: Alignment.center,
                          child: Text(
                            ConstStringFriendsScreen.yourFriendsTabLabel,
                            style: constBodyMediumWhite,
                          ),
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            requestsTabName,
                            style: constBodyMediumWhite,
                          ),
                        ),
                      ),
                    ),
                  ]),
            ),
            body: const TabBarView(
              children: [
                FriendsList(),
                RequestsList(),
              ],
            ),
            bottomNavigationBar: const StorywoodBottomNavigationBar()));
  }
}
