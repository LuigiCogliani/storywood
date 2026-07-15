import 'package:flutter/material.dart';

import '../../data/theme_data.dart';
import './playlists_overview_plus_button.dart';

class PlaylistOverviewNoPlaylistsMessage extends StatelessWidget {
  const PlaylistOverviewNoPlaylistsMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final double mediaQueryHeight = MediaQuery.of(context).size.height;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.all(mediaQueryHeight * 0.03),
          child: Center(
            child: Text(
              ConstStringPlaylistsScreen.errorMessageNoPlaylists,
              style: constSinglePlaylistErrorMessage(mediaQueryHeight),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const Center(
          child: PlaylistsOverviewPlusButton(
            iconScalingFactor: 0.04,
          ),
        ),
      ],
    );
  }
}
