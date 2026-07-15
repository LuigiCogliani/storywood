import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/theme_data.dart';

class UserProfilePostContentTypeNotifier
    extends StateNotifier<Map<String, bool>> {
  // initialise the filters for content type (default is show all)
  UserProfilePostContentTypeNotifier()
      : super({
          constContentTypeMovie: false,
          constContentTypeTv: false,
          constContentTypePodcast: false,
          constContentTypeBook: false,
        });

  void setContentTypeFilters(bool isMovieSelected, bool isTvSelected,
      bool isPodcastSelected, bool isBookSelected) {
    state = {
      constContentTypeMovie: isMovieSelected,
      constContentTypeTv: isTvSelected,
      constContentTypePodcast: isPodcastSelected,
      constContentTypeBook: isBookSelected
    };
  }
}

final contentTypePostFilterProvider = StateNotifierProvider<
    UserProfilePostContentTypeNotifier, Map<String, bool>>((ref) {
  return UserProfilePostContentTypeNotifier();
});
