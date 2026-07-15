import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:irina_storywood_mockup/providers/users_provider_riverpod.dart';

import '../data/theme_data.dart';
import '../data/environment.dart';
import '../models/playlist_class.dart';
import './single_playlist_view_provider.dart';
import './notifications_functions.dart';

//TODO: Irina to review and clean up unused code

class PlaylistNotifier extends StateNotifier<List<Playlist>> {
  PlaylistNotifier(state) : super([]);

  /// get the playlist on firebase with the same userID as the logged in user
  Future<List<Playlist>> fetchPlaylistsFromFirebase(String? userId) async {
    // init empty list of playlist
    final List<Playlist> loadedPlaylists = [];

    //fetch from Firebase the playlists shared with the specific userId
    var filteredPlaylists = await FirebaseFirestore.instance
        .collection('${ENVIRONMENT}playlists')
        .where('listOfUsersId', arrayContains: userId)
        .get();

    // fill the local playlist list with the data from firebase
    for (var doc in filteredPlaylists.docs) {
      List<String> listOfUsersIdAsStrings = [];
      for (var sentToString in doc['listOfUsersId']) {
        listOfUsersIdAsStrings.add(sentToString);
      }
      List<String> visibleToAsStrings = [];
      if (doc.data().toString().contains('visibleToUserIds'))
        for (var visibleToString in doc['visibleToUserIds']) {
          visibleToAsStrings.add(visibleToString);
        }

      loadedPlaylists.add(Playlist(
        id: doc.id,
        name: doc['name'],
        createdBy:
            doc.data().toString().contains('createdBy') ? doc['createdBy'] : '',
        listOfTipsId: doc['listOfTipsId'],
        listOfUsersId: doc['listOfUsersId'],
        imageUrl:
            doc.data().toString().contains('imageUrl') ? doc['imageUrl'] : null,
        imageTipId: doc.data().toString().contains('imageTipId')
            ? doc['imageTipId']
            : null,
        playlistPrivacy: doc.data().toString().contains('playlistPrivacy')
            ? doc['playlistPrivacy']
            //if legacy playlist choose privacy based on listOfUsersId length
            : listOfUsersIdAsStrings.length == 1
                ? constPlaylistPrivacyPrivate
                : constPlaylistPrivacyTaggedFriends,
        //check if visibleTo field available
        visibleToUserIds: doc.data().toString().contains('visibleToUserIds')
            ? visibleToAsStrings
            //if legacy tip fill in with sentTo
            : listOfUsersIdAsStrings,
        timeStampCreated: doc.data().toString().contains('timeStampCreated')
            ? doc['timeStampCreated']
            : DateTime.now().toUtc().toString(),
        playlistStatus: doc.data().toString().contains('playlistStatus')
            ? doc['playlistStatus']
            //if legacy playlist choose privacy based on listOfUsersId length
            : listOfUsersIdAsStrings.isEmpty
                ? constPlaylistStatusDeleted
                : constPlaylistStatusActive,
      ));
    }

    // assign the list of playlists to the private property
    /**NOTE this could be the reason of the problem with the new playlist not
     * appearing after being added to the list. Here we were supposed to use the square brackets
     * and the spread operator instead of just assigning the list to the state */

    state = loadedPlaylists;

    return state;
  }

  void updateLocalPlaylistImage(
      String playlistId, String imageUrl, String? imageTipId) {
// get the index of the playlist stored in the cache
    final playlistIndex =
        state.indexWhere((playlist) => playlist.id == playlistId);
    state[playlistIndex].imageUrl = imageUrl;
    state[playlistIndex].imageTipId = imageTipId;
    state = [...state];
  }

