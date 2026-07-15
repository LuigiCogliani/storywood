import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/theme_data.dart';

//TODO: Luigi to review and clean up unused code

class PlaylistNewTipNotifier extends StateNotifier<List<String>> {
  PlaylistNewTipNotifier() : super([]); //initialise data with null string

  /// updates the friends tagged in the tip
  List<String> updateListOfSelectedPlaylists(
      {required String playlistId, required bool checkboxState}) {
    // initialise the empty list of tipIds
    List<String> listOfPlaylistIds = [...state];

// if we selected the check box
    if (checkboxState) {
      // add user
      listOfPlaylistIds.add(playlistId);
    } else {
      listOfPlaylistIds.remove(playlistId);
    }
    /** If we don't use the spread operator, modifying the list of users an hence updating
     * the state will not trigger a widget rebuild
     */
    state = [...listOfPlaylistIds];
    return state;
  }

  /// after sending the tip we need to reset the provider
  void resetProvider() {
    state = [];
  }
}

final playlistNewTipProvider =
    StateNotifierProvider<PlaylistNewTipNotifier, List<String>>((ref) {
  return PlaylistNewTipNotifier();
});

class UserIdToUsernameNotifier extends StateNotifier<Map<String, String>> {
  UserIdToUsernameNotifier() : super({}); //initialise data with null string
  /// assign the map of user id to userenames. This map will be used in the tag
  /// friends tile in the new tip screen to show the front-end the usernames of the friends
  /// tagged
  void assignMap(map) {
    state = map;
  }
}

final userIdToUsernameProvider =
    StateNotifierProvider<UserIdToUsernameNotifier, Map<String, String>>((ref) {
  return UserIdToUsernameNotifier();
});

class TagFriendsNotifier extends StateNotifier<List<String>> {
  TagFriendsNotifier() : super([]); //initialise data with null string

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

class TipPrivacyStatusNewTipNotifier extends StateNotifier<String> {
  TipPrivacyStatusNewTipNotifier()
      : super(
            constTipPrivacyAllFriends); //initialise data with default value in case not changed
  /// store the comment into a provider
  void assignPrivacyStatus(String tipPrivayStatusPickedByUser) {
    state = tipPrivayStatusPickedByUser;
  }
}

final tipPrivacyStatusNewTipProvider =
    StateNotifierProvider<TipPrivacyStatusNewTipNotifier, String>((ref) {
  return TipPrivacyStatusNewTipNotifier();
});

final tagFriendsProvider =
    StateNotifierProvider<TagFriendsNotifier, List<String>>((ref) {
  return TagFriendsNotifier();
});

class CommentNewTipNotifier extends StateNotifier<String> {
  CommentNewTipNotifier() : super(''); //initialise data with null string
  /// store the comment into a provider
  void assignComment(String commentLeftByUser) {
    state = commentLeftByUser;
  }
}

final commentNewTipProvider =
    StateNotifierProvider<CommentNewTipNotifier, String>((ref) {
  return CommentNewTipNotifier();
});

class CommentNewTipValidationNotifier extends StateNotifier<bool> {
  CommentNewTipValidationNotifier() : super(true);

  void setCommentValidationStatus(bool isCommentNotValid) {
    state = isCommentNotValid;
  }
}

final commentNewTipValidationProvider =
    StateNotifierProvider<CommentNewTipValidationNotifier, bool>((ref) {
  return CommentNewTipValidationNotifier();
});

class ShareWithNewTipValidationNotifier extends StateNotifier<bool> {
  ShareWithNewTipValidationNotifier() : super(true);

  void setShareWithValidationStatus(bool isShareWithNotValid) {
    state = isShareWithNotValid;
  }
}

final shareWithNewTipValidationProvider =
    StateNotifierProvider<ShareWithNewTipValidationNotifier, bool>((ref) {
  return ShareWithNewTipValidationNotifier();
});

class ContentTypeSelectionNewTipNotifier extends StateNotifier<String> {
  ContentTypeSelectionNewTipNotifier()
      : super(ConstNewTipScreen.contentTypeDefaultValue); //initialise data

  void assignContentTypeSelection(String contentType) {
    state = contentType;
  }
}

final contentTypeSelectionNewTipProvider =
    StateNotifierProvider<ContentTypeSelectionNewTipNotifier, String>((ref) {
  return ContentTypeSelectionNewTipNotifier();
});

class QueryResultNewTipNotifier extends StateNotifier<String> {
  QueryResultNewTipNotifier() : super('search for movies'); //initialise data

  void assignQueryResult(String query) {
    state = query;
  }
}

final queryResultNewTipProvider =
    StateNotifierProvider<QueryResultNewTipNotifier, String>((ref) {
  return QueryResultNewTipNotifier();
});
