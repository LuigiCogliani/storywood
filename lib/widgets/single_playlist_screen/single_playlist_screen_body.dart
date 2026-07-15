import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/theme_data.dart';
import '../../models/playlist_class.dart';
import '../../providers/playlist_provider.dart';
import '../../widgets/single_playlist_screen/single_playlist_list.dart';
import '../../widgets/single_playlist_screen/single_playlist_menu_button.dart';
import '../../widgets/single_playlist_screen/single_playlist_filters.dart';

class SinglePlaylistScreenBody extends ConsumerWidget {
  const SinglePlaylistScreenBody(
      {super.key, required this.playlist, required this.myPlaylistInterface});
  final Playlist playlist;
  final bool myPlaylistInterface;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double mediaQueryWidth = MediaQuery.of(context).size.width;
    final mediaQuery = MediaQuery.of(context);
    ref.watch(playlistProvider); //needed to refresh widget if name changed

    Widget? buildMenuButtonCupertino() {
      if (myPlaylistInterface) {
        return CupertinoSinglePlaylistMenuButton(
          playlist: playlist,
        );
      } else {
        return null;
      }
    }

    return Platform.isIOS
        ? CupertinoPageScaffold(
            backgroundColor: constScaffoldBackground,
            navigationBar: CupertinoNavigationBar(
              backgroundColor: constTopBarBackgroundColor,
              middle: Text(
                playlist.name,
                style: constTopBar,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: buildMenuButtonCupertino(),
            ),
            child: SizedBox(
              height: (mediaQuery.size.height - mediaQuery.padding.top) * 0.88,
              child: Material(
                child: Container(
                  color: constScaffoldBackground,
                  child: Column(
                    children: [
                      if (myPlaylistInterface)
                        const SinglePlaylistFilters(), //top row with tip status filters
                      //Expanded is need to display the gridview, otherwise it doesn't work
                      Expanded(
                          child: SinglePlaylistList(
                        playlist: playlist,
                        myPlaylistInterface: myPlaylistInterface,
                      )),
                    ],
                  ),
                ),
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: constTopBarBackgroundColor,
              centerTitle: constIsAppBarTitleNotCentered,
              title: Text(
                playlist.name,
                style: constTopBar,
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                if (myPlaylistInterface)
                  Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: mediaQueryWidth * 0.015),
                      child: AndroidSinglePlaylistPopupMenuButton(
                        playlist: playlist,
                      )),
              ],
            ),
            body: Column(
              children: [
                if (myPlaylistInterface)
                  const SinglePlaylistFilters(), //top row with tip status filters
                //Expanded is need to display the gridview, otherwise it doesn't work
                Expanded(
                    child: SinglePlaylistList(
                  playlist: playlist,
                  myPlaylistInterface: myPlaylistInterface,
                )),
              ],
            ),
          );
  }
}
