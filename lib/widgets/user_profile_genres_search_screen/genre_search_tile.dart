import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/genre_class.dart';
import '../../data/theme_data.dart';
import '../../providers/users_provider_riverpod.dart';

class UserProfileGenreSearchTile extends ConsumerWidget {
  const UserProfileGenreSearchTile({super.key, required this.genre});
  final Genre genre;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<String> favouriteGenreIds =
        ref.watch(userInfoProvider)?.favouriteGenreIds ?? [];

    bool genreSelected = (favouriteGenreIds.contains(genre.id) ? true : false);

    return CheckboxListTile(
      // color of the tick
      checkColor: constFilterScreenCheckboxMarkWhite,
      // fill color of the checkbox when the checkbox is checked
      activeColor: constFilterScreenCheckboxFillBlack,
      title: Text(
        genre.name,
        style: constBodyMediumWhite,
      ),
      value: genreSelected,
      onChanged: (bool? newValue) {
        if (newValue!) {
          ref.read(userInfoProvider.notifier).addFavouriteGenreId(genre.id);
        } else {
          ref.read(userInfoProvider.notifier).removeFavouriteGenreId(genre.id);
        }
      },
    );
  }
}
