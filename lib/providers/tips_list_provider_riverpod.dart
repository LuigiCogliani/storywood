import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/utils.dart';

import '../data/environment.dart';

import '../models/tip_class.dart';
import './notifications_functions.dart';

import '../screens/content_screen.dart';
import '../data/theme_data.dart';

//TODO: Luigi to review and clean up unused code

class TipsListNotifier extends StateNotifier<List<Tip>> {
  TipsListNotifier(state) : super([]);

  ///Generates a positive random integer uniformly distributed on the range
  ///from [min], inclusive, to [max], exclusive.
  int next({required int min, required int max}) =>
      min + Random().nextInt(max - min);

  /// For movies and tv series we need a "landscape" image.
  /// Since we cannot pull them via futurebuilder in newsfeed screen
  /// (we use pagination now, which doesn't allow to use a future builder
  /// inside it) we need to store them in the tip.
  /// If there are no images in tmdb but only posters, we need to return an empty map
  Future<Map> createInfoObjectForMoviesAndTv(
      {required String contentType,
      required String storywoodContentId,
      required Map info}) async {
    if (contentType == constContentTypeMovie ||
        contentType == constContentTypeTv) {
      // initialise empty List for the image Url
      List<String> imageUrls = [];
      // initialise an empty map (we cannot modify the 'info' we receive in input)
      Map infoNew = {};
      // get all the images
      final snapshot = await FirebaseFirestore.instance
          .doc('${ENVIRONMENT}content$contentType/$storywoodContentId')
          .get();

      final Map content = snapshot.data()!['images'];
      // see if we have backdrops
      try {
// assign two backdrops
        for (var i = 0; i < 2; i++) {
          final String background = content['backdrops']
              [next(min: 0, max: content['backdrops'].length)];
          imageUrls.add(background);
        }

// assign one logo (try catch) assign one more backdrop
        try {
          final String logo =
              content['logos'][next(min: 0, max: content['logos'].length)];
          imageUrls.add(logo);
        } catch (noLogosError) {
          final String background3 = content['backdrops']
              [next(min: 0, max: content['backdrops'].length)];
          imageUrls.add(background3);
        }
      } catch (noBackdropsError) {
        try {
          //assign 3 logos
          for (var i = 0; i < 3; i++) {
            final String logo =
                content['logos'][next(min: 0, max: content['logos'].length)];
            imageUrls.add(logo);
          }
        } catch (noLogosError) {
          // do nothing
        }
      }
      // if there were no images
      if (imageUrls.isEmpty) {
        /**assign an empty map. THis means that when we load the tip we will
       * default to the poster
       */
        return {};
      } else {
        infoNew['images'] = imageUrls;

        return infoNew;
      }
    } else {
      // if it's a book or a podcast, return info unchanged
      return info;
    }
  }

  /// Add new tip to both firebase and front end.
  /// NOTE if updating this function remember to also update the function in the
  /// auth screen that sends the welcome tips
  Future<String> addNewTip({
    required String txTitle,
    required String comment,
    required List<String> sentTo,
    required List<String> visibleTo,
    required String contentType,
    required String tipType,
    required String imageUrl,
    required String contentId,
    required Map<dynamic, dynamic> info,
    required String storywoodContentId,
    required String tipPrivacy,
    List<String>? playlistIds,
    required WidgetRef ref,
  }) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    // initialise the timestampe in utc (as string)
    final dateCreated = DateTime.now().toUtc().toString();
    //keep only unique users
    List<String> sendToSelectedBuffer = sentTo.toSet().toList();
    List<String> visibleToUnique = visibleTo.toSet().toList();
    /**
       * NOTE: this code snippet is also in tip_menu_screen, future builder, when we load a legacy tip
       * (i.e. a tip that has no votes in Firebase)
       */
    // inititliase the uservotes default values
    Map<String, bool> userVotesDefault = {'isCastVote': false, 'isPoop': false};
    // initialise the user votes
    Map<String, Map<String, bool>> userVotes = Map.fromIterable(
        sendToSelectedBuffer,
        key: (e) => e,
        value: (e) => userVotesDefault);
    // add the sender vote
    userVotes[userId!] = {
      'isCastVote': true,
      // if the tipType is a recommendation than isPoop must be false
      'isPoop':
          tipType == ConstNewTipScreen.tipTypeRecommendation ? false : true
    };
    /**
     * end code snippet. NOTE: we cannot just add it into a function because the next line of code requires
     * userVotes, defined here, but the second part of the replicated code requires the tipId, which is not
     * available until we send the tip to firebase
     */

