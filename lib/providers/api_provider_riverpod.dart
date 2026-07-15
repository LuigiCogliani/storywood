import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:books_finder/books_finder.dart';
import 'package:podcast_search/podcast_search.dart';

import '../data/theme_data.dart';
import '../data/environment.dart';
import '../data/api_constants.dart';
import '../models/movie_search_result.dart';
import '../models/tv_search_result.dart';

import './locale_provider.dart';

class ContentInfoNotifier extends StateNotifier<Map<String, dynamic>> {
  Ref ref;
  ContentInfoNotifier(this.ref) : super({});

  /// fetch all info for a movie or a tv series and
  /// create a content object in Firebase
  Future<Map<String, dynamic>> getContentFromTmdb(
      {required String tmdbContentId,
      required String currentContentType}) async {
    /* initialise the Map with the info we will store in firebase.
  * queryLanguage is the language we performed the query in. This means that all the data pulled
  * e.g. overview, trailer etc. will be in that language (only english for now)
  */
    final Map<String, dynamic> info = {'queryLanguage': 'EN'};
    info['contentType'] = currentContentType;

    /*
     set the name of the tmdb API fields we need to check
     (the fields name sometimtes differ between movies and tv series)
    */
    List<String> contentFieldNames = ['', '', '', ''];
    currentContentType == constContentTypeMovie
        ? contentFieldNames = ['movie', 'title', 'release_date', 'runtime']
        : contentFieldNames = [
            'tv',
            'name',
            'first_air_date',
            'episode_run_time'
          ];
    // generate the DETAILS API query url
    final url = Uri.parse(
        '${ApiConstants.baseUrl}/${contentFieldNames[0]}/$tmdbContentId?api_key=${ApiConstants.apiKey}&language=en-US');
    // run the API query
    try {
      final response = await http
          .get(url)
          //add a timeout
          .timeout(const Duration(seconds: timeout), onTimeout: () {
        return http.Response('Error', 408);
      });
      // decode the API response
      final contentSearchResult = json.decode(response.body);
      // get the genres
      info['genres'] = contentSearchResult['genres'] ?? [];
// tmdb id
      info['contentId'] = tmdbContentId;
      // runtime
      info['runtime'] = currentContentType == constContentTypeMovie
          ? contentSearchResult[contentFieldNames[3]].toString() ?? ''
          // for the tv series the runtime is inside a List
          /**
        * NOTE the runtime is not working for tv series. tmdb stores the runtime inside and array.
        In the examples on the website (GoT) you will see the runtime stored as [60], which looks like an array with one element.
        However, when I pull the data I get an empty List in flutter. I tried casting it to list and it doesn't work.
        I also tried with multiple tv series and the same thing happens.
        The runtime type is List<dynamic>, and the length is zero.
        NOTE the same problem was solved for the images by removing the language from the query, but is not working in this case
        */
          : contentSearchResult[contentFieldNames[3]].toString() ?? '';
// TMDB vote
      info['voteAverage'] =
          contentSearchResult['vote_average'].toString() ?? 'No vote available';
      // get content title
      info['title'] = contentSearchResult[contentFieldNames[1]].toString() ??
          'No title available';
      // get content overview
      info['overview'] =
          contentSearchResult['overview'].toString() ?? 'No overview available';
      // get url for the content poster
      info['posterPath'] = ApiConstants.baseImageUrl +
              contentSearchResult['poster_path'].toString() ??
          'https://i.ibb.co/9vVDbNt/app-icon.png';
      // get the year the content was first released
      info['year'] =
          contentSearchResult[contentFieldNames[2]].toString().split('-')[0] ??
              '';
    } catch (error) {
      throw (error);
    }

    // generate the CAST API query url
    final urlCast = Uri.parse(
        '${ApiConstants.baseUrl}/${contentFieldNames[0]}/$tmdbContentId/credits?api_key=${ApiConstants.apiKey}&language=en-US');
    try {
      // initialise the data structure for the cast (each item is a map)
      List<Map> cast = [];

      final responseCast = await http
          .get(urlCast)
          // add a timeout
          .timeout(const Duration(seconds: timeout), onTimeout: () {
        return http.Response('Error', 408);
      });
      // decode the API response
      final castSearchResult = json.decode(responseCast.body)['cast'];
      // fill the list of cast members
      for (var castMember in castSearchResult) {
        cast.add(castMember);
      }
      // add the cast to the content info
      info['cast'] = cast;
    } catch (error) {
      throw (error);
    }

    // generate the SIMILAR CONTENT API query url
    final urlSimilar = Uri.parse(
        '${ApiConstants.baseUrl}/${contentFieldNames[0]}/$tmdbContentId/similar?api_key=${ApiConstants.apiKey}&language=en-US');
    // run the API query
    try {
      // initialise the data structure for the similar content
      List similarContent = [];

      final responseSimilar = await http
          .get(urlSimilar)
          //add a timeout
          .timeout(const Duration(seconds: timeout), onTimeout: () {
        return http.Response('Error', 408);
      });
      // decode the API response
      final similarContentResponse =
          json.decode(responseSimilar.body)['results'];

// fill the list of id for simila content
      for (var content in similarContentResponse) {
        similarContent.add(content['id']);
      }

      // assign the list of IDs
      info['similarContent'] = similarContent;
    } catch (error) {
      throw (error);
    }

    // generate the IMAGES API query url
    final urlImages = Uri.parse(
        '${ApiConstants.baseUrl}/${contentFieldNames[0]}/$tmdbContentId/images?api_key=${ApiConstants.apiKey}');
    // run the API query
    try {
// initialise the data structure for the images
      Map<String, List<String>> imagesContent = {};

      final responseImages = await http
          .get(urlImages)
          //add a timeout
          .timeout(const Duration(seconds: timeout), onTimeout: () {
        return http.Response('Error', 408);
      });
      // decode the API response
      final responseImagesBody = json.decode(responseImages.body);

      /// sometimes tmdb stores images in svg format, which will give us an error.
      /// This function checks if the last 3 characters are jpg or the last 4 characters are jpeg
      bool isJpg({required String filePath}) {
        // turn the path all to lowercase
        final String lowerCaseFilePath = filePath.toLowerCase();
        // check for jpg ending
        final bool isEndsInJpg =
            lowerCaseFilePath.substring(lowerCaseFilePath.length - 3) == 'jpg';
        // check for jpeg ending
        final bool isEndsInJpeg =
            lowerCaseFilePath.substring(lowerCaseFilePath.length - 4) == 'jpeg';
        return isEndsInJpg || isEndsInJpeg;
      }

      /// add the images from a specific category, and filter for English images
      List<String> addImagesToList(
          {required responseBody, required String nameOfTypeOfImages}) {
        // initialise the empty list whre you will store the images
        List<String> listOfImages = [];
        // check if we have the type of images for this specific content (this prevents errors)
        if (responseBody.keys.contains(nameOfTypeOfImages)) {
          for (var image in responseBody[nameOfTypeOfImages]) {
            // check they are in English
            if (image['iso_639_1'] == 'en' &&
                isJpg(filePath: image['file_path'])) {
              listOfImages.add(
                  ApiConstants.baseImageUrl + image['file_path'].toString() ??
                      'https://i.ibb.co/9vVDbNt/app-icon.png');
            }
          }
        }

        return listOfImages;
      }

// add logos
      imagesContent['logos'] = addImagesToList(
          responseBody: responseImagesBody, nameOfTypeOfImages: 'logos');
// add backdrops
      imagesContent['backdrops'] = addImagesToList(
          responseBody: responseImagesBody, nameOfTypeOfImages: 'backdrops');
// add logos
      imagesContent['posters'] = addImagesToList(
          responseBody: responseImagesBody, nameOfTypeOfImages: 'posters');

      // assign the images
      info['images'] = imagesContent;
    } catch (error) {
      throw (error);
    }

    // generate the EXTERNAL IDS API query url
    final urlExternal = Uri.parse(
        '${ApiConstants.baseUrl}/${contentFieldNames[0]}/$tmdbContentId/external_ids?api_key=${ApiConstants.apiKey}');
    // run the API query
    try {
      final responseExternal = await http
          .get(urlExternal)
          //add a timeout
          .timeout(const Duration(seconds: timeout), onTimeout: () {
        return http.Response('Error', 408);
      });
      // decode the API response
      final contentResultExternal = json.decode(responseExternal.body);
      //assign external ids
      info['externalIds'] = contentResultExternal;
    } catch (error) {
      throw (error);
    }
//(note that tv has no release dates)
    if (currentContentType == constContentTypeMovie) {
      // generate the RELEASE DATES API query url
      final urlRelease = Uri.parse(
          '${ApiConstants.baseUrl}/${contentFieldNames[0]}/$tmdbContentId/release_dates?api_key=${ApiConstants.apiKey}');
      // run the API query
      try {
        final responseRelease = await http
            .get(urlRelease)
            //add a timeout
            .timeout(const Duration(seconds: timeout), onTimeout: () {
          return http.Response('Error', 408);
        });
        // decode the API response
        final contentSearchResultRelease = json.decode(responseRelease.body);
        // assign release dates
        info['releaseDates'] = contentSearchResultRelease['results'];
      } catch (error) {
        throw (error);
      }
    } else {
      // assign release dates
      info['releaseDates'] = null;
    }

    // generate the API query url
    final urlTrailer = Uri.parse(
        '${ApiConstants.baseUrl}/${contentFieldNames[0]}/$tmdbContentId/videos?api_key=${ApiConstants.apiKey}&language=en-US');
    try {
      final responseTrailer = await http
          .get(urlTrailer)
          // add a timeout
          .timeout(const Duration(seconds: timeout), onTimeout: () {
        return http.Response('Error', 408);
      });
      // get all the trailers
      final trailerSearchResult = json.decode(responseTrailer.body)['results'];
// make list from for loop
// filter only for youtube videos:
      var youtubeList = [
        for (var video in trailerSearchResult)
          if (video['site'].toString() == 'YouTube') video
      ];
      // filter only for youtube trailers:
      var youtubeTrailerList = [
        for (var youtubeClip in youtubeList)
          if (youtubeClip['type'].toString() == 'Trailer') youtubeClip
      ];
      // filter only for official youtube trailers:
      var youtubeTrailerOfficialList = [
        for (var trailer in youtubeTrailerList)
          if (trailer['official'] == true) trailer
      ];

//NOTE: we have to use youtube video because the flutter widget is a youtube plugin
      // if there is at least an youtube official trailer get the first one
      if (youtubeTrailerOfficialList.isNotEmpty) {
        info['trailer'] = youtubeTrailerOfficialList[0]['key'].toString();
      } else
      // default to youtube trailer
      if (youtubeTrailerList.isNotEmpty) {
        info['trailer'] = youtubeTrailerList[0]['key'].toString();
      } else
      // default to first youtube video
      if (youtubeList.isNotEmpty) {
        info['trailer'] = youtubeList[0]['key'].toString();
      } else
      // say there is no video available
      {
        info['trailer'] = 'No trailer available';
      }
// get all the other videos
      List videos = [];

      for (var videoItem in trailerSearchResult) {
        if (videoItem['site'].toString() == 'YouTube') {
          Map itemToAdd = {};
          itemToAdd['video_type'] = videoItem['type'];
          itemToAdd['video_name'] = videoItem['name'];
          itemToAdd['video_youtube_key'] = videoItem['key'];
          videos.add(itemToAdd);
        }
      }
      //assign video
      info['videos'] = videos;
    } catch (error) {
      throw (error);
    }

// initialise map of streaming provider by country
    Map streamingProviders = {};
    // generate the url to fetch streaming providers
    final urlStreamingProviders = Uri.parse(
        '${ApiConstants.baseUrl}/${contentFieldNames[0]}/$tmdbContentId/watch/providers?api_key=${ApiConstants.apiKey}');

    try {
      final responseStreamingProviders = await http
          .get(urlStreamingProviders)
          // add a timeout
          .timeout(const Duration(seconds: timeout), onTimeout: () {
        return http.Response('Error', 408);
      });
      // decode the json response
      final searchResultStreamingProviders =
          json.decode(responseStreamingProviders.body)['results'];

      for (var countrycode in searchResultStreamingProviders.keys.toList()) {
        // initialise the data structure for the streaming providers
        final List<Map<String, String>> listOfStreamingProviders = [];
        for (var key
            in searchResultStreamingProviders[countrycode].keys.toList()) {
          if (key != 'link') {
            var streamingProvidersInSpecificCountry =
                searchResultStreamingProviders[countrycode][key];
            for (var provider in streamingProvidersInSpecificCountry) {
              if (key == 'flatrate') {
                listOfStreamingProviders.add({
                  // the order we will use to show the streaming services in the front end
                  'priority': 'a',
                  'streamingType': 'Subscription',
                  'providerName': provider['provider_name'],
                  'logoUrl':
                      '${ApiConstants.baseImageUrl}${provider['logo_path']}'
                });
              } else if ((key == 'rent') || (key == 'buy')) {
                const String streamingType = 'Rent';
                listOfStreamingProviders.add({
                  'priority': 'c',
                  'streamingType': streamingType,
                  'providerName': provider['provider_name'],
                  'logoUrl':
                      '${ApiConstants.baseImageUrl}${provider['logo_path']}'
                });
              } else if ((key == 'ads') || (key == 'free')) {
                const String streamingType = 'Ads';
                listOfStreamingProviders.add({
                  'priority': 'b',
                  'streamingType': streamingType,
                  'providerName': provider['provider_name'],
                  'logoUrl':
                      '${ApiConstants.baseImageUrl}${provider['logo_path']}'
                });
              }
            }
          }
        }
        List<Map<String, dynamic>> sortedListOfStreamingProviders =
            listOfStreamingProviders.toSet().toList();
        sortedListOfStreamingProviders
            .sort((a, b) => a['priority'].compareTo(b['priority']));
        //contentInfo['streamingProviders'] = sortedListOfStreamingProviders;
        streamingProviders[countrycode] = sortedListOfStreamingProviders;
      }

      info['streamingProviders'] = streamingProviders;
    } catch (error) {
      // do nothing
    }

// push the info into firebase

    var token = await FirebaseFirestore.instance
        .collection('${ENVIRONMENT}content$currentContentType')
        .add(info);
    // initialise a map with all the data required to create the content screen
    Map<String, dynamic> contentScreenData = {};
    contentScreenData['storywoodContentId'] = token.id;
    contentScreenData['trailer'] = info['trailer'];
    contentScreenData['title'] = info['title'];
    contentScreenData['contentType'] = info['contentType'];
    contentScreenData['year'] = info['year'];
    contentScreenData['contentId'] = info['contentId'];
    contentScreenData['runtime'] = info['runtime'];
    contentScreenData['voteAverage'] = info['voteAverage'];
    contentScreenData['overview'] = info['overview'];
    contentScreenData['posterPath'] = info['posterPath'];
    contentScreenData['cast'] = info['cast'];
    // get the country code to search the streaming availabilty
    final String countryCode = ref.read(localeProvider);
    contentScreenData['streamingProviders'] =
        info['streamingProviders'][countryCode];

    state = contentScreenData;
    return contentScreenData;
  }

// get the date of the first episode of a podcast
  String _getDateOfFirstEpisode(snapshot) {
    if (snapshot.episodes != null) {
      int earliestYear = 0;
      for (var episode in snapshot.episodes) {
        int currentYear = episode.publicationDate.year;
        // if we are in the first loop
        if (earliestYear == 0) {
          earliestYear = currentYear;
        } else if (earliestYear > currentYear) {
          earliestYear = currentYear;
        }
      }
      return earliestYear.toString();
    } else {
      return '';
    }
  }

