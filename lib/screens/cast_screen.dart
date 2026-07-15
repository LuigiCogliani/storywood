import 'dart:io';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import '../data/api_constants.dart';
import '../providers/navigation_bar_provider.dart';
import '../providers/tips_list_provider_riverpod.dart';

import '../widgets/adaptive_circular_loading.dart';
import '../widgets/material_wrapped.dart';
import '../data/theme_data.dart';
import '../screens/newsfeed_screen.dart';

class CastScreen extends riverpod.ConsumerWidget {
  const CastScreen({super.key});
  static const routeName = '/cast-screen';

  Future<List> _getCredits(castEntity) async {
    // generate the API query url for movies
    final urlMovies = Uri.parse(
        '${ApiConstants.baseUrl}/person/${castEntity['id']}/movie_credits?api_key=${ApiConstants.apiKey}');
// get the movie credits
    final responseMovies = await http
        .get(urlMovies)
        // add a timeout
        .timeout(const Duration(seconds: timeout), onTimeout: () {
      return http.Response('Error', 408);
    });
    // append movies
    final List castCredits = json.decode(responseMovies.body)['cast'];
    // add the type of content
    for (var credit in castCredits) {
      credit['type'] = 'Movie';
    }

    // generate the API query url for movies
    final urlTv = Uri.parse(
        '${ApiConstants.baseUrl}/person/${castEntity['id']}/tv_credits?api_key=${ApiConstants.apiKey}');
// get the movie credits
    final responseTv = await http
        .get(urlTv)
        // add a timeout
        .timeout(const Duration(seconds: timeout), onTimeout: () {
      return http.Response('Error', 408);
    });

// append tv credits
    final List castCreditsTv = json.decode(responseTv.body)['cast'];
    for (var tv in castCreditsTv) {
      castCredits.add({
        'original_title': tv['original_name'],
        'release_date': tv['first_air_date'],
        'posterPath': tv['poster_path'],
        'id': tv['id'],
        'type': 'TV series'
      });
    }
// sort credits by date, descending
    castCredits.sort((b, a) => a['release_date'].compareTo(b['release_date']));
    return castCredits;
  }

  _body({required snapshot, required riverpod.WidgetRef ref}) {
    return SafeArea(
        child: Center(
      child: ListView.separated(
        separatorBuilder: (context, index) {
          return const Divider(
            color: constListDivider,
          );
        },
        itemCount: snapshot.data.length,
        itemBuilder: (BuildContext context, int index) {
          final String releaseDate = snapshot.data[index]['release_date'];
          final String year =
              releaseDate.length > 8 ? releaseDate.substring(0, 4) : 'no year';
          final poster = snapshot.data[index]['posterPath'] != null
              ? Image.network(
                  ApiConstants.baseImageUrl +
                      snapshot.data[index]['posterPath'],
                  fit: BoxFit.fitWidth,
                )
              : snapshot.data[index]['poster_path'] != null
                  ? Image.network(
                      ApiConstants.baseImageUrl +
                          snapshot.data[index]['poster_path'],
                      fit: BoxFit.fitWidth,
                    )
                  : Image.network(constDefaultImageMisingPlaceholder,
                      fit: BoxFit.fitWidth);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: MaterialWrapped(
              child: InkWell(
                  onTap: () {
                    ref.read(tipListProvider.notifier).navigateToContentScreen(
                        context: context,
                        contentType: snapshot.data[index]['type'].toString() ==
                                constContentTypeMovie
                            ? constContentTypeMovie
                            : constContentTypeTv,
                        contentId: snapshot.data[index]['id'].toString());
                  },
                  child: SizedBox(
                    height: 100,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: poster,
                        ),
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${snapshot.data[index]['original_title']}',
                                  style: constTitleSmallLightBold,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  year,
                                  style: constDisplaySmallWhite,
                                ),
                                Text(
                                  snapshot.data[index]['type'].toString(),
                                  style: constBodySmallLight,
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  )),
            ),
          );
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    final castEntity = ModalRoute.of(context)!.settings.arguments as Map;

    final double screenHeight = MediaQuery.of(context).size.height;

    return FutureBuilder(
      future: _getCredits(castEntity),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length == 0) {
            return const Center(
              child: Text(
                ConstStringCastScreen.noInfo,
                style: constBodyLargeLight,
              ),
            );
          } else {
            return Platform.isIOS
                ? CupertinoPageScaffold(
                    backgroundColor: constScaffoldBackground,
                    navigationBar: CupertinoNavigationBar(
                      backgroundColor: constTopBarBackgroundColor,
                      middle: Text(
                        '${castEntity['name']} ${ConstStringCastScreen.screenTitle}',
                        overflow: TextOverflow.ellipsis,
                        style: constTitleMediumLightBold,
                      ),
                      trailing: Material(
                        child: Container(
                          color: constScaffoldBackground,
                          child: IconButton(
                            onPressed: () {
                              // update the provider for the bottom navigation bar
                              ref
                                  .read(
                                      bottomNavigationBarIndexProvider.notifier)
                                  .updatebottomNavigationBarIndexNotifier(
                                      constHomeScreenBottomNavigationBarIndex);

                              Navigator.of(context).pushNamed(
                                NewsfeedScreen.routeName,
                              );
                            },
                            icon: Icon(
                              ConstBottomNavigationBar.newsfeedScreenIcon,
                              color: constIconColorLight,
                              size: screenHeight * 0.029,
                            ),
                          ),
                        ),
                      ),
                    ),
                    child: _body(snapshot: snapshot, ref: ref))
                : Scaffold(
                    appBar: AppBar(
                      centerTitle: constIsAppBarTitleNotCentered,
                      title: Text(
                        '${castEntity['name']} ${ConstStringCastScreen.screenTitle}',
                        overflow: TextOverflow.ellipsis,
                        style: constTitleMediumLightBold,
                      ),
                      actions: [
                        IconButton(
                          onPressed: () {
                            // update the provider for the bottom navigation bar
                            ref
                                .read(bottomNavigationBarIndexProvider.notifier)
                                .updatebottomNavigationBarIndexNotifier(
                                    constHomeScreenBottomNavigationBarIndex);

                            Navigator.of(context).pushNamed(
                              NewsfeedScreen.routeName,
                            );
                          },
                          icon: Icon(
                            ConstBottomNavigationBar.newsfeedScreenIcon,
                            color: constIconColorLight,
                            size: screenHeight * 0.029,
                          ),
                        )
                      ],
                    ),
                    body: _body(snapshot: snapshot, ref: ref));
          }
        } else if (snapshot.hasError) {
          return const Center(
            child: Text(
              ConstStringCastScreen.futureBuilderError,
              style: constBodyLargeLight,
            ),
          );
        } else {
          return adaptiveCircularLoading(
              color: constCircularProgressIndicatorWhite);
        }
      },
    );
  }
}
