import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/services.dart';

import '../android_ios_picker.dart';
import '../content_screen/cast_scroll.dart';
import '../app_bar_title_tile.dart';
import '../content_not_available_alert_dialog.dart';
import '../content_screen/streaming_scroll.dart';
import '../home_button.dart';
import '../three_share_buttons.dart';

import '../../providers/api_provider_riverpod.dart';
import '../../providers/locale_provider.dart';
import '../../data/theme_data.dart';

/// create the string for the subtitle, with year, genre, and runtime for movies.
/// This works in case of missing data as well (see movie "pain hustlers")
String subtitle(
    {required AsyncSnapshot<Map<String, dynamic>> snapshot,
    required String contentType,
    required String countryCode}) {
  // initialise an empty list for genres
  final List<Map<dynamic, dynamic>> genres = [];
  String genreString = '';
  // check if there is no genre in TMDB
  if (snapshot.data!['genres'] != null) {
    for (var genre in snapshot.data!['genres']) {
      genres.add(genre);
    }

    // if there is only one genre
    if (genres.isNotEmpty) {
      genreString = genres[0]['name'];
    }
    // if there are no genres
    else {
      genreString = '';
    }
  }
  String year = '';
  if (snapshot.data!['year'] != null) {
    year = snapshot.data!['year'];
  }
  String runtime = '';
  // runtime has a different format for movies and tv series
  if (contentType == constContentTypeMovie) {
    if (snapshot.data!['runtime'] != null) {
      runtime = snapshot.data!['runtime'] + ' min';
    }
  } else {
    // fpr the tv series we could not extract the runtime from TMDB
    // (see api_provider_riverpod.dart)
    runtime = '';
  }
  // concatenate the strings
  String subtitle = year +
      (genreString.isNotEmpty ? ' ‧ $genreString' : genreString) +
      (runtime.isNotEmpty ? ' ‧ $runtime' : runtime);

  return subtitle;
}

/// create the content screen for movies or tv series
Widget movieOrTvseriesContentScaffold({
  required context,
  required contentId,
  required contentType,
  required ref,
}) {
  return FutureBuilder<Map<String, dynamic>>(
      future: ref.read(contentInfoProvider.notifier).checkForContentInFirebase(
          contentType: contentType, contentId: contentId),
      builder: ((context, snapshot) {
        if (snapshot.hasError) {
          return const ContentNotAvailableAlertDialog();
        } else if (snapshot.hasData) {
          late YoutubePlayerController controller;
          controller = YoutubePlayerController(
              initialVideoId: snapshot.data!['trailer'] ??
                  ConstStringContentScreen.noTrailerMessage,
              flags: const YoutubePlayerFlags(
                mute: false,
                autoPlay: false,
                disableDragSeek: false,
                loop: false,
                isLive: false,
                forceHD: false,
                enableCaption: false,
              ));
// get the country code to search the streaming availabilty
          final String countryCode = ref.read(localeProvider);
          return YoutubePlayerBuilder(
              onExitFullScreen: () {
                // The player forces portraitUp after exiting fullscreen. This overrides the behaviour.
                SystemChrome.setPreferredOrientations(DeviceOrientation.values);
              },
              player: YoutubePlayer(
                controller: controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: constYoutubePlayerColor,
                progressColors: const ProgressBarColors(
                  playedColor: constYoutubePlayerColor,
                  handleColor: constYoutubePlayerColor,
                ),
              ),
              builder: (context, player) {
                if (Platform.isIOS) {
                  return CupertinoPageScaffold(
                    backgroundColor: constScaffoldBackground,
                    navigationBar: CupertinoNavigationBar(
                      trailing: HomeButton(ref: ref),
                      middle: AppBarTitleTile(
                        title: snapshot.data!['title'] ??
                            ConstStringContentScreen.noTitleMessage,
                        subtitle: subtitle(
                            contentType: contentType,
                            snapshot: snapshot,
                            countryCode: countryCode),
                        titleMinFontSize: 14,
                        subtitleFontSize: 14,
                        isClickable: false,
                        route: '',
                      ),
                      backgroundColor: constTopBarBackgroundColor,
                    ),
                    child: Stack(children: [
                      // stack the poster in the BG
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(snapshot.data!['posterPath'] ??
                                constDefaultImageMisingPlaceholder),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // overlay the poster in the BG with a fading gradient
                      Container(
                        foregroundDecoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              constContentScreenGradient1,
                              constContentScreenGradient2,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            stops: [0.1, 0.6],
                          ),
                        ),
                      ),
                      MovieOrTvSeriesBody(
                          snapshot: snapshot,
                          player: player,
                          countryCode: countryCode,
                          contentType: contentType),
                    ]),
                  );
                }
                {
                  return Scaffold(
                    extendBodyBehindAppBar: true,
                    backgroundColor: constScaffoldBackground,
                    appBar: AppBar(
                        actions: [HomeButton(ref: ref)],
                        centerTitle: constIsAppBarTitleNotCentered,
                        title: AppBarTitleTile(
                          title: snapshot.data!['title'] ??
                              ConstStringContentScreen.noTitleMessage,
                          subtitle: subtitle(
                              contentType: contentType,
                              snapshot: snapshot,
                              countryCode: countryCode),
                          titleMinFontSize: 14,
                          subtitleFontSize: 14,
                          isClickable: false,
                          route: '',
                        ),
                        elevation: 0,
                        backgroundColor: constTopBarBackgroundColor,
                        toolbarHeight: (MediaQuery.of(context).size.height -
                                MediaQuery.of(context).padding.top) *
                            0.12),
                    body: Stack(children: [
                      // stack the poster in the BG
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(snapshot.data!['posterPath'] ??
                                constDefaultImageMisingPlaceholder),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // overlay the poster in the BG with a fading gradient
                      Container(
                        foregroundDecoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              constContentScreenGradient1,
                              constContentScreenGradient2,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            stops: [0.1, 0.6],
                          ),
                        ),
                      ),

                      MovieOrTvSeriesBody(
                          snapshot: snapshot,
                          player: player,
                          countryCode: countryCode,
                          contentType: contentType)
                    ]),
                  );
                }
              });
        } else {
          return Center(
            child: androidIosPicker(
                androidVersion: const CircularProgressIndicator(
                  color: constCircularProgressIndicatorWhite,
                ),
                iosVersion: const CupertinoActivityIndicator(
                  color: constCircularProgressIndicatorWhite,
                )),
          );
        }
      }));
}

