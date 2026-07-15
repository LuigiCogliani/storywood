import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../data/environment.dart';
import '../data/theme_data.dart';
import '../models/user_class.dart' as storywood;

//TODO: Irina to review and clean up unused code

class UserInfoNotifier extends StateNotifier<storywood.User?> {
  UserInfoNotifier() : super(null); //initialise data

  Future<storywood.User?> loadUserInfo() async {
    /**
     * Luigi: added this try catch statement to try diagnose
     * the issue we sometimes get when android users sign up
     */
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      DocumentSnapshot tempDoc = await FirebaseFirestore.instance
          .collection('${ENVIRONMENT}users')
          .doc(userId)
          .get();

      final storywood.User buffer = storywood.User(
        userId: tempDoc.id,
        userName: tempDoc['username'],
        friendsUserIds: tempDoc.data().toString().contains('friend_user_ids')
            ? List.from(tempDoc['friend_user_ids'])
            : null,
        friendRequestsUserIds:
            tempDoc.data().toString().contains('friend_requests_user_ids')
                ? List.from(tempDoc['friend_requests_user_ids'])
                : null,
        imageUrl: tempDoc.data().toString().contains('image_url') &&
                tempDoc['image_url'] != '' &&
                tempDoc['image_url'] != null
            ? tempDoc['image_url']
            : constDefaultImageMisingPlaceholder,
        favouriteGenreIds:
            tempDoc.data().toString().contains('favourite_genre_ids')
                ? List.from(tempDoc['favourite_genre_ids'])
                : null,
        topRecommendationIds:
            tempDoc.data().toString().contains('top_recommendation_ids')
                ? List.from(tempDoc['top_recommendation_ids'])
                : null,
      );

      state = buffer;
      return state;
    } catch (e, stackTrace) {
      // Log the error using Firebase Crashlytics
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
    }
  }

  void updateUserInfo(storywood.User newUserInfo) {
    state = newUserInfo;
  }

  void updateUserImageUrl(String imageUrl) {
    //update locally to trigger provider refresh
    state = state?.copyWith(imageUrl: imageUrl);

    //update on Firebase
    FirebaseFirestore.instance
        .collection('${ENVIRONMENT}users')
        .doc(state?.userId)
        .set({
      'image_url': imageUrl,
    }, SetOptions(merge: true));
  }

  void addFavouriteGenreId(String genreId) {
    //update locally to trigger provider refresh

    if (state!.favouriteGenreIds == null) {
      state!.favouriteGenreIds = [genreId];
    } else {
      state!.favouriteGenreIds?.add(genreId);
    }

    List<String> newFavouriteGenreIds = state!.favouriteGenreIds!;
    state = state?.copyWith(favouriteGenreIds: newFavouriteGenreIds);

    //update on Firebase
    FirebaseFirestore.instance
        .collection('${ENVIRONMENT}users')
        .doc(state?.userId)
        .set({
      'favourite_genre_ids': newFavouriteGenreIds,
    }, SetOptions(merge: true));
  }

  void removeFavouriteGenreId(String genreId) {
    //update locally to trigger provider refresh
    state!.favouriteGenreIds?.remove(genreId);
    List<String> newFavouriteGenreIds = state!.favouriteGenreIds!;
    state = state?.copyWith(favouriteGenreIds: newFavouriteGenreIds);

    //update on Firebase
    FirebaseFirestore.instance
        .collection('${ENVIRONMENT}users')
        .doc(state?.userId)
        .set({
      'favourite_genre_ids': newFavouriteGenreIds,
    }, SetOptions(merge: true));
  }

  void addTopRecommendationId(String tipId) {
    //update locally to trigger provider refresh
    if (state!.topRecommendationIds == null) {
      state!.topRecommendationIds = [tipId];
    } else {
      state!.topRecommendationIds?.add(tipId);
    }

    List<String> newTipIds = state!.topRecommendationIds!;
    state = state?.copyWith(topRecommendationIds: newTipIds);

    //update on Firebase
    FirebaseFirestore.instance
        .collection('${ENVIRONMENT}users')
        .doc(state?.userId)
        .set({
      'top_recommendation_ids': newTipIds,
    }, SetOptions(merge: true));
  }

  void removeTopRecommendationId(String tipId) {
    //update locally to trigger provider refresh
    state!.topRecommendationIds?.remove(tipId);
    List<String> newTipIds = state!.topRecommendationIds!;
    state = state?.copyWith(topRecommendationIds: newTipIds);

    //update on Firebase
    FirebaseFirestore.instance
        .collection('${ENVIRONMENT}users')
        .doc(state?.userId)
        .set({
      'top_recommendation_ids': newTipIds,
    }, SetOptions(merge: true));
  }
}