  ///Helper function that updates the tip record in Firebase
  //TODO: update local memory tip assignment once we understand how tips will be stored locally
  //TODO: check that removeTipSinglePlaylistProvider is properly set up in the widgets as input
  Future<void> updateTipPlaylistAssignment(
      {required String playlistId,
      required String tipId,
      required bool checkboxState,
      required WidgetRef ref,
      required bool removeTipSinglePlaylistProvider}) async {
    //get Firebase record

    var query =
        await FirebaseFirestore.instance.doc('${ENVIRONMENT}tips/$tipId').get();

    List playlistIdsFromFirebase =
        query.data().toString().contains('playlistIds')
            ? query['playlistIds']
            : [];

    //change status
    if (checkboxState) {
      // add the tip to the list in Firebase
      playlistIdsFromFirebase.add(playlistId);
      //make sure there are no duplicates
      playlistIdsFromFirebase = playlistIdsFromFirebase.toSet().toList();
    } else {
      //check there are no duplicates
      playlistIdsFromFirebase = playlistIdsFromFirebase.toSet().toList();
      //remove the tip on Firebase and from single playlist
      playlistIdsFromFirebase.remove(playlistId);

      //remove from singleplaylist provider local state if required

      if (removeTipSinglePlaylistProvider) {
        ref
            .read(tipsSinglePlaylistProvider.notifier)
            .removeTipFromPlaylistLocal(tipId: tipId);
      }
    }

    //update Firebase record
    FirebaseFirestore.instance.doc('${ENVIRONMENT}tips/$tipId').set({
      'playlistIds': playlistIdsFromFirebase,
    }, SetOptions(merge: true));
  }

  /// updates the playlist in firebase and in the local memory
  Future<List<Playlist>> updatePlaylistInFirebase(
      {required String playlistId,
      required String tipId,
      required bool checkboxState,
      required String tipImageUrl,
      required WidgetRef ref,
      required bool removeTipSinglePlaylistProvider}) async {
    //Execute update tip Firebase record function
    updateTipPlaylistAssignment(
        playlistId: playlistId,
        tipId: tipId,
        checkboxState: checkboxState,
        ref: ref,
        removeTipSinglePlaylistProvider: removeTipSinglePlaylistProvider);
    //get the playlist by playlist ID from Firebase (list of tips, image url, image tipId)
    var query = await FirebaseFirestore.instance
        .doc('${ENVIRONMENT}playlists/$playlistId')
        .get();

    List tipsIdFromFirebase = query['listOfTipsId'];

    String? imageTipId = query.data().toString().contains('imageTipId')
        ? query['imageTipId']
        : null;

    String playlistImageUrl = query.data().toString().contains('imageUrl')
        ? query['imageUrl']
        : constDefaultImageMisingPlaceholder;
    // get the index of the playlist stored in the cache
    final playlistIndex =
        state.indexWhere((playlist) => playlist.id == playlistId);
    // if we selected the check box
    if (checkboxState) {
      // add the tip to the list in firebase
      tipsIdFromFirebase.add(tipId);
      // ensure there are no duplicates
      tipsIdFromFirebase = tipsIdFromFirebase.toSet().toList();

      //check if playlist already has image and if not set it to the tip image
      if (playlistImageUrl == constDefaultImageMisingPlaceholder) {
        playlistImageUrl = tipImageUrl;
        imageTipId = tipId;
        //update local record
        state[playlistIndex].imageUrl = playlistImageUrl;
        state[playlistIndex].imageTipId = imageTipId;
      }
      // add the tip to the list in the cache
      state[playlistIndex].listOfTipsId.add(tipId);
    } else {
      // ensure there are no duplicates
      tipsIdFromFirebase = tipsIdFromFirebase.toSet().toList();
      //remove tip
      tipsIdFromFirebase.remove(tipId);
      state[playlistIndex].listOfTipsId.remove(tipId);

      //check if tip image was used as playlist image
      if (imageTipId == tipId) {
        if (tipsIdFromFirebase.isEmpty) {
          //use default image in no more tips left in the collection
          imageTipId = null;
          playlistImageUrl = constDefaultImageMisingPlaceholder;
        } else {
          //update playlist image to new image from another tip if deleted image was used as cover
          imageTipId = tipsIdFromFirebase.first;
          var queryTip = await FirebaseFirestore.instance
              .doc('${ENVIRONMENT}tips/$imageTipId')
              .get();
          playlistImageUrl = queryTip['imageUrl'];
        }

        //update local playlist image info
        state[playlistIndex].imageUrl = playlistImageUrl;
        state[playlistIndex].imageTipId = imageTipId;
      }
    }

    state = [...state];

    // add the updated list of tipIds and image info
    FirebaseFirestore.instance.doc('${ENVIRONMENT}playlists/$playlistId').set({
      'listOfTipsId': tipsIdFromFirebase,
      'imageUrl': playlistImageUrl,
      'imageTipId': imageTipId,
    }, SetOptions(merge: true));

    return state;
  }