  /// fetch all info for a movie or a tv series and
  /// create a content object in Firebase
  Future<Map<String, dynamic>> getContentFromPodcastSearch(
      {required String podcastId, required String url}) async {
    /* initialise the Map with the info we will store in firebase.
  * queryLanguage is the language we performed the query in. This means that all the data pulled
  * e.g. overview, etc. will be in that language (only english for now)
  */

    final Map<String, dynamic> info = {'queryLanguage': 'EN'};

// get the info from the url
    final Podcast item = await Podcast.loadFeed(url: url);

    // initialise the podcast search method
    var search = Search();
    // Search for podcasts with the title
    SearchResult results = await search.search(item.title!,
        // we only need one because we are search for the exact name
        //NOTE this will not work if we have two podcasts with the same name
        limit: 1);

    var yetAnotherPodcastObject = results.items[0];
    // those can all be null, so need to add a nullcheck in place
    info['title'] = item.title ?? 'Title not available';
    info['year'] = _getDateOfFirstEpisode(item);
    info['overview'] = item.description ?? 'Description not available';
    info['posterPath'] = item.image ?? 'https://i.ibb.co/9vVDbNt/app-icon.png';
    info['contentType'] = constContentTypePodcast;
    info['contentId'] = podcastId;
    // url we can use to load the feed
    info['feedUrl'] = yetAnotherPodcastObject.feedUrl ?? '';

    info['host'] = yetAnotherPodcastObject.artistName ?? 'Host not avilable';
    info['iTunesUrl'] = yetAnotherPodcastObject.trackViewUrl ?? '';
    info['genre'] =
        yetAnotherPodcastObject.primaryGenreName ?? 'Genre not available';

// push the info into firebase
    var token = await FirebaseFirestore.instance
        .collection('${ENVIRONMENT}content$constContentTypePodcast')
        .add(info);

    info['storywoodContentId'] = token.id;
    return info;
  }

