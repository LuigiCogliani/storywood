import 'package:flutter/material.dart';

import '../widgets/bottom_navigation_bar.dart';
import '../widgets/playlists_overview_screen/playlists_overview_grid.dart';
import '../widgets/playlists_overview_screen/playlists_overview_plus_button.dart';
import '../data/theme_data.dart';

class PlaylistsOverviewScreen extends StatelessWidget {
  const PlaylistsOverviewScreen({super.key});
  static const routeName = '/playlists-overview-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: constScaffoldBackground,
        appBar: AppBar(
          backgroundColor: constTopBarBackgroundColor,
          centerTitle: constIsAppBarTitleNotCentered,
          automaticallyImplyLeading: false,
          title: const Text(
            ConstStringPlaylistsScreen.screenTitle,
            style: constTopBar,
          ),
          actions: const [
            PlaylistsOverviewPlusButton(
              iconScalingFactor: 0.04,
            ),
          ],
        ),
        body: const PlaylistsOverviewGrid(),
        bottomNavigationBar: const StorywoodBottomNavigationBar());
  }
}