  /// creates a new playlist on firestore
  Future<void> createNewPlaylist(
      {required String name,
      required String? userId,
      required String playlistPrivacyStatus,
      required WidgetRef ref}) {
    List<String>? visibleToUserIds;
    if (playlistPrivacyStatus == constPlaylistPrivacyAllFriends ||
        playlistPrivacyStatus == constPlaylistPrivacyPublic) {
      visibleToUserIds = ref.read(userInfoProvider)?.friendsUserIds ?? [];

      visibleToUserIds.add(userId!);
    } else {
      visibleToUserIds = [userId!];
    }
// send the playlist to Firebase
    return FirebaseFirestore.instance
        .collection('${ENVIRONMENT}playlists')
        .add({
      'name': name,
      'createdBy': userId,
      'listOfTipsId': [],
      'listOfUsersId': [userId],
      'playlistPrivacy': playlistPrivacyStatus,
      'visibleToUserIds': visibleToUserIds,
      'playlistStatus': constPlaylistStatusActive,
      'timeStampCreated': DateTime.now().toUtc().toString()
    }).then((docRef) {
      // once the query is stored use the unique ID to create the new tip locally
      final newPlaylist = Playlist(
        name: name,
        createdBy: userId ?? '',
        listOfTipsId: [],
        listOfUsersId: [userId],
        id: docRef.id,
        playlistPrivacy: playlistPrivacyStatus,
        visibleToUserIds: visibleToUserIds,
        playlistStatus: constPlaylistStatusActive,
        timeStampCreated: DateTime.now().toUtc().toString(),
      );
      // store the new tip locally

      state.add(newPlaylist);
      state = [...state];
    });
  }

  ///Updates playlist name in local memory and on Firebase
  Future<void> updatePlaylistName(
      {required String playlistId, required String newName}) async {
    //update playlist name in local memory
    final playlistIndex =
        state.indexWhere((playlist) => playlist.id == playlistId);

    state[playlistIndex].name = newName;

    state = [...state];

    //update playlist record on Firebase
    FirebaseFirestore.instance.doc('${ENVIRONMENT}playlists/$playlistId').set({
      'name': newName,
    }, SetOptions(merge: true));
  }

  ///Add new users to a playlist
  Future<void> addUsersToPlaylist(
      {required String playlistId,
      required List<String> userIds,
      required String myUserId,
      required WidgetRef ref}) async {
    //find the playlist index based on id
    final playlistIndex =
        state.indexWhere((playlist) => playlist.id == playlistId);
    //get current playlist userIds
    List<dynamic> oldUserIds = state[playlistIndex].listOfUsersId;
    List<String> oldVisibleTo = state[playlistIndex].visibleToUserIds ?? [];

    //add new userIds to old userIds and remove potential duplicates
    List<dynamic> newUserIds = (oldUserIds + userIds).toSet().toList();
    List<String> newVisibleTo = (oldVisibleTo + userIds).toSet().toList();

    //update playlist userIds in local memory
    state[playlistIndex].listOfUsersId = newUserIds;
    state[playlistIndex].visibleToUserIds = newVisibleTo;
    state[playlistIndex].playlistPrivacy = constPlaylistPrivacyTaggedFriends;

    state = [...state];

    //update playlist userIds on Firebase
    FirebaseFirestore.instance.doc('${ENVIRONMENT}playlists/$playlistId').set({
      'listOfUsersId': newUserIds,
      'visibleToUserIds': newVisibleTo,
      'playlistPrivacy': constPlaylistPrivacyTaggedFriends,
    }, SetOptions(merge: true));

    //add  notification to send to collection recepients
    addNewNotification(
        timeStampCreated: DateTime.now().toUtc().toString(),
        tipId: state[playlistIndex].id, //used tipId field to store collectionId
        notificationType: constNotifTypeCollectionShared,
        sentBy: myUserId,
        sentTo: userIds,
        imageUrl:
            state[playlistIndex].imageUrl ?? constDefaultImageMisingPlaceholder,
        ref: ref);
  }

