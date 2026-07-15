import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:podcast_search/podcast_search.dart';
import 'package:books_finder/books_finder.dart';

import './content_search_result_item.dart';

import '../content_not_available_alert_dialog.dart';
import '../adaptive_circular_loading.dart';

import '../../providers/api_provider_riverpod.dart';
import '../../data/theme_data.dart';
import '../../data/api_constants.dart';

class ListOfMovieResults extends riverpod.ConsumerWidget {
  const ListOfMovieResults({
    super.key,
    required this.query,
    required this.screenHeight,
    required this.screenWidth,
  });
  final String query;
  final double screenHeight;
  final double screenWidth;

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    String searchTerm = query;

    return FutureBuilder<List>(
        future: ref
            .read(movieNamesFromSearchNewTipProvider.notifier)
            .returnMovieNameFromSearch(searchTerm),
        builder: ((context, snapshot) {
          if (snapshot.hasError) {
            return const ContentNotAvailableAlertDialog();
          } else if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return const QueryReturnedNoResults();
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var result = snapshot.data![index];
                  final String imageUrl = result.posterPath == null
                      ? constDefaultImageMisingPlaceholder
                      : ApiConstants.baseImageUrl +
                          result.posterPath.toString();
                  return ContentSearchResultItem(
                    imageUrl: imageUrl,
                    ref: ref,
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    contentId: result.id.toString(),
                    title: result.title.toString(),
                    year: result.releaseDate.split('-')[0],
                    overview: result.overview.toString(),
                    contentType: constContentTypeMovie,
                  );
                },
              );
            }
          } else {
            return Center(
              child: adaptiveCircularLoading(
                  color: constCircularProgressIndicatorWhite),
            );
          }
        }));
  }
}

class ListOfTvResults extends riverpod.ConsumerWidget {
  const ListOfTvResults({
    super.key,
    required this.query,
    required this.screenHeight,
    required this.screenWidth,
  });
  final String query;
  final double screenHeight;
  final double screenWidth;

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    String searchTerm = query;
    return FutureBuilder<List>(
        future: ref
            .read(tvNamesFromSearchNewTipProvider.notifier)
            .returnTvNameFromSearch(searchTerm),
        builder: ((context, snapshot) {
          if (snapshot.hasError) {
            return const ContentNotAvailableAlertDialog();
          } else if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return const QueryReturnedNoResults();
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var result = snapshot.data![index];

                  final String imageUrl = result.posterPath == null
                      ? constDefaultImageMisingPlaceholder
                      : ApiConstants.baseImageUrl +
                          result.posterPath.toString();

                  return ContentSearchResultItem(
                      imageUrl: imageUrl,
                      ref: ref,
                      screenHeight: screenHeight,
                      screenWidth: screenWidth,
                      contentId: result.id.toString(),
                      title: result.name.toString(),
                      year: result.firstAirDate.split('-')[0],
                      overview: result.overview.toString(),
                      contentType: constContentTypeTv);
                },
              );
            }
          } else {
            return Center(
              child: adaptiveCircularLoading(
                  color: constCircularProgressIndicatorWhite),
            );
          }
        }));
  }
}

class ListOfBookResults extends riverpod.ConsumerWidget {
  const ListOfBookResults({
    super.key,
    required this.query,
    required this.screenHeight,
    required this.screenWidth,
  });
  final String query;
  final double screenHeight;
  final double screenWidth;

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    String searchTerm = query.toString();
    // do not actually start querying the API unless the user typed already 3 characters
    if (searchTerm.length > 2) {
      return FutureBuilder<List<Book>>(
          future: ref
              .read(bookNamesFromSearchNewTipProvider.notifier)
              .returnbookNameFromSearch(searchTerm),
          builder: ((context, snapshot) {
            if (snapshot.hasError &
                /**
                 * the book API has some code that throws an error if the query is 
                 * an empty string. This condition prevents us to access the snapshot
                 * error code if the error is of the type "query message empty"
                 * (the error message will contain "query.isNotEmpty")
                 */
                (!snapshot.error.toString().contains('query.isNotEmpty'))) {
              return const ContentNotAvailableAlertDialog();
            } else if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return const QueryReturnedNoResults();
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var result = snapshot.data![index];
                    String posterLink = result.info.imageLinks.isEmpty
                        ? 'https://i.ibb.co/9vVDbNt/app-icon.png'
                        : result.info.imageLinks['smallThumbnail'].toString();
                    // turn "http" into "https" to prevent "Content-Length must contain only digits" error
                    if (posterLink.substring(0, 5) == 'http:') {
                      posterLink =
                          '${posterLink.substring(0, 4)}s${posterLink.substring(4)}';
                    }
                    return ContentSearchResultItem(
                      imageUrl: posterLink,
                      ref: ref,
                      screenHeight: screenHeight,
                      screenWidth: screenWidth,
                      contentId: result.id.toString(),
                      title: result.info.title,
                      year: result.info.rawPublishedDate.split('-')[0],
                      overview: result.info.description.toString(),
                      contentType: constContentTypeBook,
                    );
                  },
                );
              }
            } else {
              // start showing the circula progress indicator only after the third character is typed
              return query.length < 2
                  ? const Center()
                  : Center(
                      child: adaptiveCircularLoading(
                          color: constCircularProgressIndicatorWhite),
                    );
            }
          }));
    } else {
      return const Center();
    }
  }
}

class ListOfPodcastResults extends riverpod.ConsumerWidget {
  const ListOfPodcastResults({
    super.key,
    required this.query,
    required this.screenHeight,
    required this.screenWidth,
  });
  final String query;
  final double screenHeight;
  final double screenWidth;

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    // get the search term from the provider
    String searchTerm = query;
    return FutureBuilder<SearchResult>(
        // run the API call
        future: ref
            .read(podcastNamesFromSearchNewTipProvider.notifier)
            .returnPodcastNamesFromSearch(searchTerm),
        builder: ((context, snapshot) {
          if (snapshot.hasError) {
            return const ContentNotAvailableAlertDialog();
          } else if (snapshot.hasData) {
            if (snapshot.data!.items.isEmpty) {
              return const QueryReturnedNoResults();
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.items.length,
                itemBuilder: (context, index) {
                  var result = snapshot.data!.items[index];

                  final String imageUrl = result.artworkUrl600.toString() == ''
                      ? constDefaultImageMisingPlaceholder
                      : result.artworkUrl600.toString();
                  return ContentSearchResultItem(
                      imageUrl: imageUrl,
                      ref: ref,
                      screenHeight: screenHeight,
                      screenWidth: screenWidth,
                      contentId: result.trackId.toString(),
                      title: result.trackName!.toString(),
                      year: result.releaseDate!.year.toString(),
                      overview: result.artistName.toString(),
                      contentType: constContentTypePodcast,
                      podcastUrl: result.feedUrl.toString());
                },
              );
            }
          } else {
            return Center(
              child: adaptiveCircularLoading(
                  color: constCircularProgressIndicatorWhite),
            );
          }
        }));
  }
}

class QueryReturnedNoResults extends StatelessWidget {
  const QueryReturnedNoResults({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.1),
        child: const Text(
            textAlign: TextAlign.center,
            ConstNewTipScreen.noContentFoundMessage),
      ),
    );
  }
}