    final Map infoForFirebase = await createInfoObjectForMoviesAndTv(
        contentType: contentType,
        storywoodContentId: storywoodContentId,
        info: info);

    // send the tip to Firebase
    DocumentReference<Map<String, dynamic>> docRef =
        await FirebaseFirestore.instance.collection('${ENVIRONMENT}tips').add({
      'title': txTitle,
      'originalComment': comment,
      'imageUrl': imageUrl,
      'contentType': contentType,
      'tipType': tipType,
      'sentBy': userId,
      'sentTo': sendToSelectedBuffer,
      'timeStampCreated': dateCreated,
      'contentId': contentId,
      'timeStampLastUpdated': dateCreated,
      'info': infoForFirebase,
      'playlistIds': playlistIds ?? [],
      'storywoodContentId': storywoodContentId,
      'tipPrivacy': tipPrivacy,
      'visibleTo': visibleToUnique,
    });

    ///function to execute the rest after docRef future result comes back
    addOtherItems(DocumentReference<Map<String, dynamic>> docRef) async {
      // once the query is stored use the unique ID to create the new tip locally
      final newTip = Tip(
          title: txTitle,
          originalComment: comment,
          imageUrl: imageUrl,
          id: docRef.id,
          contentType: contentType,
          tipType: tipType,
          sentBy: userId!,
          sentTo: sendToSelectedBuffer,
          timeStampCreated: dateCreated,
          tipStatus: ConstTipScreen.tipStatusNotStarted,
          contentId: contentId,
          timeStampLastUpdated: dateCreated,
          isArchived: false,
          isMuted: false,
          info: infoForFirebase,
          userVotes: userVotes);
      // store the new tip locally
      state.add(newTip);

      var _tipId = docRef.id.toString();

      // Record original comment as first chat message in the chat collection on Firebase

      FirebaseFirestore.instance
          .collection('${ENVIRONMENT}chats/$_tipId/messages')
          .add({
        'text': comment,
        'createdAt': DateTime.now().toUtc().toString(),
        'userId': userId,
      });
      /**
       * NOTE: this for loop is also in tip_menu_screen, future builder, when we load a legacy tip
       * (i.e. a tip that has no votes in Firebase)
       */
      // add the original tip type as vote on firebase
      for (var user in userVotes.keys) {
        // if the sender already sent the tip then overwrite the vote
        var votesToSet = userVotes[user]!;
        FirebaseFirestore.instance
            .collection('${ENVIRONMENT}userVotes/$contentType$contentId/$user')
            .doc(_tipId)
            .set(votesToSet);
      }

      //Call the function to create a notification message
      addNewNotification(
          timeStampCreated: DateTime.now().toUtc().toString(),
          tipId: docRef.id,
          notificationType: constNotifTypeNewTip,
          sentBy: userId ?? '',
          sentTo: tipPrivacy == constTipPrivacyTaggedFriends
              ? sendToSelectedBuffer
              : visibleToUnique,
          imageUrl: imageUrl,
          ref: ref);

      // update the user preferences
      for (var userLoop in sentTo) {
        // by default the tip is not archived
        FirebaseFirestore.instance
            .collection('${ENVIRONMENT}userPreferences/$userLoop/archived')
            .doc(_tipId)
            .set({
          _tipId: false,
        });
        // by default the tip is not muted
        FirebaseFirestore.instance
            .collection('${ENVIRONMENT}userPreferences/$userLoop/muted')
            .doc(_tipId)
            .set({
          _tipId: false,
        });
      }
    }

    addOtherItems(docRef);

    //return tipId as a result of the function execution
    return docRef.id.toString();
  }

