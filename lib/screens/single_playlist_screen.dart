import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/single_playlist_screen/single_playlist_screen_body.dart';
import '../widgets/adaptive_circular_loading.dart';
import '../widgets/adaptive_alert_dialog_single_button.dart';
import '../models/playlist_class.dart';
import '../data/theme_data.dart';
import '../providers/playlist_provider.dart';

class SinglePlaylistScreen extends ConsumerWidget {
  const SinglePlaylistScreen({super.key});
  static const routeName = '/single-playlist-screen';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modalRouteArguments =
        ModalRoute.of(context)!.settings.arguments as List;
    final String playlistId = modalRouteArguments[0].toString();
    final Playlist? playlist = modalRouteArguments[1] as Playlist?;
    final bool myPlaylistInterface = modalRouteArguments[2] as bool;
    Future<Playlist?> future = fetchSinglePlaylistFromFirebase(playlistId);

    return playlist == null
        ? FutureBuilder(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return adaptiveCircularLoading(
                    color: constCircularProgressIndicatorWhite);
              } else {
                if (snapshot.hasError || snapshot.data == null) {
                  return const AdaptiveAlertDialogSingleButton(
                      title: ConstStringSinglePlaylistScreen.loadingError,
                      message: ConstStringSinglePlaylistScreen.errorMessage1,
                      actionMessage: ConstStringAlertDialog.okayButton);
                }
                if (snapshot.hasData && snapshot.data != null) {
                  final Playlist snapshotPlaylist = snapshot.data as Playlist;
                  return SinglePlaylistScreenBody(
                    playlist: snapshotPlaylist,
                    myPlaylistInterface: myPlaylistInterface,
                  );
                }
                return const AdaptiveAlertDialogSingleButton(
                    title: ConstStringSinglePlaylistScreen.loadingError,
                    message: ConstStringSinglePlaylistScreen.errorMessage2,
                    actionMessage: ConstStringAlertDialog.okayButton);
              }
            })
        : SinglePlaylistScreenBody(
            playlist: playlist,
            myPlaylistInterface: myPlaylistInterface,
          );
  }
}
