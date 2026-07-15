import 'package:flutter/material.dart';

import '../../data/theme_data.dart';
import '../../models/playlist_class.dart';
import '../../screens/single_playlist_screen.dart';
import '../../widgets/choose_thumbs_icon.dart';

class PlaylistsOverviewItem extends StatelessWidget {
  const PlaylistsOverviewItem({super.key, required this.playlist});
  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    final double mediaQueryHeight = MediaQuery.of(context).size.height;
    final double mediaQueryWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(
          SinglePlaylistScreen.routeName,
          arguments: [playlist.id, playlist, true],
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: mediaQueryWidth * 0.015,
          vertical: mediaQueryHeight * 0.016,
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(mediaQueryHeight * 0.008),
              child: Stack(children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(mediaQueryHeight * 0.018),
                  ),
                  child: Image.network(
                    playlist.imageUrl ?? constDefaultImageMisingPlaceholder,
                    height: mediaQueryHeight * 0.175,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, mediaQueryHeight * 0.008,
                        mediaQueryHeight * 0.01, 0),
                    child: ChoosePlayistPrivacyIcon(
                      playlistPrivacy: playlist.playlistPrivacy!,
                      iconSize: mediaQueryHeight * 0.03,
                    ),
                  ),
                )
              ]),
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: mediaQueryHeight * 0.008),
              child: Text(
                playlist.name,
                style: constPlaylistGridTextLight(mediaQueryHeight),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
