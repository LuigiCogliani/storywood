import 'package:flutter/material.dart';

import '../data/theme_data.dart';

class Tip with ChangeNotifier {
  // some properties are not final to allow us to update them
  String? id;
  String? storywoodContentId;
  String? title;
  String? imageUrl;
  String? originalComment;
  String? contentType;
  String? tipType;
  String? sentBy;
  List<String>? sentTo;
  List<String>? visibleTo;
  String? timeStampCreated;
  String? tipStatus;
  String? tipPrivacy;
  String? contentId;
  String? timeStampLastUpdated;
  bool? isArchived;
  bool? isMuted;
  // content info (mostly used because the Book api does not allow us to search content at a later stage with ID)
  Map<dynamic, dynamic>? info;
  Map<String, Map<String, bool>>? userVotes;
  List<String>? playlistIds;

  set setTipId(String newId) {
    id = newId;
  }

  set setTipStatus(String newStatus) {
    tipStatus = newStatus;
  }

  set setArchivedStatus(bool newStatus) {
    isArchived = newStatus;
  }

  set setInfo(Map newInfo) {
    info = newInfo;
  }

  set setMutedStatus(bool newStatus) {
    isMuted = newStatus;
  }

  Tip(
      {this.id,
      this.title,
      this.imageUrl,
      this.originalComment,
      this.contentType,
      this.tipType,
      this.sentBy,
      this.sentTo,
      this.visibleTo,
      this.timeStampCreated,
      this.tipStatus,
      this.contentId,
      this.timeStampLastUpdated,
      this.isArchived,
      this.isMuted,
      this.info,
      this.userVotes,
      this.playlistIds,
      this.storywoodContentId,
      this.tipPrivacy});

  /// We will use this method to use pagination. Unfortunately with pagination we need
  /// to cast all the objects in a list, e.g. the list of user Id we send the tip to is stored
  /// as a list of strings, and returns to use as a list of items that are strings, but
  /// is read as a list of dynamic objects.
  Tip.fromJson(Map<String, dynamic> json) {
    List<String> playlistIdsAsStrings = [];
    // some of the tips will not hae the playlistIds field
    try {
      for (var playlistId in json['playlistIds']) {
        playlistIdsAsStrings.add(playlistId);
      }
    } catch (error) {}
    List<String> sentToAsStrings = [];
    for (var sentToString in json['sentTo']) {
      sentToAsStrings.add(sentToString);
    }
    List<String> visibleToAsStrings = [];
    if (json.containsKey('visibleTo'))
      for (var visibleToString in json['visibleTo']) {
        visibleToAsStrings.add(visibleToString);
      }
// we will fill the id using a setter method when we fetch the tisp with pagination
    id = '';

    playlistIds = playlistIdsAsStrings;
    title = json['title'];
    imageUrl = json['imageUrl'];
    originalComment = json['originalComment'];
    contentType = json['contentType'];
    tipType = json['tipType'];
    sentBy = json['sentBy'];
    sentTo = sentToAsStrings;
    timeStampCreated = json['timeStampCreated'];
    tipStatus = ConstTipScreen.tipStatusNotStarted;
    contentId = json['contentId'];
    timeStampLastUpdated = json['timeStampLastUpdated'];
    isArchived = false;
    isMuted = false;
// this if statement prevents legacy tips with no "info" from thwroing an error
    if (json.containsKey('info')) {
      info = json['contentType'] == constContentTypePodcast
          ? {'feedUrl': json['info']['feedUrl']}
          /** Add the 'images' only if we are working with movie
         * or tv series AND we actually have already images in the tip.
         * Legacy tips will have an empty info property, leading with assigning
         * a null value here.
         */
          : json['contentType'] != constContentTypeBook &&
                  json['info'].keys.contains('images')
              ? {'images': json['info']['images']}
              : {};
    } else {
      info = {};
    }
    userVotes = {};
    storywoodContentId = json.containsKey('storywoodContentId')
        ? json['storywoodContentId']
        : '';
    //check if tipPrivacy field available
    tipPrivacy = json.containsKey('tipPrivacy')
        ? json['tipPrivacy']
        //if legacy tip choose privacy based on sentTo length
        : sentToAsStrings.length == 1
            ? constTipPrivacySelfTip
            : constTipPrivacyTaggedFriends;
    //check if visibleTo field available
    visibleTo = json.containsKey('visibleTo')
        ? visibleToAsStrings
        //if legacy tip fill in with sentTo
        : sentToAsStrings;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    return data;
  }
}