final userInfoProvider =
    StateNotifierProvider<UserInfoNotifier, storywood.User?>((ref) {
  return UserInfoNotifier();
});

///Provider returns the list of Storywood user objects who are friends with currently signed-in user
final friendsFutureProvider =
    FutureProvider<Map<String, storywood.User>>((ref) async {
  final Map<String, storywood.User> loadedUsers = {};

  ///Support function to pull list of friend ids
  Future<List<String>?> fetchFriendIds() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    var userInfo = await FirebaseFirestore.instance
        .collection('${ENVIRONMENT}users')
        .doc(userId)
        .get();
    var userInfoUpdated = storywood.User(
      userId: userInfo.id,
      userName: userInfo['username'],
      friendsUserIds: userInfo.data().toString().contains('friend_user_ids')
          ? List.from(userInfo['friend_user_ids'])
          : null,
      friendRequestsUserIds:
          userInfo.data().toString().contains('friend_requests_user_ids')
              ? List.from(userInfo['friend_requests_user_ids'])
              : null,
      imageUrl: userInfo.data().toString().contains('image_url') &&
              userInfo['image_url'] != '' &&
              userInfo['image_url'] != null
          ? userInfo['image_url']
          : constDefaultImageMisingPlaceholder,
      favouriteGenreIds:
          userInfo.data().toString().contains('favourite_genre_ids')
              ? List.from(userInfo['favourite_genre_ids'])
              : null,
      topRecommendationIds:
          userInfo.data().toString().contains('top_recommendation_ids')
              ? List.from(userInfo['top_recommendation_ids'])
              : null,
    );

    //update loaded user info provider with latest info
    ref.read(userInfoProvider.notifier).updateUserInfo(userInfoUpdated);

    return userInfoUpdated.friendsUserIds;
  }

  //pull friend ids
  final List<String>? friendIds = await fetchFriendIds();

  //pull user info for user friends
  if (friendIds != null && friendIds.isNotEmpty) {
    var usersCollection = await FirebaseFirestore.instance
        .collection('${ENVIRONMENT}users')
        .where(FieldPath.documentId, whereIn: friendIds)
        .get();

    for (var doc in usersCollection.docs) {
      loadedUsers[doc.id] = storywood.User(
        userId: doc.id,
        userName: doc['username'],
        imageUrl: doc.data().toString().contains('image_url') &&
                doc['image_url'] != '' &&
                doc['image_url'] != null
            ? doc['image_url']
            : constDefaultImageMisingPlaceholder,
        friendsUserIds: doc.data().toString().contains('friend_user_ids')
            ? List.from(doc['friend_user_ids'])
            : null,
        favouriteGenreIds: doc.data().toString().contains('favourite_genre_ids')
            ? List.from(doc['favourite_genre_ids'])
            : null,
        topRecommendationIds:
            doc.data().toString().contains('top_recommendation_ids')
                ? List.from(doc['top_recommendation_ids'])
                : null,
      );
    }
  }

  return loadedUsers;
});