/// If there is no image, tmdb will not have an empty field
/// but a file like "https://image.tmdb.org/t/p/w500null".
/// This function checks if there is the word "null" in the poster path
bool isNullImage({required String posterPath}) {
  return posterPath.contains('null');
}

/// checkes whether or not the movie was released in the present year
bool isReleasedThisYear({required String releaseDate}) {
  return ((releaseDate != null) & (releaseDate.isNotEmpty))
      ? (DateTime.parse(releaseDate).year == DateTime.now().year ? true : false)
      : false;
}

/// extract the release date (for movies only)
String getReleaseDate(
    {required AsyncSnapshot<Map<String, dynamic>> snapshot,
    required String countryCode,
    required String contentType}) {
  String releaseDate = '';
  if (contentType == constContentTypeMovie) {
    if (snapshot.data!['releaseDates'] != null) {
      final List<Map<dynamic, dynamic>> releaseDates = [];

      for (var release in snapshot.data!['releaseDates']) {
        releaseDates.add({
          'releaseDate': release['release_dates'][0]['release_date'],
          'countryCode': release['iso_3166_1']
        });
      }
      for (var release in releaseDates) {
        if (release['countryCode'].contains(countryCode)) {
          releaseDate = release['releaseDate'];
        }
      }
    }
  }

  return releaseDate;
}

class MovieOrTvSeriesBody extends StatelessWidget {
  const MovieOrTvSeriesBody(
      {super.key,
      required this.snapshot,
      required this.player,
      required this.countryCode,
      required this.contentType});
  final AsyncSnapshot<Map<String, dynamic>> snapshot;
  final Widget player;
  final String countryCode;
  final String contentType;

