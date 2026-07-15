import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/theme_data.dart';
import '../../data/genres.dart';
import '../../models/genre_class.dart';
import '../../models/user_class.dart' as storywood;
import '../../screens/user_profile_genres_search_screen.dart';

class UserProfileFavouriteGenres extends ConsumerWidget {
  const UserProfileFavouriteGenres(
      {super.key, required this.profileUser, required this.isMyProfile});
  final storywood.User profileUser;
  final bool isMyProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<String> favouriteGenreIds = profileUser.favouriteGenreIds ?? [];
    List<Genre> favouriteGenres = allGenres
        .where((genre) => favouriteGenreIds.contains(genre.id))
        .toList();
    final double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              ConstStringUserProfileScreen.tabNameGenres,
              style: constTourButtonLight,
              textAlign: TextAlign.start,
            ),
            if (isMyProfile)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(UserProfileGenresSearchScreen.routeName);
                  },
                  child: Icon(
                    CupertinoIcons.pencil_ellipsis_rectangle,
                    color: Colors.white,
                    size: screenHeight * 0.025,
                  ),
                ),
              ),
          ],
        ),
        if (favouriteGenres.isNotEmpty)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: GridView.builder(
                  //scrollDirection: Axis.horizontal,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    //childAspectRatio: 2 / 2.2, //controls the height of grid items
                  ),
                  itemCount: favouriteGenres.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Icon(
                          favouriteGenres[index].icon,
                          color: Colors.white,
                          size: screenHeight * 0.02,
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            favouriteGenres[index].name,
                            maxLines: 2,
                            style: const TextStyle(
                              fontFamily: 'ios',
                              fontSize: 10,
                              color: Colors.white,
                              overflow: TextOverflow.ellipsis,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  }),
            ),
          ),
        if (favouriteGenres.isEmpty)
          const Expanded(
              child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    ConstStringUserProfileScreen
                        .noFavouriteGenresMessageMyProfile,
                    style: constBodySmallWhite,
                    textAlign: TextAlign.center,
                  )))
      ],
    );
  }
}
