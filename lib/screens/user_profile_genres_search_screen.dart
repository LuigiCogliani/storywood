import 'package:flutter/material.dart';

import '../data/theme_data.dart';
import '../data/genres.dart';
import '../models/genre_class.dart';
import '../widgets/user_profile_genres_search_screen/genre_search_tile.dart';

class UserProfileGenresSearchScreen extends StatefulWidget {
  const UserProfileGenresSearchScreen({super.key});
  static const routeName = '/user-profile-genres-search-screen';

  @override
  State<UserProfileGenresSearchScreen> createState() =>
      _UserProfileGenresSearchScreenState();
}

class _UserProfileGenresSearchScreenState
    extends State<UserProfileGenresSearchScreen> {
  late TextEditingController genreSearchController;
  List<Genre> displayedGenres = allGenres;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    genreSearchController = TextEditingController();
  }

  @override
  void dispose() {
    genreSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void filterGenresListBySearchText(String searchText) {
      setState(() {
        displayedGenres = allGenres
            .where((genre) =>
                genre.name.toLowerCase().contains(searchText.toLowerCase()))
            .toList();
      });
    }

    displayedGenres
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: constTopBarBackgroundColor,
      appBar: AppBar(
        backgroundColor: constTopBarBackgroundColor,
        centerTitle: constIsAppBarTitleNotCentered,
        title: const Text(
          ConstStringUserProfileScreen.selectGenresScreenTitle,
          style: constBodyLargeLight,
        ),
        iconTheme: const IconThemeData(color: constIconColorLight),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SearchBar(
              onChanged: (value) => filterGenresListBySearchText(value),
              backgroundColor: MaterialStatePropertyAll(Colors.grey[800]),
              controller: genreSearchController,
              leading: const Icon(
                Icons.search,
                color: Colors.white,
              ),
              textStyle: const MaterialStatePropertyAll(constBodyMediumWhite),
              shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenHeight * 0.01))),
              constraints: BoxConstraints(
                  maxHeight: screenHeight * 0.1,
                  minHeight: screenHeight * 0.05),
            ),
            Expanded(
              flex: 5,
              child: ListView.builder(
                  itemCount: displayedGenres.length,
                  itemBuilder: (context, index) {
                    return UserProfileGenreSearchTile(
                        genre: displayedGenres[index]);
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