  @override
  Widget build(BuildContext context) {
    /**
    * for some reason when we store complex data structures in Firebase we lose their type,
    e.g. the cast is stored as a list of maps, but when we fetch it we get a type of List<dynamic>.
    However, if we look at the type of the individual objects in the list, their type is not dynamic, but
    Map<String,dynamic>, which is how we stored them in firebase
    We need to create a new List and assign the items individually.
    
    */

    final List<Map<dynamic, dynamic>> streamingPlatforms = [];
    final List<Map<dynamic, dynamic>> cast = [];

    // check that cast and streaming providers are not null (this happens if e.g. there are zero streaming providers)
    if (snapshot.data!['cast'] != null) {
      for (var castMember in snapshot.data!['cast']) {
        cast.add(castMember);
      }
    }
    if (snapshot.data!['streamingProviders'] != null) {
      for (var provider in snapshot.data!['streamingProviders']) {
        streamingPlatforms.add(provider);
      }
    }
// get release date
    final String releaseDate = getReleaseDate(
        snapshot: snapshot, countryCode: countryCode, contentType: contentType);

    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = (MediaQuery.of(context).size.width);
    final snapshotData = snapshot.data!;
    final String year = snapshotData['year'].toString() ??
        ConstStringContentScreen.noYearMessage;

    final String imageUrl = isNullImage(posterPath: snapshotData['posterPath'])
        ? constDefaultImageMisingPlaceholder
        : snapshotData['posterPath'];
    final String storywoodContentId = snapshotData['storywoodContentId'];

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ThreeShareButtons(
              year: year,
              overview: snapshotData['overview'] ??
                  ConstStringContentScreen.noOverviewMessage,
              contentId: snapshotData['contentId'],
              contentInfo: const {},
              imageUrl: imageUrl,
              contentType: snapshotData['contentType'],
              title: snapshotData['title'],
              storywoodContentId: storywoodContentId,
            ),
            Center(
              child: snapshotData['trailer'] ==
                      ConstStringContentScreen.noTrailerMessage
                  ? const Text(ConstStringContentScreen.noTrailerMessage,
                      style: constBodyMediumLight)
                  : player,
            ),
            releaseDateSameYear(releaseDate, mediaQueryHeight),
            Container(
                padding: EdgeInsets.fromLTRB(
                  0,
                  mediaQueryHeight * 0.02,
                  0,
                  mediaQueryHeight * 0.01,
                ),
                child: CupertinoListTile(
                  title: Text(ConstStringContentScreen.streamingSectionTitle,
                      style: constTitleMediumLightBold),
                  subtitle: Text(
                      '${ConstStringContentScreen.streamingAvailabilityMessage} $countryCode on:',
                      style: constBodySmallLight),
                )),
            StreamingScroll(
              streamingPlatforms: streamingPlatforms,
              //snapshot.data!['streamingProviders'],
              cardHeight: mediaQueryHeight * 0.10,
              mediaQueryWidth: mediaQueryWidth,
              mediaQueryHeight: mediaQueryHeight,
            ),
            Container(
                padding: EdgeInsets.fromLTRB(
                  0,
                  mediaQueryHeight * 0.02,
                  0,
                  mediaQueryHeight * 0.001,
                ),
                child: const CupertinoListTile(
                  title: Text(ConstStringContentScreen.castSectionTitle,
                      style: constTitleMediumLightBold),
                )),
            SizedBox(
              height: mediaQueryHeight * 0.25,
              child: CastScroll(movieCast: cast),
            ),
            Container(
                padding: EdgeInsets.fromLTRB(
                  0,
                  mediaQueryHeight * 0.02,
                  0,
                  mediaQueryHeight * 0.005,
                ),
                child: const CupertinoListTile(
                  title: Text(ConstStringContentScreen.overviewSectionTitle,
                      style: constTitleMediumLightBold),
                )),
            Container(
                padding:
                    EdgeInsets.symmetric(horizontal: mediaQueryWidth * 0.05),
                child: Text(
                    snapshot.data!['overview'] ??
                        ConstStringContentScreen.noOverviewMessage,
                    style: constBodySmallLight)),
          ],
        ),
      ),
    );
  }

  /// shows the tile with the release date if the movie was released in the current year
  Widget releaseDateSameYear(String releaseDate, double mediaQueryHeight) {
    List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    if (isReleasedThisYear(releaseDate: releaseDate) &
        (contentType == constContentTypeMovie)) {
      final int day = DateTime.parse(releaseDate).day;
      final String month = months[(DateTime.parse(releaseDate).month - 1)];
      final int year = DateTime.parse(releaseDate).year;

      return Container(
          padding: EdgeInsets.fromLTRB(
            0,
            mediaQueryHeight * 0.02,
            0,
            mediaQueryHeight * 0.01,
          ),
          child: CupertinoListTile(
            title: Text(ConstStringContentScreen.releaseDateSectionTitle,
                style: constTitleMediumLightBold),
            subtitle: Text(
                '${ConstStringContentScreen.releaseDateMessage} $countryCode on $day $month $year',
                style: constBodySmallLight),
          ));
    } else {
      return SizedBox(
        height: 1,
      );
    }
  }
}