  ///Deletes playlist from local memory and creates Firebase deleted status record
  Future<void> deletePlaylist(
      {required Playlist playlist, required String? userId}) async {
    //update Firebase user preferences record
    await FirebaseFirestore.instance
        .doc(
            '${ENVIRONMENT}userPreferences/$userId/deletedPlaylists/${playlist.id}')
        .set({
      'status': ConstPlaylistStatus.playlistStatusDeleted,
    }, SetOptions(merge: true));

    //update Firebase playlist record
    List<dynamic> playlistUserIds = playlist.listOfUsersId;
    playlistUserIds.remove(userId);
    String playlistStatus = playlist.playlistStatus;
    List<String>? visibleToUserIds = playlist.visibleToUserIds;
    visibleToUserIds?.remove(userId);
    //For playlists shared with friends (tagged) we don't update overall status and visibleTo as it's used by multiple people
    if (playlist.playlistPrivacy != constTipPrivacyTaggedFriends) {
      playlistStatus = constPlaylistStatusDeleted;
      visibleToUserIds = [];
    }
    FirebaseFirestore.instance
        .doc('${ENVIRONMENT}playlists/${playlist.id}')
        .set({
      'listOfUsersId': playlistUserIds,
      'playlistStatus': playlistStatus,
      'visibleToUserIds': visibleToUserIds,
    }, SetOptions(merge: true));

    //TODO: decide if tip records should be adjusted, at the moment tip records will keep playlistId if whole playlist was deleted

    //update playlist in local memory
    state.remove(playlist);
    state = [...state];
  }
}

final playlistProvider =
    StateNotifierProvider<PlaylistNotifier, List<Playlist>>((ref) {
  return PlaylistNotifier([]);
});

class PlaylistFiltersNotifier extends StateNotifier<List<String>> {
  PlaylistFiltersNotifier(state) : super([]);

  /// return a list of tipIds with all the tips in the playlist selected
  List<String> updatePlaylistFilter(
      {required tipIdsToAdd, required checkboxState}) {
// if the playlist is empty do nothing
    if (tipIdsToAdd.length == 0) {
      return state;
    } else {
      // if we selected the check box
      if (checkboxState) {
        // add the tips from the playlist
        state.addAll(List<String>.from(tipIdsToAdd));
      } else {
        // remove the tips from the playlist, use SET to avoid duplicates
        var set1 = Set.from(state);
        var set2 = Set.from(tipIdsToAdd);
        state = List.from(set1.difference(set2));
      }

      return state;
    }
  }

  /// clear the playlist filter, this will show all the tips regardless of playlists
  List clearPlaylistFilter() {
    state = [];
    return state;
  }
}

final playlistFiltersProvider =
    StateNotifierProvider<PlaylistFiltersNotifier, List<String>>((ref) {
  return PlaylistFiltersNotifier([]);
});

/// list of the names of playlist selected to show in the front end
class PlaylistNamesNotifier extends StateNotifier<List> {
  PlaylistNamesNotifier(state) : super([]);

  /// return a list of tipIds with all the tips in the playlist selected
  updateListOfPlaylistNames({required playlistName, required checkboxState}) {
    // if we selected the check box
    if (checkboxState) {
      // add the tips from the playlist
      state.add(playlistName);
    } else {
      state.remove(playlistName);
    }
    state = [...state];
  }