  /// fetch all info for a movie or a tv series and
  /// create a content object in Firebase
  Future<Map<String, dynamic>> getContentFromBookSearch(
      {required String bookId}) async {
    /* initialise the Map with the info we will store in firebase.
  * queryLanguage is the language we performed the query in. This means that all the data pulled
  * e.g. overview, etc. will be in that language (only english for now)
  */

    Map<String, dynamic> info = {'queryLanguage': 'EN'};

    // assign the books matching the user input to a list
    final Book book = await getSpecificBook(bookId);

    final SaleInfo saleInfo = book.saleInfo;
    final BookInfo bookInfo = book.info;

    // those can all be null, so need to add a nullcheck in place
    info['title'] = bookInfo.title ?? 'Title not available';

    info['year'] = bookInfo.publishedDate ?? '';
    info['overview'] = bookInfo.description ?? 'Overview not available';
    String posterLink = bookInfo.imageLinks['smallThumbnail'].toString() ??
        'https://i.ibb.co/9vVDbNt/app-icon.png';
    // turn "http" into "https" to prevent "Content-Length must contain only digits" error
    if (posterLink.substring(0, 5) == 'http:') {
      posterLink = '${posterLink.substring(0, 4)}s${posterLink.substring(4)}';
    }
    info['posterPath'] = posterLink;

    info['contentType'] = constContentTypeBook;
    info['contentId'] = bookId;
    info['numberOfPages'] = bookInfo.pageCount.toString() ?? '';
    info['genre'] = bookInfo.categories ?? '';
    info['author'] = bookInfo.authors ?? '';
    info['publisher'] = bookInfo.publisher ?? '';
    info['subtitle'] = bookInfo.subtitle ?? '';

    //info['previewLink'] = bookInfo.previewLink;
    /** for some reason the properties
     * canonicalVolumeLink
     * infoLink, and
     * previewLink
     * prevent us to push the content to Firebase. When you call these three property
     * (or even a single one of them) the function will run and return all the value, but will not write to Firebase
     * I have no idea why (Luigi). I also tried embedding them individually
     * into try / catch statements, but it is not an error. In fact, in the example of Fight Club, all three links
     * are available. The good news is we can make the link ourselves
     */
    info['previewLink'] = 'https://play.google.com/books/reader?id=$bookId';
    info['canonicalVolumeLink'] =
        'https://play.google.com/store/books/details?id=$bookId';
    // push the info into firebase

    var token = await FirebaseFirestore.instance
        .collection('${ENVIRONMENT}content$constContentTypeBook')
        .add(info);

    info['storywoodContentId'] = token.id;
    return info;
  }