// Update timeStampLastUpdated for a specific tip
  void updateTipTimeStampLastUpdated(tipId) async {
    // convert the timestamp to utc and then string
    final dateUpdated = DateTime.now().toUtc().toString();

    //Irina removed local copy update as we no longer use Tips provider and it was causing errors

    // get the index of the tip (the tips are stored in a list)
    // final tipIndex = state.indexWhere((tip) => tip.id == tipId);

    //Update data in the cache
    // state[tipIndex].timeStampLastUpdated = dateUpdated;

    //Update Firebase record
    FirebaseFirestore.instance.collection('${ENVIRONMENT}tips').doc(tipId).set({
      'timeStampLastUpdated': dateUpdated,
    }, SetOptions(merge: true));

    // return state[tipIndex];
  }

  /// update the vote cast by the user local memroy
  Future<List<Tip>> updateTipsContentStatus(
      contentId, contentType, newStatus) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    // find tips that have that contentId
    final filteredTips =
        state.where((tip) => tip.contentId == contentId).toList();

    //update their status in local memory
    for (var tip in filteredTips) {
      tip.tipStatus = newStatus;
    }

    //record content status on Firebase
    await FirebaseFirestore.instance
        .collection('${ENVIRONMENT}userPreferences/${userId}/contentStatus/')
        .doc('${contentType}${contentId}')
        .set({
      'contentStatus': newStatus,
    }, SetOptions(merge: true));

    return state;
  }

  /// this function allows user to access the tips sent before we added the voting
  /// system without breaking the code or the database
  /// NOTE: this code is replicated in tips list provider (unfortunately
  /// it is not possible to add it in a function)
  Map<String, Map<String, bool>> makeTheTipRetroactiveToTheVoteSystem(
      {required sentTo,
      required sentBy,
      required tipType,
      required contentType,
      required contentId,
      required tipId}) {
    // inititliase the uservotes default values
    Map<String, bool> userVotesDefault = {'isCastVote': false, 'isPoop': false};
    // initialise the user votes
    Map<String, Map<String, bool>> userVotes =
        Map.fromIterable(sentTo, key: (e) => e, value: (e) => userVotesDefault);
    // add the sender vote
    userVotes[sentBy] = {
      'isCastVote': true,
      // if the tipType is a recommendation than isPoop must be false
      'isPoop':
          tipType == ConstNewTipScreen.tipTypeRecommendation ? false : true
    };
    // add the original tip type as vote on firebase
    for (var user in userVotes.keys) {
      // if the sender already sent the tip then overwrite the vote
      var votesToSet = userVotes[user]!;
      FirebaseFirestore.instance
          .collection('${ENVIRONMENT}userVotes/$contentType$contentId/$user')
          .doc(tipId)
          .set(votesToSet);
    }
    return userVotes;
  }

  /// fetch the votes from firebase
  Future<dynamic> getVotesForContent(
      {required contentType,
      required contentId,
      required tipId,
      required sentTo}) async {
    // fetch the votes byt the tip users in the specific content
    Map allVotes = {};
    for (var user in sentTo) {
      final dynamic votes = await FirebaseFirestore.instance
          .doc('${ENVIRONMENT}userVotes/$contentType$contentId/$user/$tipId')
          .get();
      allVotes[user] = votes;
    }
    return allVotes;
  }

  /// defines the behaviour of redirection to the content screen based on the content type
  navigateToContentScreen(
      {required context,
      required contentType,
      required contentId,
      podcastUrl = ''}) {
    if (contentType == constContentTypePodcast) {
      Navigator.of(context).pushNamed(ContentScreen.routeName,
          arguments: [contentType, contentId, podcastUrl]);
    } else {
      Navigator.of(context).pushNamed(ContentScreen.routeName,
          arguments: [contentType, contentId]);
    }
  }

  /// defines the behaviour of redirection to the content screen based on the content type
  goToContentScreen(
      {required context,
      required contentType,
      required contentId,
      required tipid,
      required contentInfo,
      required overview,
      required title,
      required imageUrl}) {
    if ((contentType == constContentTypeMovie) ||
        (contentType == constContentTypeTv)) {
      Navigator.of(context).pushNamed(ContentScreen.routeName, arguments: [
        contentType,
        contentId,
        tipid,
        contentInfo,
        overview,
        title,
        imageUrl
      ]);
    } else if (((contentType == constContentTypeBook) ||
            (contentType == constContentTypePodcast)) &
        (contentInfo.length > 0)) {
      Navigator.of(context).pushNamed(ContentScreen.routeName, arguments: [
        contentType,
        contentId,
        tipid,
        contentInfo,
        overview,
        title,
        imageUrl
      ]);
    }
  }

  /// creates the front end name for the content info item
  String createNameBasedOnContentType(contentType) {
    if (contentType == constContentTypeMovie) {
      return ConstStringTipScreen.contentTypeMovie;
    } else if (contentType == constContentTypeTv) {
      return ConstStringTipScreen.contentTypeTvSeries;
    } else if (contentType == constContentTypeBook) {
      return ConstStringTipScreen.contentTypeBook;
    } else {
      return ConstStringTipScreen.contentTypePodcast;
    }
  }
}

