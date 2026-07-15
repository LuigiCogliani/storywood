import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/theme_data.dart';
import '../data/environment.dart';
import '../models/playlist_class.dart';
import '../models/tip_class.dart';
import '../providers/tips_list_provider_riverpod.dart';

//TODO: Irina to review and clean up unused code

class TipsSinglePlaylistNotifier extends StateNotifier<List<Tip>> {
  TipsSinglePlaylistNotifier(state) : super([]);

  ///Support function to fetch playlist tips from Firebase
  Future<List<Tip>> fetchPlaylistTipsFromFirebase(
      Playlist playlist, String? userId) async {
    // initialise a local map for the loaded tips
    Map<String, Tip> loadedTips = {};

    //fetch from Firebase the tips from the playlist
    var query = await FirebaseFirestore.instance
        .collection('${ENVIRONMENT}tips')
        .where('playlistIds', arrayContains: playlist.id)
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
      loadedTips[doc.id] = currentTip;
    }

    // fetch the entire collection of content status
    //TODO: not scalable, need to figure out how to fetch only relevant tips status?
    var contentStatus = await FirebaseFirestore.instance
        .collection('${ENVIRONMENT}userPreferences/$userId/contentStatus')
        .get();

    final List<Tip> loadedTipsFinal = [];

    // TODO: check if I need this "Tip" here or if there is a better way to switch from map to list
    loadedTips.forEach((idOfTheTip, tip) {
      loadedTipsFinal.add(loadedTips[idOfTheTip]!);
    });

    //for each loaded contentStatus update corresponding tips
    if (contentStatus.docs.isNotEmpty) {
      for (var doc in contentStatus.docs) {
        // print('populating tip status');
        final filteredTips = loadedTipsFinal
            .where((tip) => tip.contentType! + tip.contentId! == doc.id)
            .toList();
        for (var tip in filteredTips) {
          tip.tipStatus = doc['contentStatus'];
          // print('tip.tipStatus');
          // print(tip.tipStatus);
        }
      }
    }

    // assign the list of tips to the private property
    state = loadedTipsFinal;

    return state;
  }

  ///Function removes tip from local state single playlist view based on tipId

  List<Tip> removeTipFromPlaylistLocal({required String tipId}) {
    //get the index of the tip in the state
    final tipIndex = state.indexWhere((tip) => tip.id == tipId);

    //remove the tip from the local page memory
    state.remove(state[tipIndex]);

    state = [...state];
    return state;
  }

  Future<List<Tip>> updateTipsContentStatus(
      contentId, contentType, newStatus, userId) async {
    // find tips that have that contentId
    final filteredTips =
        state.where((tip) => tip.contentId == contentId).toList();

    //update their status in local memory
    for (var tip in filteredTips) {
      tip.tipStatus = newStatus;
    }

    //record content status on Firebase
    await FirebaseFirestore.instance
        .collection('${ENVIRONMENT}userPreferences/$userId/contentStatus/')
        .doc('$contentType$contentId')
        .set({
      'contentStatus': newStatus,
    }, SetOptions(merge: true));

    return state;
  }
}

final tipsSinglePlaylistProvider =
    StateNotifierProvider<TipsSinglePlaylistNotifier, List<Tip>>((ref) {
  return TipsSinglePlaylistNotifier([]);
});

// ignore: slash_for_doc_comments
/**added by Luigi on 24 Jul 2023 to fix a bug with the tip status in iOS.
 * After working flawlessly the tip status dropdown stopped updating the front end 
 * in real time. We had to resort to a provider to trigger a widget rebuild.
 * Irina - it seems to be working again without this code but I keep it here commented out
 * just in case it happens again in the future.
 */
// class SinglePlaylistTipStatusNotifier extends StateNotifier<int> {
//   SinglePlaylistTipStatusNotifier() : super(0);
// // update the tip status provider
//   void updateState({required int newState}) {
//     state = newState;
//   }
// }

// final tipStatusSinglePlaylistProvider =
//     StateNotifierProvider<SinglePlaylistTipStatusNotifier, int>((ref) {
//   return SinglePlaylistTipStatusNotifier();
// });

class SinglePlaylistFilterContentStatusNotifier
    extends StateNotifier<Map<String, bool>> {
  // initialise the filters for content type (default is show all)
  SinglePlaylistFilterContentStatusNotifier()
      : super({
          ConstTipScreen.tipStatusNotStarted: false,
          ConstTipScreen.tipStatusInProgress: false,
          ConstTipScreen.tipStatusFinished: false,
        });

  void setContentStatusFilters(
    bool isNotStartedSelected,
    bool isInProgressSelected,
    bool isFinishedSelected,
  ) {
    state = {
      ConstTipScreen.tipStatusNotStarted: isNotStartedSelected,
      ConstTipScreen.tipStatusInProgress: isInProgressSelected,
      ConstTipScreen.tipStatusFinished: isFinishedSelected,
    };
  }
}

final contentStatusSinglePlaylistFilterProvider = StateNotifierProvider<
    SinglePlaylistFilterContentStatusNotifier, Map<String, bool>>((ref) {
  return SinglePlaylistFilterContentStatusNotifier();
});

final filteredTipsSinglePlaylistProvider = Provider((ref) {
  // keep getting the full list of tips from the provider
  final tipsDatabase = ref.watch(tipsSinglePlaylistProvider);
  /**the following map is used to make sure that if none
   * of filters is selected (e.g. if we did not select a single tip status type)
   * then we will see all of thet tips (e.g. show all the 3 status types)
   */

  final functionSpecificContentStatusFilters = {
    ...ref.watch(contentStatusSinglePlaylistFilterProvider)
  };

  // if there is not at least one content status filter set to true (i.e. they are all unselected)
  if (!functionSpecificContentStatusFilters.containsValue(true)) {
    // then set them all to true
    functionSpecificContentStatusFilters
        .updateAll((name, value) => value = true);
  }

  return tipsDatabase.where((tip) {
    /*
      if the filter for "Not started" is set to false and the tip we are looking is "Not started", 
      then return false (i.e. don't show on the playlist page).
      Same concept for the other filters
      */

    if (functionSpecificContentStatusFilters[
                ConstTipScreen.tipStatusNotStarted] ==
            false &&
        tip.tipStatus == ConstTipScreen.tipStatusNotStarted) {
      return false;
    }

    if (functionSpecificContentStatusFilters[
                ConstTipScreen.tipStatusFinished] ==
            false &&
        tip.tipStatus == ConstTipScreen.tipStatusFinished) {
      return false;
    }

    if (functionSpecificContentStatusFilters[
                ConstTipScreen.tipStatusInProgress] ==
            false &&
        tip.tipStatus == ConstTipScreen.tipStatusInProgress) {
      return false;
    }

    // in any other case return true (i.e. show the tip in the front end)
    return true;
  }).toList();
});