  /// clear the list of names to show in the front end
  clearListOfPlaylistNames() {
    state = [];
  }
}

final playlistNamesProvider =
    StateNotifierProvider<PlaylistNamesNotifier, List>((ref) {
  return PlaylistNamesNotifier([]);
});

class PlaylistCheckboxesStatusNotifier
    extends StateNotifier<Map<String, bool>> {
  // initialise the filters archived status to false
  PlaylistCheckboxesStatusNotifier() : super({});

  void setPlaylistCheckbox(
      {required String playlistId, required bool isChecked}) {
    state[playlistId] = isChecked;
  }

  /// clear all the playlist checkboxes in the front end
  Map clearPlaylistCheckboxes() {
    state = {};
    return state;
  }
}

final playlistCheckboxesStatusProvider =
    StateNotifierProvider<PlaylistCheckboxesStatusNotifier, Map<String, bool>>(
        (ref) {
  return PlaylistCheckboxesStatusNotifier();
});

class TagFriendsPlaylistNotifier extends StateNotifier<List<String>> {
  TagFriendsPlaylistNotifier() : super([]); //initialise data with null string

  /// updates the friends tagged in the tip
  List<String> updateListOfTaggedFriends(
      {required String userId, required bool checkboxState}) {
    // initialise the empty list of tipIds
    List<String> listOfUsers = [...state];

// if we selected the check box
    if (checkboxState) {
      // add user
      listOfUsers.add(userId);
    } else {
      listOfUsers.remove(userId);
    }
    /** If we don't use the spread operator, modifying the list of users an hence updating
     * the state will not trigger a widget rebuild
     */
    state = [...listOfUsers];
    return state;
  }

  /// after sending the tip we need to reset the provider
  void resetProvider() {
    state = [];
  }
}

final tagFriendsPlaylistProvider =
    StateNotifierProvider<TagFriendsPlaylistNotifier, List<String>>((ref) {
  return TagFriendsPlaylistNotifier();
});

/// Support function pulls playlist from Firebase based on playlistId (used in SinglePlaylistScreen)
Future<Playlist> fetchSinglePlaylistFromFirebase(String playlistId) async {
  var docSnapshot = await FirebaseFirestore.instance
      .collection('${ENVIRONMENT}playlists')
      .doc(playlistId)
      .get();

  Playlist playlist = Playlist(
    id: playlistId,
    name: docSnapshot['name'],
    createdBy: docSnapshot.data().toString().contains('createdBy')
        ? docSnapshot['createdBy']
        : '',
    listOfTipsId: docSnapshot['listOfTipsId'],
    listOfUsersId: docSnapshot['listOfUsersId'],
    imageUrl: docSnapshot.data().toString().contains('imageUrl')
        ? docSnapshot['imageUrl']
        : null,
    imageTipId: docSnapshot.data().toString().contains('imageTipId')
        ? docSnapshot['imageTipId']
        : null,
    playlistStatus: docSnapshot.data().toString().contains('playlistStatus')
        ? docSnapshot['playlistStatus']
        //if legacy playlist choose privacy based on listOfUsersId length
        : (docSnapshot['listOfUsersId'] as List<dynamic>).isEmpty
            ? constPlaylistStatusDeleted
            : constPlaylistStatusActive,
    timeStampCreated: docSnapshot.data().toString().contains('timeStampCreated')
        ? docSnapshot['timeStampCreated']
        : DateTime.now().toUtc().toString(),
  );
  return playlist;
}

class PlaylistPrivacyStatusNewTipNotifier extends StateNotifier<String> {
  PlaylistPrivacyStatusNewTipNotifier()
      : super(
            constPlaylistPrivacyPrivate); //initialise data with default value in case not changed
  /// store the comment into a provider
  void assignPrivacyStatus(String playlistPrivayStatusPickedByUser) {
    state = playlistPrivayStatusPickedByUser;
  }
}

