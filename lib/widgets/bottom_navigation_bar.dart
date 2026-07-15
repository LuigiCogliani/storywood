import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:irina_storywood_mockup/screens/user_profile_screen.dart';

import '../screens/newsfeed_screen.dart';
import '../screens/new_tip_search_screen.dart';
import '../screens/friends_screen.dart';
import '../screens/playlists_overview_screen.dart';

import '../providers/navigation_bar_provider.dart';
import '../providers/users_provider_riverpod.dart';
import '../data/theme_data.dart';
import './home_button.dart';

/// list of the bottom navigation bar icons (same code for ios and android)
const List<BottomNavigationBarItem> bottomNaviagtionBarItems = [
  BottomNavigationBarItem(
    icon: Icon(ConstBottomNavigationBar.newsfeedScreenIcon),
    label: ConstBottomNavigationBar.newsfeedScreen,
  ),
  BottomNavigationBarItem(
    icon: Icon(ConstBottomNavigationBar.playlistsScreenIcon),
    label: ConstBottomNavigationBar.playlistsScreen,
  ),
  BottomNavigationBarItem(
    icon: Icon(ConstBottomNavigationBar.newTipScreenIcon),
    label: ConstBottomNavigationBar.newTipScreen,
  ),
  BottomNavigationBarItem(
    icon: Icon(ConstBottomNavigationBar.friendsScreenIcon),
    label: ConstBottomNavigationBar.friendsScreen,
  ),
  BottomNavigationBarItem(
    icon: Icon(ConstBottomNavigationBar.userProfileScreenIcon),
    label: ConstBottomNavigationBar.userProfileScreen,
  ),
];

class StorywoodBottomNavigationBar extends ConsumerStatefulWidget {
  const StorywoodBottomNavigationBar({super.key});

  @override
  ConsumerState<StorywoodBottomNavigationBar> createState() =>
      _StorywoodBottomNavigationBarState();
}

class _StorywoodBottomNavigationBarState
    extends ConsumerState<StorywoodBottomNavigationBar> {
  // this is necessary for the code to run, but the provider will override this
  int selectedIndex = 0;

  /// define the navigator as you tap on an icon and update the index
  _onItemTapped(index, context) {
    const bool isNewTipScreen = true;
    final String? userId = ref.read(userInfoProvider)?.userId;
    if (index != ref.watch(bottomNavigationBarIndexProvider)) {
      switch (index) {
        case constHomeScreenBottomNavigationBarIndex:
          Navigator.of(context).pushNamed(
            NewsfeedScreen.routeName,
          );
          break;
        case constPlaylistsBottomNavigationBarIndex:
          resetProviders(ref);
          Navigator.of(context).pushNamed(PlaylistsOverviewScreen.routeName);
          break;
        case constNewTipScreenBottomNavigationBarIndex:
          resetProviders(ref);
          Navigator.of(context).pushNamed(NewTipSearchScreen.routeName,
              arguments: [isNewTipScreen]);
          break;
        case constFriendsScreenBottomNavigationBarIndex:
          Navigator.of(context)
              .pushNamed(FriendsScreen.routeNameYourFriendsTab);
          break;
        case constUserProfileScreenBottomNavigationBarIndex:
          Navigator.of(context).pushNamed(UserProfileScreen.routeName,
              arguments: [true, null, userId]);
          break;
      }
      setState(
        () {
          // update the state
          selectedIndex = index;
        },
      );
      // update the provider (note that you need to update both state and provider for this to work)
      ref
          .read(bottomNavigationBarIndexProvider.notifier)
          .updatebottomNavigationBarIndexNotifier(selectedIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomNavigationBarIndexProvider);
    return BottomNavigationBar(
      // color of the unselected label
      unselectedItemColor: ConstBottomNavigationBar.inactiveColor,
      // theme of the unselected icon
      unselectedIconTheme: ConstBottomNavigationBar.unselectedIconTheme,
      // unselectedLabelStyle is unresponsive
      //unselectedLabelStyle: ConstBottomNavigationBar.unselectedLabelStyle,
      // theme of the selected icon
      selectedIconTheme: ConstBottomNavigationBar.selectedIconTheme,
      showUnselectedLabels: true,
      // selectedLabelStyle is unresponsive
      //selectedLabelStyle: TextStyle(color: Colors.amber),
      selectedFontSize: 14,
      unselectedFontSize: 10,
      // this is necessary to have a fixed BG color
      type: BottomNavigationBarType.fixed,
      //background color of the bar
      backgroundColor: ConstBottomNavigationBar.backgroundColor,
      items: bottomNaviagtionBarItems,
      // label color of the selected item
      selectedItemColor: ConstBottomNavigationBar.activeColor,
      currentIndex: selectedIndex,
      onTap: (int index) {
        _onItemTapped(index, context);
      },
    );
  }
}