final tipListProvider =
    StateNotifierProvider<TipsListNotifier, List<Tip>>((ref) {
  return TipsListNotifier([]);
});

/// Support function to set podcastUrl, even if only an empty string
String generatePodcastUrl({required Tip? currentTip}) {
  try {
    return currentTip?.contentType == constContentTypePodcast
        ? currentTip?.info!['feedUrl']
        : '';
  } catch (error) {
    return '';
  }
}

/// Support function to fetch a single tip from Firebase based on tipId (used to create post screen if navigated from Notifications tab)
Future<Tip?> fetchSingleTipFromFirebase(String tipId) async {
  final query = FirebaseFirestore.instance
      .collection('${ENVIRONMENT}tips')
      .doc(tipId)
      .withConverter<Tip>(
        fromFirestore: (snapshot, _) => Tip.fromJson(snapshot.data()!),
        toFirestore: (tip, _) => tip.toJson(),
      );

  final tip = (await query.get()).data();
//TODO ask irina about this one
  //add the tipId
  tip?.setTipId = (await query.get()).id;

  if (tip?.contentType == constContentTypePodcast) {
    // add podcastUrl
    final String podcastUrl = generatePodcastUrl(currentTip: tip);
    // add the info
    final info = {'feedUrl': podcastUrl};
    tip?.setInfo = info;
  }

  return tip;
}

/// Support function to fetch multiple tips from Firebase based on tipId which are visible to myUserId (used to create top recommendations for User profile)
Future<List<Tip>?> fetchTipsFromFirebaseByTipIdVisibleToMyUserId(
    List<String> tipIds, String myUserId) async {
  final query = FirebaseFirestore.instance
      .collection('${ENVIRONMENT}tips')
      .where(FieldPath.documentId, whereIn: tipIds)
      .where(Filter.or(Filter('visibleTo', arrayContains: myUserId),
          Filter('tipPrivacy', isEqualTo: constTipPrivacyPublic)))
      .withConverter<Tip>(
        fromFirestore: (snapshot, _) => Tip.fromJson(snapshot.data()!),
        toFirestore: (tip, _) => tip.toJson(),
      );
  List<Tip>? tips = [];

  final tipsQuerySnapshot = await query.get();

  for (var doc in tipsQuerySnapshot.docs) {
    Tip currentTip = doc.data();
    // if we are loading a podcast we need to add the feedurl to the info
    if (currentTip.contentType == constContentTypePodcast) {
      final String podcastUrl = generatePodcastUrl(currentTip: currentTip);
      final info = {'feedUrl': podcastUrl};
      // add the info
      currentTip.setInfo = info;
    }
    //add the tipId
    currentTip.setTipId = doc.id;

    tips.add(currentTip);
  }

  return tips;
}

/// Support function to add user id to tip SentTo (used when someone comments on the post but not part of SentTo yet to receive notifications)
void addUserIdToTipSentTo(
    {required String tipId, required String userId}) async {
//Pull current sentTo from Firebase
  final snapshot =
      await FirebaseFirestore.instance.doc('${ENVIRONMENT}tips/$tipId').get();

  List<String> sentToAsStrings = [];
  for (var sentToString in snapshot.data()!['sentTo']) {
    sentToAsStrings.add(sentToString);
  }

//Add new userId
  sentToAsStrings.add(userId);
  sentToAsStrings.toSet().toList();

//Send updated sentTo to Firebase
  FirebaseFirestore.instance.collection('${ENVIRONMENT}tips').doc(tipId).set({
    'sentTo': sentToAsStrings,
  }, SetOptions(merge: true));
}