  /// we are now using unique SW id for content, but we will have an overlap
  /// with the APIs ID. This helper function will work regardless if we are receiving the SWID or the API ID
  Future<Map<String, dynamic>> checkBothStorywoodIdAndContentId(
      {required String contentType, required String contentId}) async {
    try {
      // first we will assume the id we receive is the SW id
      var content = await FirebaseFirestore.instance
          .doc('${ENVIRONMENT}content$contentType/$contentId')
          .get();
      return {'storywoodContentId': contentId, 'contentData': content.data()!};
    } catch (error) {
      // if that fails we will assume we have the APIs ID
      var content = await FirebaseFirestore.instance
          .collection('${ENVIRONMENT}content$contentType')
          .where('contentId', isEqualTo: contentId)
          .get();

      return {
        'storywoodContentId': content.docs[0].id,
        'contentData': content.docs[0].data()
      };
    }
  }

  /// Check if we already have a content object in firebase.
  /// NOTE: the try / catch has been tested and it works as intended (i.e.
  /// if we don't have a movie stored we will call the function to get it from TMDB)
  Future<Map<String, dynamic>> checkForContentInFirebase(
      {required String contentId,
      required String contentType,
      /**
       * The podcast search library only supports search by url. We can use the content id
       * to check if we already have the podcast in firebase or not, but if we don't we will
       * need the url to load the content data
       */
      String podcastUrl = ''}) async {
    try {
      final contentDataToUnpack = await checkBothStorywoodIdAndContentId(
          contentId: contentId, contentType: contentType);

      // initialise a map with all the data required to create the content screen
      final Map<String, dynamic> content = contentDataToUnpack['contentData'];
      Map<String, dynamic> contentScreenData = {};
//
// fields in common with all the 4 content types
      contentScreenData['title'] = content['title'];
      contentScreenData['year'] = content['year'];
      contentScreenData['overview'] = content['overview'];
      contentScreenData['posterPath'] = content['posterPath'];
      contentScreenData['contentType'] = content['contentType'];
      contentScreenData['contentId'] = content['contentId'];
      contentScreenData['storywoodContentId'] =
          contentDataToUnpack['storywoodContentId'];
      // fields only relevant for movie and tv
      if ((contentType == constContentTypeMovie) ||
          (contentType == constContentTypeTv)) {
        contentScreenData['trailer'] = content['trailer'];
        contentScreenData['runtime'] = content['runtime'];
        contentScreenData['voteAverage'] = content['voteAverage'];
        contentScreenData['cast'] = content['cast'];

        // get the country code to search the streaming availabilty
        final String countryCode = ref.read(localeProvider);

        contentScreenData['streamingProviders'] =
            content['streamingProviders'][countryCode];

        contentScreenData['images'] = content['images'];
        contentScreenData['genres'] = content['genres'];
        contentScreenData['releaseDates'] = content['releaseDates'];
      }
      // fields only relevant for podcast
      else if (contentType == constContentTypePodcast) {
        contentScreenData['feedUrl'] = content['feedUrl'];
        contentScreenData['host'] = content['host'];
        contentScreenData['genre'] = content['genre'];
        contentScreenData['iTunesUrl'] = content['iTunesUrl'];
      }
      // fields only relevant for books
      else {
        contentScreenData['numberOfPages'] = content['numberOfPages'];
        contentScreenData['genre'] = content['genre'];
        contentScreenData['author'] = content['author'];
        contentScreenData['publisher'] = content['publisher'];
        contentScreenData['subtitle'] = content['subtitle'];
        contentScreenData['canonicalVolumeLink'] =
            content['canonicalVolumeLink'];
        contentScreenData['infoLink'] = content['infoLink'];
        contentScreenData['previewLink'] = content['previewLink'];
        contentScreenData['publishedDate'] = content['publishedDate'];
      }

      return contentScreenData;
    } catch (error) {
      /**
       *  if we don't have the content we will fetch the content info from tmdb or the other APIs
       * and create a content object infirebase before loading the tip.
       * Next time the user loads the tip we will fetch the content info from firebase.
       * This will only be used once for user with old tips (the ones we added to our
       * database before we started storing the content info ourselves)
       */
      if ((contentType == constContentTypeMovie) ||
          (contentType == constContentTypeTv)) {
        Map<String, dynamic> info = await getContentFromTmdb(
            currentContentType: contentType, tmdbContentId: contentId);
        return info;
      } else if (contentType == constContentTypePodcast) {
        Map<String, dynamic> info = await getContentFromPodcastSearch(
            podcastId: contentId, url: podcastUrl);
        return info;
      } else {
        Map<String, dynamic> info =
            await getContentFromBookSearch(bookId: contentId);
        return info;
      }
    }
  }

