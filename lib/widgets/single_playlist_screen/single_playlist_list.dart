import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:irina_storywood_mockup/providers/users_provider_riverpod.dart';

import '../../providers/single_playlist_view_provider.dart';
import './single_playlist_item.dart';
import '../../data/theme_data.dart';

import '../../models/playlist_class.dart';
import '../../models/tip_class.dart';
import './single_playlist_error_no_tips.dart';
import '../adaptive_circular_loading.dart';

class SinglePlaylistList extends ConsumerStatefulWidget {
  const SinglePlaylistList(
      {super.key, required this.playlist, required this.myPlaylistInterface});
  final Playlist playlist;
  final bool myPlaylistInterface;

  @override
  ConsumerState<SinglePlaylistList> createState() => _SinglePlaylistListState();
}

class _SinglePlaylistListState extends ConsumerState<SinglePlaylistList> {
  //Define future variable to be used for Future Builder
  var _isInit = true;
  Future<dynamic>? fetchPlaylistTipsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInit) {
      //clean up old provider values
      ref.invalidate(contentStatusSinglePlaylistFilterProvider);
      ref.invalidate(filteredTipsSinglePlaylistProvider);
      String? userId = ref.read(userInfoProvider)?.userId;
      fetchPlaylistTipsFuture = ref
          .read(tipsSinglePlaylistProvider.notifier)
          .fetchPlaylistTipsFromFirebase(widget.playlist, userId);
    }
    _isInit = false;
  }

  @override
  Widget build(BuildContext context) {
    final List<Tip> displayedTips =
        ref.watch(filteredTipsSinglePlaylistProvider);
    final String? userId = ref.read(userInfoProvider)?.userId;
    return RefreshIndicator(
      color: Colors.black,
      onRefresh: () => ref
          .read(tipsSinglePlaylistProvider.notifier)
          .fetchPlaylistTipsFromFirebase(widget.playlist, userId),
      child: FutureBuilder(
          future: fetchPlaylistTipsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return adaptiveCircularLoading(
                  color: constCircularProgressIndicatorWhite);
            } else if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                if (widget.myPlaylistInterface) {
                  return const SinglePlaylistErrorNoTips();
                } else {
                  return Container();
                }
              } else {
                if (displayedTips.isEmpty &&
                    //check that no tips is not caused by filter application
                    !ref
                        .read(contentStatusSinglePlaylistFilterProvider)
                        .containsValue(true)) {
                  if (widget.myPlaylistInterface) {
                    return const SinglePlaylistErrorNoTips();
                  } else {
                    return Container();
                  }
                } else {
                  displayedTips.sort((a, b) => a.timeStampLastUpdated!
                      .compareTo(b.timeStampLastUpdated!));
                  //show from latest to oldest
                  final reversedDisplayedTips = displayedTips.reversed.toList();

                  return ListView.builder(
                    itemBuilder: (context, index) {
                      return SinglePlaylistItem(
                        tip: reversedDisplayedTips[index],
                        playlist: widget.playlist,
                        myPlaylistInterface: widget.myPlaylistInterface,
                      );
                    },
                    itemCount: reversedDisplayedTips.length,
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
          }),
    );
  }
}