final friendRequestsFutureProvider =
    FutureProvider<Map<String, storywood.User>>((ref) async {
  final Map<String, storywood.User> loadedUsers = {};

  //Support function to pull list of friendRequestIds
  Future<List<String>?> fetchFriendIds() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    var userInfo = await FirebaseFirestore.instance
        .collection('${ENVIRONMENT}users')
        .doc(userId)
        .get();
    var userInfoUpdated = storywood.User(
      userId: userInfo.id,
      userName: userInfo['username'],
      friendsUserIds: userInfo.data().toString().contains('friend_user_ids')
          ? List.from(userInfo['friend_user_ids'])
          : null,
      friendRequestsUserIds:
          userInfo.data().toString().contains('friend_requests_user_ids')
              ? List.from(userInfo['friend_requests_user_ids'])
              : null,
      imageUrl: userInfo.data().toString().contains('image_url') &&
              userInfo['image_url'] != '' &&
              userInfo['image_url'] != null
          ? userInfo['image_url']
          : constDefaultImageMisingPlaceholder,
      favouriteGenreIds:
          userInfo.data().toString().contains('favourite_genre_ids')
              ? List.from(userInfo['favourite_genre_ids'])
              : null,
      topRecommendationIds:
          userInfo.data().toString().contains('top_recommendation_ids')
              ? List.from(userInfo['top_recommendation_ids'])
              : null,
    );

    //update loaded user info provider
    ref.read(userInfoProvider.notifier).updateUserInfo(userInfoUpdated);

    return userInfoUpdated.friendRequestsUserIds;
  }

  //pull list of friend request ids
  final List<String>? friendRequestsUserIds = await fetchFriendIds();

  //pull user info for user friends
  if (friendRequestsUserIds != null && friendRequestsUserIds.isNotEmpty) {
    var usersCollection = await FirebaseFirestore.instance
        .collection('${ENVIRONMENT}users')
        .where(FieldPath.documentId, whereIn: friendRequestsUserIds)
        .get();

    for (var doc in usersCollection.docs) {
      loadedUsers[doc.id] = storywood.User(
        userId: doc.id,
        userName: doc['username'],
        imageUrl: doc.data().toString().contains('image_url') &&
                doc['image_url'] != '' &&
                doc['image_url'] != null
            ? doc['image_url']
            : constDefaultImageMisingPlaceholder,
        friendsUserIds: doc.data().toString().contains('friend_user_ids')
            ? List.from(doc['friend_user_ids'])
            : null,
        friendRequestsUserIds:
            doc.data().toString().contains('friend_requests_user_ids')
                ? List.from(doc['friend_requests_user_ids'])
                : null,
        favouriteGenreIds: doc.data().toString().contains('favourite_genre_ids')
            ? List.from(doc['favourite_genre_ids'])
            : null,
        topRecommendationIds:
            doc.data().toString().contains('top_recommendation_ids')
                ? List.from(doc['top_recommendation_ids'])
                : null,
      );
    }
  }

  return loadedUsers;
});

class UsernameNotifier extends StateNotifier<Map<String, dynamic>> {
  UsernameNotifier() : super({}); //initialise data

  // String? userId = FirebaseAuth.instance.currentUser?.uid;

  //TODO: fetchallusernames doesn't look scalable
  /// get the all the usernames and user IDs from firestore and store them into one map
  /// one with the user ids as keys
  Future<void> fetchAllUsernameFromFirebase() async {
    // initialise empty map
    Map<String, dynamic> usernameBuffer = {};
// we need to load the list of users twice to make sure that we load all the data
// wiht no errors (prevents the old issue with logging in the first time)
    //Extract from Firebase
    var usernameCollectionWarmUp = await FirebaseFirestore.instance
        .collection('${ENVIRONMENT}users')
        .get();

//Extract from Firebase
    var usernameCollection = await FirebaseFirestore.instance
        .collection('${ENVIRONMENT}users')
        .get();

/**
 * The problem is in the following code block. For some reason the first time we load data
 * from Firebase the username of the user currently logged in will not completely
 * load. As a result the next for loop would give an error because the doc would not have
 * a "username" field once it gest to the currently signed in user.
 * This is not a timing issue, since wrapping the loop inside a 5 seconds delay did not solve the
 * problem.
 * 
 * A possible solution was to load the newsfeed screen without an error, but will register the
 * username of the currently logged in user as an empty string. It will be filled up next time the user
 * goes to another screen and goes back to the newsfeed screen.
 */
    // fill the map
    for (var doc in usernameCollection.docs) {
      // this try statement avoids problem with the "ghost user" when we switch database without loggin out
      try {
        usernameBuffer[doc.id] = {
          'username': doc['username'],
          'imageUrl': doc.data().toString().contains('image_url') &&
                  doc['image_url'] != '' &&
                  doc['image_url'] != null
              ? doc['image_url']
              : constDefaultImageMisingPlaceholder
        };
      } catch (error) {}
    }

    state = {...usernameBuffer};
  }