final playlistPrivacyStatusNewTipProvider =
    StateNotifierProvider<PlaylistPrivacyStatusNewTipNotifier, String>((ref) {
  return PlaylistPrivacyStatusNewTipNotifier();
});

/// Support function to add userId to visibleTo of all "all friends collections" available to another userId (when adding each other to friends):
void addVisibleToUserIdToPlaylistsCreatedByUserId(
    {required String createdByUserId, required String visibleToUserId}) async {
  print('started function');
  //fetch all tips sent by sentByUserId which are Public of FriendsOnly
  List<Playlist> loadedPlaylists = [];

  var query = await FirebaseFirestore.instance
      .collection('${ENVIRONMENT}playlists')
      .where(Filter.and(
          Filter('createdBy', isEqualTo: createdByUserId),
          Filter('playlistPrivacy', whereIn: [
            constPlaylistPrivacyAllFriends,
            constPlaylistPrivacyPublic
          ])))
      .withConverter<Playlist>(
        fromFirestore: (snapshot, _) => Playlist.fromJson(snapshot.data()!),
        toFirestore: (playlist, _) => playlist.toJson(),
      );

  final querySnapshot = (await query.get());

  for (var doc in querySnapshot.docs) {
    Playlist currentPlaylist = doc.data();

    //add the playlistId
    currentPlaylist.setPlaylistId = doc.id;

    //add the playlist to the output map
    loadedPlaylists.add(currentPlaylist);
  }

  //for each playlist
  for (var playlist in loadedPlaylists) {
    print('updating visible to');
    //update visibleToUserId
    playlist.visibleToUserIds == null
        ? playlist.visibleToUserIds = [visibleToUserId]
        : playlist.visibleToUserIds?.add(visibleToUserId);

    var newVisibleTo = playlist.visibleToUserIds!.toSet().toList();

    //Send updated visibleTo to Firebase
    FirebaseFirestore.instance
        .collection('${ENVIRONMENT}playlists')
        .doc(playlist.id)
        .set({
      'visibleToUserIds': newVisibleTo,
    }, SetOptions(merge: true));
  }
}

/// Support function to add userId to visibleTo of all "all friends collections" available to another userId (when adding each other to friends):
void removeVisibleToUserIdToPlaylistsCreatedByUserId(
    {required String createdByUserId, required String visibleToUserId}) async {
  //fetch all tips sent by sentByUserId which are Public of FriendsOnly
  List<Playlist> loadedPlaylists = [];

  var query = await FirebaseFirestore.instance
      .collection('${ENVIRONMENT}playlists')
      .where(Filter.and(
          Filter('createdBy', isEqualTo: createdByUserId),
          Filter('playlistPrivacy', whereIn: [
            constPlaylistPrivacyAllFriends,
            constPlaylistPrivacyPublic
          ])))
      .withConverter<Playlist>(
        fromFirestore: (snapshot, _) => Playlist.fromJson(snapshot.data()!),
        toFirestore: (playlist, _) => playlist.toJson(),
      );

  final querySnapshot = (await query.get());

  for (var doc in querySnapshot.docs) {
    Playlist currentPlaylist = doc.data();

    //add the playlistId
    currentPlaylist.setPlaylistId = doc.id;

    //add the playlist to the output map
    loadedPlaylists.add(currentPlaylist);
  }

  //for each playlist
  for (var playlist in loadedPlaylists) {
    //update visibleToUserId
    playlist.visibleToUserIds == null
        ? playlist.visibleToUserIds = null
        : playlist.visibleToUserIds?.remove(visibleToUserId);

    var newVisibleTo = playlist.visibleToUserIds!.toSet().toList();

    //Send updated visibleTo to Firebase
    FirebaseFirestore.instance
        .collection('${ENVIRONMENT}playlists')
        .doc(playlist.id)
        .set({
      'visibleToUserIds': newVisibleTo,
    }, SetOptions(merge: true));
  }
}