  /// fetch the content info with the TMDB api, movies and tv series only
//   Future<Map<String, dynamic>> fetchContentInfo(
//       tmdbContentId, currentContentType) async {
//     // initialise the map we will return at the end of the function
//     final Map<String, dynamic> contentInfo = {};
//     // initialise the map to store the generic data on the content
//     // i.e. all the data except for the cast
//     Map<String?, dynamic> contentGenericData = {};
//     // initialise the data structure for the cast (each item is a map)
//     List<Map> cast = [];
//     // initialise the data structure for the streaming providers
//     final List<Map<String, String>> listOfStreamingProviders = [];
//     /*
//      set the name of the tmdb API fields we need to check
//      (the fields name differ between movies and tv series)
//     */
//     List<String> contentFieldNames = ['', '', ''];
//     currentContentType == constContentTypeMovie
//         ? contentFieldNames = ['movie', 'original_title', 'release_date']
//         : contentFieldNames = ['tv', 'name', 'first_air_date'];
//     // generate the API query url
//     final url = Uri.parse(
//         '${ApiConstants.baseUrl}/${contentFieldNames[0]}/$tmdbContentId?api_key=${ApiConstants.apiKey}');
//     // run the API query
//     try {
//       final response = await http
//           .get(url)
//           //add a timeout
//           .timeout(const Duration(seconds: timeout), onTimeout: () {
//         return http.Response('Error', 408);
//       });
//       // decode the API response
//       final contentSearchResult = json.decode(response.body);
//       // get content title
//       contentGenericData['title'] =
//           contentSearchResult[contentFieldNames[1]].toString() ??
//               'No title available';
//       // get content overview
//       contentGenericData['overview'] =
//           contentSearchResult['overview'].toString() ?? 'No overview available';
//       // get url for the content poster
//       contentGenericData['posterPath'] = ApiConstants.baseImageUrl +
//               contentSearchResult['posterPath'].toString() ??
//           'https://i.ibb.co/9vVDbNt/app-icon.png';
//       // get the year the content was first released
//       contentGenericData['year'] =
//           contentSearchResult[contentFieldNames[2]].toString().split('-')[0] ??
//               '';
//     } catch (error) {
//       throw (error);
//     }
//     // add the generic data to the content info
//     contentInfo['content_data'] = contentGenericData;

//     // generate the API query url
//     final urlCast = Uri.parse(
//         '${ApiConstants.baseUrl}/${contentFieldNames[0]}/$tmdbContentId/credits?api_key=${ApiConstants.apiKey}');
//     try {
//       final responseCast = await http
//           .get(urlCast)
//           // add a timeout
//           .timeout(const Duration(seconds: timeout), onTimeout: () {
//         return http.Response('Error', 408);
//       });
//       // decode the API response
//       final castSearchResult = json.decode(responseCast.body)['cast'];
//       // fill the list of cast members
//       for (var castMember in castSearchResult) {
//         cast.add(castMember);
//       }
//       // add the cast to the content info
//       contentInfo['cast'] = cast;
//     } catch (error) {
//       throw (error);
//     }
//     // generate the API query url
//     final urlTrailer = Uri.parse(
//         '${ApiConstants.baseUrl}/${contentFieldNames[0]}/$tmdbContentId/videos?api_key=${ApiConstants.apiKey}');
//     try {
//       final responseTrailer = await http
//           .get(urlTrailer)
//           // add a timeout
//           .timeout(const Duration(seconds: timeout), onTimeout: () {
//         return http.Response('Error', 408);
//       });
//       // get all the trailers
//       final trailerSearchResult = json.decode(responseTrailer.body)['results'];

//       // filter only for youtube trailers:
//       var filteredList = [
//         for (var video in trailerSearchResult)
//           if ((video['site'].toString() == 'YouTube') &&
//               (video['type'].toString() == 'Trailer'))
//             video
//       ];

//       // if there are no videos say the trailer is not available
//       if (filteredList.isEmpty) {
//         contentGenericData['trailer'] = 'No trailer available';
//       } else {
//         contentGenericData['trailer'] = filteredList[0]['key'].toString();
//       }
//     } catch (error) {
//       throw (error);
//     }

//     // generate the url to fetch streaming providers
//     final urlStreamingProviders = Uri.parse(
//         '${ApiConstants.baseUrl}${contentFieldNames[0]}/$tmdbContentId/watch/providers?api_key=${ApiConstants.apiKey}');

//     try {
//       final responseStreamingProviders = await http
//           .get(urlStreamingProviders)
//           // add a timeout
//           .timeout(const Duration(seconds: timeout), onTimeout: () {
//         return http.Response('Error', 408);
//       });
//       // decode the json response
//       final searchResultStreamingProviders =
//           json.decode(responseStreamingProviders.body);

// // get the country code to search the streaming availabilty
//       final String countryCode = ref.read(localeProvider);
// // iterate over all the different type of streaming (included in the subscription or rent)
//       for (var key in searchResultStreamingProviders['results'][countryCode]
//           .keys
//           .toList()) {
//         if (key != 'link') {
//           final searchResultStreamingProvidersGb =
//               searchResultStreamingProviders['results'][countryCode][key];
//           for (var provider in searchResultStreamingProvidersGb) {
//             if (key == 'flatrate') {
//               listOfStreamingProviders.add({
//                 // the order we will use to show the streaming services in the front end
//                 'priority': 'a',
//                 'streamingType': 'Subscription',
//                 'provider_name': provider['provider_name'],
//                 'logoUrl':
//                     '${ApiConstants.baseImageUrl}${provider['logo_path']}'
//               });
//             } else if ((key == 'rent') || (key == 'buy')) {
//               const String streamingType = 'Rent';
//               listOfStreamingProviders.add({
//                 'priority': 'c',
//                 'streamingType': streamingType,
//                 'provider_name': provider['provider_name'],
//                 'logoUrl':
//                     '${ApiConstants.baseImageUrl}${provider['logo_path']}'
//               });
//             } else if ((key == 'ads') || (key == 'free')) {
//               const String streamingType = 'Ads';
//               listOfStreamingProviders.add({
//                 'priority': 'b',
//                 'streamingType': streamingType,
//                 'provider_name': provider['provider_name'],
//                 'logoUrl':
//                     '${ApiConstants.baseImageUrl}${provider['logo_path']}'
//               });
//             }
//           }
//         }
//       }
//     } catch (error) {
//       // do nothing
//     }
//     List<Map<String, dynamic>> sortedListOfStreamingProviders =
//         listOfStreamingProviders.toSet().toList();
//     sortedListOfStreamingProviders
//         .sort((a, b) => a['priority'].compareTo(b['priority']));
//     contentInfo['streamingProviders'] = sortedListOfStreamingProviders;

//     state = contentInfo;

//     return state;
//   }
}

