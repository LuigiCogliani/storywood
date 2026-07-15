import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:irina_storywood_mockup/providers/users_provider_riverpod.dart';

import '../../providers/playlist_provider.dart';
import './playlists_overview_item.dart';
import './playlists_overview_no_playlists.dart';
import '../../data/theme_data.dart';

class PlaylistsOverviewGrid extends ConsumerStatefulWidget {
  const PlaylistsOverviewGrid({super.key});

  @override
  ConsumerState<PlaylistsOverviewGrid> createState() =>
      _PlaylistsOverviewGridState();
}

class _PlaylistsOverviewGridState extends ConsumerState<PlaylistsOverviewGrid> {
  //Define future variable to be used for Future Builder
  var _isInit = true;

  Future<dynamic>? fetchPlaylistsFuture;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      String? userId = ref.read(userInfoProvider)?.userId;
      fetchPlaylistsFuture = ref
          .read(playlistProvider.notifier)
          .fetchPlaylistsFromFirebase(userId);
    }
    _isInit = false;
  }

  @override
  Widget build(BuildContext context) {
    final displayedPlaylists = ref.watch(playlistProvider);

    return FutureBuilder(
        future: fetchPlaylistsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Platform.isIOS
                  ? const CupertinoActivityIndicator(
                      color: constCircularProgressIndicatorWhite,
                    )
                  : const CircularProgressIndicator(
                      color: constCircularProgressIndicatorWhite,
                    ),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const PlaylistOverviewNoPlaylistsMessage();
            } else {
              if (displayedPlaylists.isEmpty) {
                return const PlaylistOverviewNoPlaylistsMessage();
              } else {
                //sort playlists alphabetically by name
                displayedPlaylists.sort((a, b) =>
                    a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio:
                        2 / 2.2, //controls the height of grid items
                  ),
                  itemBuilder: (context, index) {
                    return PlaylistsOverviewItem(
                        playlist: displayedPlaylists[index]);
                  },
                  itemCount: displayedPlaylists.length,
                );
              }
            }
          } else {
            return Center(
              child: Text(
                'State: ${snapshot.connectionState}',
                style: constBodySmallLight,
              ),
            );
          }
        });
  }
}