/// Support function to add userId to visibleTo of all posts created by another userId (when adding each other to friends)
void addVisibleToUserIdToTipsBySentByUserId(
    {required String sentByUserId, required String visibleToUserId}) async {
  //fetch all tips sent by sentByUserId which are Public of FriendsOnly
  List<Tip> loadedTips = [];

  var query = await FirebaseFirestore.instance
      .collection('${ENVIRONMENT}tips')
      .where(Filter.and(
          Filter('sentBy', isEqualTo: sentByUserId),
          Filter('tipPrivacy',
              whereIn: [constTipPrivacyAllFriends, constTipPrivacyPublic])))
      .withConverter<Tip>(
        fromFirestore: (snapshot, _) => Tip.fromJson(snapshot.data()!),
        toFirestore: (tip, _) => tip.toJson(),
      );

  final querySnapshot = (await query.get());

  for (var doc in querySnapshot.docs) {
    Tip currentTip = doc.data();
    // if we are loading a podcast we need to add the feedurl to the info
    if (currentTip.contentType == constContentTypePodcast) {
      final String podcastUrl = generatePodcastUrl(currentTip: currentTip);
      final info = {'feedUrl': podcastUrl};
      // add the info
      currentTip.setInfo = info;
    }
    //add the tipId
    currentTip.setTipId = doc.id;

    //add the tip to the output map
    loadedTips.add(currentTip);
  }

  //for each tip
  for (var tip in loadedTips) {
    //update visibleToUserId
    tip.visibleTo == null
        ? tip.visibleTo = [visibleToUserId]
        : tip.visibleTo?.add(visibleToUserId);

    var newVisibleTo = tip.visibleTo!.toSet().toList();

    //Send updated visibleTo to Firebase
    FirebaseFirestore.instance
        .collection('${ENVIRONMENT}tips')
        .doc(tip.id)
        .set({
      'visibleTo': newVisibleTo,
    }, SetOptions(merge: true));
  }
}

/// Support function to remove userId from visibleTo of all posts created by another userId (when removing each other from friends)
void removeVisibleToUserIdFromTipsBySentByUserId(
    {required String sentByUserId, required String visibleToUserId}) async {
  //fetch all tips sent by sentByUserId which are Public of FriendsOnly
  List<Tip> loadedTips = [];

  //TODO: for now when deleted from friends you still see posts where you were tagged
  var query = await FirebaseFirestore.instance
      .collection('${ENVIRONMENT}tips')
      .where(Filter.and(
          Filter('sentBy', isEqualTo: sentByUserId),
          Filter('tipPrivacy',
              whereIn: [constTipPrivacyAllFriends, constTipPrivacyPublic])))
      .withConverter<Tip>(
        fromFirestore: (snapshot, _) => Tip.fromJson(snapshot.data()!),
        toFirestore: (tip, _) => tip.toJson(),
      );

  final querySnapshot = (await query.get());

  for (var doc in querySnapshot.docs) {
    Tip currentTip = doc.data();
    // if we are loading a podcast we need to add the feedurl to the info
    if (currentTip.contentType == constContentTypePodcast) {
      final String podcastUrl = generatePodcastUrl(currentTip: currentTip);
      final info = {'feedUrl': podcastUrl};
      // add the info
      currentTip.setInfo = info;
    }
    //add the tipId
    currentTip.setTipId = doc.id;

    //add the tip to the output map
    loadedTips.add(currentTip);
  }

  //for each tip
  for (var tip in loadedTips) {
    //update visibleToUserId
    tip.visibleTo == null
        ? tip.visibleTo = null
        : tip.visibleTo?.remove(visibleToUserId);

    var newVisibleTo = tip.visibleTo!.toSet().toList();

    //Send updated visibleTo to Firebase
    FirebaseFirestore.instance
        .collection('${ENVIRONMENT}tips')
        .doc(tip.id)
        .set({
      'visibleTo': newVisibleTo,
    }, SetOptions(merge: true));
  }
}
