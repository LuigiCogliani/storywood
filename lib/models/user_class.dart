import 'package:flutter/material.dart';

import '../data/theme_data.dart';
/*
we use this class throughtout the app whenever we need to convert userId to UserName
and viceversa. Both properties are unique
*/

class User with ChangeNotifier {
  String? userId;
  String? userName;
  List<String>? friendsUserIds;
  List<String>? friendRequestsUserIds;
  // mid-Jul 2023: tried adding user profile, but image not working with Firebase
  String? imageUrl;
  List<String>? favouriteGenreIds;
  List<String>? topRecommendationIds;
// method set up as part as navigate to user profile from newsfeed
  set setUserId(String newId) {
    userId = newId;
  }

  User(
      {required this.userId,
      required this.userName,
      this.friendsUserIds,
      this.friendRequestsUserIds,
      this.imageUrl,
      this.favouriteGenreIds,
      this.topRecommendationIds});

  ///method set up to be able to change single state object inside riverpod so that it triggers refresh
  User copyWith({
    String? userId,
    String? userName,
    List<String>? friendsUserIds,
    List<String>? friendRequestsUserIds,
    String? imageUrl,
    List<String>? favouriteGenreIds,
    List<String>? topRecommendationIds,
  }) {
    return User(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      friendsUserIds: friendsUserIds ?? this.friendsUserIds,
      friendRequestsUserIds:
          friendRequestsUserIds ?? this.friendRequestsUserIds,
      imageUrl: imageUrl ?? this.imageUrl,
      favouriteGenreIds: favouriteGenreIds ?? this.favouriteGenreIds,
      topRecommendationIds: topRecommendationIds ?? this.topRecommendationIds,
    );
  }

  /// We will use this method to use pagination. Unfortunately with pagination we need
  /// to cast all the objects in a list, e.g. the list of user Id we send the tip to is stored
  /// as a list of strings, and returns to use as a list of items that are strings, but
  /// is read as a list of dynamic objects.
  User.fromJson(Map<String, dynamic> json) {
    // this try catch statement prevents legacy users from thwroing an error

    List<String> friendsUserIdsAsStrings = [];
    try {
      for (var userId in json['friend_user_ids']) {
        friendsUserIdsAsStrings.add(userId);
      }
    } catch (error) {}
    List<String> friendRequestsUserIdsAsStrings = [];
    try {
      for (var friendRequestsUserId in json['friend_requests_user_ids']) {
        friendRequestsUserIdsAsStrings.add(friendRequestsUserId);
      }
    } catch (error) {}

    List<String> favouriteGenreIdsAsStrings = [];
    try {
      for (var favouriteGenreId in json['favourite_genre_ids']) {
        favouriteGenreIdsAsStrings.add(favouriteGenreId);
      }
    } catch (error) {}
    List<String> topRecommendationIdsAsStrings = [];
    try {
      for (var topRecommendationId in json['top_recommendation_ids']) {
        topRecommendationIdsAsStrings.add(topRecommendationId);
      }
    } catch (error) {}
    try {
      imageUrl = json['image_url'];
    } catch (error) {
      imageUrl = constDefaultImageMisingPlaceholder;
    }

// we will fill the id using a setter method when we fetch the tips with pagination
    userId = '';

    userName = json['username'];
    friendsUserIds = friendsUserIdsAsStrings;
    friendRequestsUserIds = friendRequestsUserIdsAsStrings;

    favouriteGenreIds = favouriteGenreIdsAsStrings;
    topRecommendationIds = topRecommendationIdsAsStrings;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    return data;
  }
}