final contentInfoProvider =
    StateNotifierProvider<ContentInfoNotifier, Map<String, dynamic>>((ref) {
  return ContentInfoNotifier(ref);
});

class MovieNamesNewTipNotifier extends StateNotifier<List> {
  MovieNamesNewTipNotifier() : super([]); //initialise data with null string

  /// Send an API request to find all the movies matching the user input
  Future<List> returnMovieNameFromSearch(movieName) async {
    // initialise an empty list to store the movie titles
    List moviesFromSearch = [];

    // generate the API query url
    final url = Uri.parse(
        '${ApiConstants.baseUrl}/search/movie?api_key=${ApiConstants.apiKey}&query=$movieName');
    try {
      final response = await http
          .get(url)
          // add a timeout
          .timeout(const Duration(seconds: timeout), onTimeout: () {
        return http.Response('Error', 408);
      });
      // decode the json response
      final searchResult =
          movieSearchResult.fromJson(json.decode(response.body));
      // fill the list with movie names
      for (var result in searchResult.results!) {
        moviesFromSearch.add(result);
      }
      // assign the list to the private property
      state = moviesFromSearch;
      return state;
    } catch (error) {
      throw (error);
    }
  }
}

final movieNamesFromSearchNewTipProvider =
    StateNotifierProvider<MovieNamesNewTipNotifier, List>((ref) {
  return MovieNamesNewTipNotifier();
});

