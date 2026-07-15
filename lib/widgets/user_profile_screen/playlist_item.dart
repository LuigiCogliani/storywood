import 'package:flutter/material.dart';

import '../../models/playlist_class.dart';
import '../../data/theme_data.dart';
import '../../screens/single_playlist_screen.dart';

class UserProfilePlaylistItem extends StatelessWidget {
  const UserProfilePlaylistItem(
      {super.key, required this.playlist, required this.isMyProfile});
  final Playlist playlist;
  final bool isMyProfile;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(SinglePlaylistScreen.routeName,
            arguments: [playlist.id, playlist, isMyProfile]);
      },
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.all(2),
            child: Image.network(
              playlist.imageUrl ?? constDefaultImageMisingPlaceholder,
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              color: Colors.black.withOpacity(0.8),
              width: double.infinity,
              child: Text(
                playlist.name,
                style: constDisplaySmallWhite,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
