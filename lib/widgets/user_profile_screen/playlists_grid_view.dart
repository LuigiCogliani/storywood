import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/theme_data.dart';
import '../../data/environment.dart';
import '../../models/playlist_class.dart';
import '../../models/user_class.dart' as storywood;
import '../../providers/users_provider_riverpod.dart';
import '../../widgets/android_ios_picker.dart';
import '../../widgets/playlists_overview_screen/playlists_overview_plus_button.dart';
import './playlist_item.dart';

class UserProfilePlaylistsGrid extends ConsumerWidget {
  const UserProfilePlaylistsGrid(
      {super.key, required this.profileUser, required this.isMyProfile});
  final storywood.User profileUser;
  final bool isMyProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
// load current user ID
    String? myUserId = ref.read(userInfoProvider)?.userId;

    String? profileUserId = profileUser.userId;

    final queryMyProfile = FirebaseFirestore.instance
        .collection('${ENVIRONMENT}playlists')
        .where('createdBy', isEqualTo: myUserId)
        .where('playlistStatus', isEqualTo: constPlaylistStatusActive)
        .where('playlistPrivacy', whereIn: [
          constPlaylistPrivacyAllFriends,
          constPlaylistPrivacyPublic,
        ])
        .orderBy('name')
        .withConverter<Playlist>(
          fromFirestore: (snapshot, _) => Playlist.fromJson(snapshot.data()!),
          toFirestore: (tip, _) => tip.toJson(),
        );

    final queryOtherProfile = FirebaseFirestore.instance
        .collection('${ENVIRONMENT}playlists')
        .where('createdBy', isEqualTo: profileUserId)
        .where('playlistStatus', isEqualTo: constPlaylistStatusActive)
        .where(Filter.or(
            Filter('playlistPrivacy', isEqualTo: constPlaylistPrivacyPublic),
            (Filter.and(
                Filter('visibleToUserIds', arrayContains: myUserId),
                Filter('playlistPrivacy',
                    isEqualTo: constTipPrivacyAllFriends)))))
        .orderBy('name')
        .withConverter<Playlist>(
          fromFirestore: (snapshot, _) => Playlist.fromJson(snapshot.data()!),
          toFirestore: (tip, _) => tip.toJson(),
        );
    final Query<Playlist> query;
    if (isMyProfile) {
      query = queryMyProfile;
    } else {
      query = queryOtherProfile;
    }

    return FirestoreQueryBuilder(
        query: query,
        pageSize: 9,
        builder: (context, snapshot, _) {
          if (snapshot.isFetching) {
            return Center(
              child: androidIosPicker(
                  androidVersion: const CircularProgressIndicator(
                    color: constCircularProgressIndicatorWhite,
                  ),
                  iosVersion: const CupertinoActivityIndicator(
                    color: constCircularProgressIndicatorWhite,
                  )),
            );
          }

          if (snapshot.hasError) {
            //  print(snapshot
            //       .error); //uncomment to get the link to create an index for the query
            return const Center(
                child: Text(
                    ConstStringUserProfileScreen
                        .futureBuilderPlaylistsNotLoadingMessage,
                    style: constBodySmallLight));
          }
          List<Playlist> loadedPlaylists = [];

          for (var doc in snapshot.docs) {
            Playlist playlist = doc.data();
            //add the playlistId
            playlist.setPlaylistId = doc.id;
            //add to loadedPlaylists
            loadedPlaylists.add(playlist);
          }
          //TODO:make plus button work
          if (loadedPlaylists.isEmpty && isMyProfile) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    ConstStringUserProfileScreen.noCollectionsToDisplay,
                    style: constBodySmallWhite,
                    textAlign: TextAlign.center,
                  ),
                ),
                // if (Platform.isIOS)
                //   const PlaylistsOverviewPlusButton(iconScalingFactor: 0.04)
              ],
            );
          } else {
            return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  //childAspectRatio: 2 / 2.2, //controls the height of grid items
                ),
                itemCount: loadedPlaylists.length,
                itemBuilder: (context, index) {
                  // if we reached the end of the currently obtained items, we try to
                  // obtain more items

                  if (snapshot.hasMore && index + 1 == loadedPlaylists.length) {
                    // Tell FirestoreQueryBuilder to try to obtain more items.
                    // It is safe to call this function from within the build method.

                    snapshot.fetchMore();
                  }

                  final playlist = loadedPlaylists[index];

                  return UserProfilePlaylistItem(
                    playlist: playlist,
                    isMyProfile: isMyProfile,
                  );
                });
          }
        });
  }
}
