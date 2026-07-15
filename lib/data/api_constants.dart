/// constants used in the TMDB API provider
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = "https://api.themoviedb.org/3";
  static const String apiKey = "f348f5345784f13c9053073df3713ef8";
  static const String baseImageUrl = "https://image.tmdb.org/t/p/w500";
}

// timeout (in seconds) for the movie and TV series API
///used to be 3 seconds but we decided to increase it to 6 mid July 2023
///because we were having a lot of timeouts while using the app with data
const int timeout = 6;

// the max number of results returned by a search (for books and podcast API)
const int maxSearchResults = 10;
