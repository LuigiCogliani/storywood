import 'package:flutter/material.dart';

import '../data/theme_data.dart';

class NotificationObject with ChangeNotifier {
  late String id;
  late String timeStampCreated;
  late String tipId;
  late String notificationType;
  late String sentBy;
  late String sentByUsername;
  late List<String> sentTo;
  late List<String> sentToTokens;
  late int activeNotifications;
  late String imageUrl;

  set setNotifiationId(String newId) {
    id = newId;
  }

  NotificationObject(
      {required this.id,
      required this.timeStampCreated,
      required this.tipId,
      required this.notificationType,
      required this.sentBy,
      required this.sentByUsername,
      required this.sentTo,
      required this.sentToTokens,
      required this.activeNotifications,
      required this.imageUrl});

  /// We will use this method to use pagination. Unfortunately with pagination we need
  /// to cast all the objects in a list, e.g. the list of user Id we send the tip to is stored
  /// as a list of strings, and returns to use as a list of items that are strings, but
  /// is read as a list of dynamic objects.
  NotificationObject.fromJson(Map<String, dynamic> json) {
    List<String> sentToAsStrings = [];
    for (var sentToString in json['sentTo']) {
      sentToAsStrings.add(sentToString);
    }
    List<String> sentToTokensAsStrings = [];
    for (var sentToTokensString in json['sentTo']) {
      sentToTokensAsStrings.add(sentToTokensString);
    }
// we will fill the id using a setter method when we fetch the tisp with pagination
    id = '';
    timeStampCreated = json['timeStampCreated'];
    tipId = json['tipId'];
    notificationType = json['notificationType'];
    sentBy = json['sentBy'];
    sentByUsername = json['sentByUsername'];
    sentTo = sentToAsStrings;
    sentToTokens = sentToTokensAsStrings;
    // old tips wil not have an activeNotifications, so we need a try catch statement
    try {
      activeNotifications = json['activeNotifications'];
    } catch (error) {
      activeNotifications = 0;
    }
    // old tips wil not have an image url, so we need a try catch statement
    try {
      imageUrl = json['imageUrl'];
    } catch (error) {
      imageUrl = constDefaultImageMisingPlaceholder;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    return data;
  }
}