  String convertUseridToUsername({required String sentBy}) {
    String sentByUsername = state[sentBy]?['username'] ?? '';

    return sentByUsername;
  }
}

final usernameProvider =
    StateNotifierProvider<UsernameNotifier, Map<String, dynamic>>((ref) {
  return UsernameNotifier();
});

class SentToNewTipNotifier extends StateNotifier<List<String>> {
  SentToNewTipNotifier(state, UsernameNotifier usernameNotifier)
      : usernames = usernameNotifier,
        super([]);

  final UsernameNotifier usernames;
  String? get userId {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  /// convert list of usernames into user IDs (used in new_tip_screen by the shareWith widget)
  List<String> convertSelectedUsernamesToUserids(
      {required List<String> sentTo}) {
    List<String> sendToSelectedBuffer = [];

    for (String username in sentTo) {
      sendToSelectedBuffer.add(usernames.state.keys.firstWhere(
          (key) => usernames.state[key]['username'] == username,
          orElse: () => ''));
    }
    sendToSelectedBuffer.add(userId ?? '');
    state = sendToSelectedBuffer;
    return state;
  }
}

final sentToNewTipProvider =
    StateNotifierProvider<SentToNewTipNotifier, List<String>>((ref) {
  return SentToNewTipNotifier([], ref.read(usernameProvider.notifier));
});

class UserSearchByUserNameNotifier extends StateNotifier<List<storywood.User>> {
  // initialise the filters for content type (default is show all)
  UserSearchByUserNameNotifier() : super([]);

  Future<List<storywood.User>?> getUsersByUsername(String? username) async {
    List<storywood.User> foundUsers = [];

    var usersCollection = await FirebaseFirestore.instance
        .collection('${ENVIRONMENT}users')
        .get();
// first commit

    for (var doc in usersCollection.docs) {
      // this try statement avoids problem with the "ghost user" when we switch database without loggin out
      try {
        if (doc['username'].contains(username)) {
          foundUsers.add(storywood.User(
            userId: doc.id,
            userName: doc['username'],
            imageUrl: doc.data().toString().contains('image_url') &&
                    doc['image_url'] != '' &&
                    doc['image_url'] != null
                ? doc['image_url']
                : constDefaultImageMisingPlaceholder,
            friendRequestsUserIds:
                doc.data().toString().contains('friend_requests_user_ids')
                    ? List.from(doc['friend_requests_user_ids'])
                    : null,
            friendsUserIds: doc.data().toString().contains('friend_user_ids')
                ? List.from(doc['friend_user_ids'])
                : null,
            favouriteGenreIds:
                doc.data().toString().contains('favourite_genre_ids')
                    ? List.from(doc['favourite_genre_ids'])
                    : null,
            topRecommendationIds:
                doc.data().toString().contains('top_recommendation_ids')
                    ? List.from(doc['top_recommendation_ids'])
                    : null,
          ));
        }
      } catch (error) {
        print('Ghost user found: $error');
      }
    }

    state = foundUsers;

    return state;
  }
}

final userSearchByUsernameProvider =
    StateNotifierProvider<UserSearchByUserNameNotifier, List<storywood.User>>(
        (ref) {
  return UserSearchByUserNameNotifier();
});

/// Support function to fetch a single User from Firebase based on userId
/// (used to create user screen if navigated from newsfeed)
Future<storywood.User?> fetchSingleUserFromFirebase(String userId) async {
  final query = FirebaseFirestore.instance
      .collection('${ENVIRONMENT}users')
      .doc(userId)
      .withConverter<storywood.User>(
        fromFirestore: (snapshot, _) =>
            storywood.User.fromJson(snapshot.data()!),
        toFirestore: (user, _) => user.toJson(),
      );

  final user = (await query.get()).data();

  //add the userId
  user?.setUserId = (await query.get()).id;

  return user;
}