class TVNamesNewTipNotifier extends StateNotifier<List> {
  TVNamesNewTipNotifier() : super([]);

  /// Send an API request to find all the TV series matching the user input
  Future<List> returnTvNameFromSearch(tvName) async {
    // initialise an empty list to store the TV series titles
    List tvSeriesFromSearch = [];
    // generate the API query url
    final url = Uri.parse(
        '${ApiConstants.baseUrl}/search/tv?api_key=${ApiConstants.apiKey}&query=$tvName');

    try {
      final response = await http
          .get(url)
          // add a timeout
          .timeout(const Duration(seconds: timeout), onTimeout: () {
        return http.Response('Error', 408);
      });
      // decode the json response
      final searchResult = TvSearchResult.fromJson(json.decode(response.body));
      // fill the list with TV series titles
      for (var result in searchResult.results!) {
        tvSeriesFromSearch.add(result);
      }
      // assign the list to the private property
      state = tvSeriesFromSearch;
      return state;
    } catch (error) {
      throw (error);
    }
  }
}

final tvNamesFromSearchNewTipProvider =
    StateNotifierProvider<TVNamesNewTipNotifier, List>((ref) {
  return TVNamesNewTipNotifier();
});

class BookNamesNewTipNotifier extends StateNotifier<List<Book>> {
  BookNamesNewTipNotifier() : super([]);

