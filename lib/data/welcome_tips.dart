import './theme_data.dart';

const String scottPilgrimReview =
    'Edgar wright sets the bar for what a comic book adaptation should play like with "Scott Pilgrim". Fun fact: to achieve a comic book "feel", he asked the actors to blink as little as possible during the shoots.\n\n';

const String theAfterPartyReview =
    'A great murder mystery! Each episode retells the events of the evening from the perspective of a new character. Very entertaining and suspense keeps you going until the end of the season where a big reveal happens.\n\n';

const String scienceVsReview =
    'A fun and relatable podcast built on science-backed, peer-reviewed facts. But don’t take every thing your hear at face value: each episode comes with a full list of citations.\n\n';

const String theThreeBodyProblemReview =
    'A sci-fi novel contemplating the impact the discovery of an extraterrestrial life would have on humanity even before we would come into contact with aliens. Netflix is already turning it into a TV series.\n\n';
// the 4 welcome tips that are sent to a new user when they first signup
final List<Map<String, dynamic>> welcomeTips = [
  {
    'txTitle': 'The Three-Body Problem',
    'comment_android': theThreeBodyProblemReview,
    'comment_ios': theThreeBodyProblemReview,
    'contentType': constContentTypeBook,
    'tipType': ConstNewTipScreen.tipTypeRecommendation,
    'imageUrl':
        'https://books.google.com/books/content?id=Z7GfEAAAQBAJ&printsec=frontcover&img=1&zoom=5&edge=curl&source=gbs_api',
    'contentId': 'Z7GfEAAAQBAJ',
    'info': {
      'authors': ['Cixin Liu'],
      'publishedDate': DateTime.parse('2015-03-12 00:00:00.000'),
      'numberOfPages': 429,
      'genre': ['Fiction'],
      'publisher': 'Bloomsbury Publishing',
      'overview':
          'Read the award-winning, critically acclaimed, multi-million-copy-selling science-fiction phenomenon – soon to be a Netflix Original Series from the creators of Game of Thrones. 1967: Ye Wenjie witnesses Red Guards beat her father to death during China\'s Cultural Revolution. This singular event will shape not only the rest of her life but also the future of mankind. Four decades later, Beijing police ask nanotech engineer Wang Miao to infiltrate a secretive cabal of scientists after a spate of inexplicable suicides. Wang\'s investigation will lead him to a mysterious online game and immerse him in a virtual world ruled by the intractable and unpredictable interaction of its three suns. This is the Three-Body Problem and it is the key to everything: the key to the scientists\' deaths, the key to a conspiracy that spans light-years and the key to the extinction-level threat humanity now faces. Praise for The Three-Body Problem: \'Your next favourite sci-fi novel\' Wired \'Immense\' Barack Obama \'Unique\' George R.R. Martin \'SF in the grand style\' Guardian \'Mind-altering and immersive\' Daily Mail Winner of the Hugo and Galaxy Awards for Best Novel'
    },
    'playlistIds': [],
    'storywoodContentId': 'zXOMfp2JdYXr3xibR5oX'
  },
  {
    'txTitle': 'Science Vs',
    'comment': scienceVsReview,
    'contentType': constContentTypePodcast,
    'tipType': ConstNewTipScreen.tipTypeRecommendation,
    'imageUrl':
        'https://megaphone.imgix.net/podcasts/f521b120-2c30-11e6-b5f3-63ee984ee1a4/image/Spotify_Gimlet_Science-VS_Key-Art_3000x3000.jpg?ixlib=rails-4.3.1&max-w=3000&max-h=3000&fit=crop&auto=format,compress',
    'contentId': '1051557000',
    'info': {},
    'playlistIds': [],
    'storywoodContentId': 'wxPqbe2eAWxvxILmSHpC'
  },
  {
    'txTitle': 'The Afterparty',
    'comment': theAfterPartyReview,
    'contentType': constContentTypeTv,
    'tipType': ConstNewTipScreen.tipTypeRecommendation,
    'imageUrl':
        'https://image.tmdb.org/t/p/w500/8UgHNgUGjYLTnyIrss1kHoJ8jHg.jpg',
    'contentId': '106454',
    'info': {
      'images': [
        'https://image.tmdb.org/t/p/w500/7isUTcsF5PaIXkWrAIfmyYdRZc2.jpg',
        'https://image.tmdb.org/t/p/w500/7isUTcsF5PaIXkWrAIfmyYdRZc2.jpg',
        'https://image.tmdb.org/t/p/w500/7isUTcsF5PaIXkWrAIfmyYdRZc2.jpg'
      ]
    },
    'playlistIds': [],
    'storywoodContentId': 'uxxpJQcDZfjyMj9IMcpW'
  },
  {
    'txTitle': 'Scott Pilgrim vs. the World',
    'comment': scottPilgrimReview,
    'contentType': constContentTypeMovie,
    'tipType': ConstNewTipScreen.tipTypeRecommendation,
    'imageUrl':
        'https://image.tmdb.org/t/p/w500/g5IoYeudx9XBEfwNL0fHvSckLBz.jpg',
    'contentId': '22538',
    'info': {
      'images': [
        'https://image.tmdb.org/t/p/w500/2dKfeHCW7VWeyxuOO3RiR0Ay7Vt.jpg',
        'https://image.tmdb.org/t/p/w500/2dKfeHCW7VWeyxuOO3RiR0Ay7Vt.jpg',
        'https://image.tmdb.org/t/p/w500/2dKfeHCW7VWeyxuOO3RiR0Ay7Vt.jpg'
      ]
    },
    'playlistIds': [],
    'storywoodContentId': 'Bu458kl4ekQrb34eZFjE'
  },
];