  ///Send an API request to find all the TV series matching the user input
  Future<List<Book>> returnbookNameFromSearch(bookName) async {
    try {
      // assign the books matching the user input to a list
      final List<Book> books = await queryBooks(bookName,
          // limit the number of results
          maxResults: maxSearchResults,
          orderBy: OrderBy.relevance,
          langRestrict: 'en');
      // assign the list to a private property
      state = books;
      return state;
    } catch (error) {
      throw (error);
    }
  }
}

final bookNamesFromSearchNewTipProvider =
    StateNotifierProvider<BookNamesNewTipNotifier, List<Book>>((ref) {
  return BookNamesNewTipNotifier();
});

class PodcastNamesNewTipNotifier extends StateNotifier<List> {
  PodcastNamesNewTipNotifier() : super([]);

  /// scrape iTunes for the podcast
  Future<SearchResult> returnPodcastNamesFromSearch(podcastName) async {
    try {
      // initialise the podcast search method
      var search = Search();

      // Search for podcasts with the user input in the title
      SearchResult results = await search.search(podcastName,
          // limit the number of results in output
          limit: maxSearchResults);

      // assign the items in the result of the search to the private property
      state = results.items;
      return results;
    } catch (error) {
      throw (error);
    }
  }
}

final podcastNamesFromSearchNewTipProvider =
    StateNotifierProvider<PodcastNamesNewTipNotifier, List>((ref) {
  return PodcastNamesNewTipNotifier();
});
