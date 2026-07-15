import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import './app_constants.dart';

/*
This file effectively replace the themeData property of MaterialApp to allows us to use the same code
for both Android and ios
Rules for naming the constants
1. use the lower camel case convention and always start with "const". This way everytime we run into one of the constants in the codebase
  we immediately know we will find that variable into the data folder
2. try to be as descpriptive as possible
 */

// cupertino icons here: https://itsallwidgets.com/cupertino-icons-gallery-the-home-of-over-1335-cupertino-icons-used-in-flutter

// the name of the app
const constAppName = 'Storywood';

const constStorywoodDummyUserId = '9jbp0RoR1Zsi1yOt9zls';

// all the constants for the bottom navigaiton bar
const int constHomeScreenBottomNavigationBarIndex = 0;
const int constPlaylistsBottomNavigationBarIndex = 1;
const int constNewTipScreenBottomNavigationBarIndex = 2;
const int constFriendsScreenBottomNavigationBarIndex = 3;
const int constUserProfileScreenBottomNavigationBarIndex = 4;

// link to all the legal documents
const constStorywoodLegalLink =
    'https://docs.google.com/document/d/13b9evStuy13jjclVL9Qy3YAeOmdwGAN5HGtQjr7WrDk/edit?usp=sharing';

// link delete account form
const constStorywoodDeleteAccountFormLink =
    'https://forms.gle/sftuDQrdH1HYHAF86';

// link to report issue form
const constStorywoodReportIssueFormLink = 'https://forms.gle/hjN7hcuu6bj9b26y6';

// the contact email to show in the front end
const constContactEmail = 'contact.storywood@gmail.com';

// set the app bar title off centre
const bool constIsAppBarTitleNotCentered = false;

// the names used throught the app for the content types
const String constContentTypeMovie = 'Movie';
const String constContentTypeTv = 'TV-series';
const String constContentTypeBook = 'Book';
const String constContentTypePodcast = 'Podcast';

// the names used throught the app for the post privacy types

const String constTipPrivacySelfTip = 'SelfTip';
const String constTipPrivacyTaggedFriends = 'TaggedFriends';
const String constTipPrivacyAllFriends = 'AllFriends';
const String constTipPrivacyPublic = 'Public';

// the names used throught the app for the playlist privacy types

const String constPlaylistPrivacyPrivate = 'Private';
const String constPlaylistPrivacyTaggedFriends = 'TaggedFriends';
const String constPlaylistPrivacyAllFriends = 'AllFriends';
const String constPlaylistPrivacyPublic = 'Public';

// the names used throught the app for the playlist status types

const String constPlaylistStatusActive = 'Active';
const String constPlaylistStatusDeleted = 'Deleted';

// the names used throught the app for the notification types
const String constNotifTypeNewTip = 'newTip';
const String constNotifTypeNewChatMessage = 'newChatMessage';
const String constNotifTypeNewFriendRequestReceived =
    'newFriendRequestReceived';
const String constNotifTypeNewFriendRequestApproved =
    'newFriendRequestApproved';
const String constNotifTypeNewVote = 'newVote';
const String constNotifTypeCollectionShared = 'newCollectionShared';

const constDefaultImageMisingPlaceholder =
    'https://i.ibb.co/9vVDbNt/app-icon.png';

//
/// constants strings used in the auth_screen
class ConstStringAuthScreen {
  ConstStringAuthScreen._();
  static const String alertDialogGenericTitle = 'An Error Occured!';
  static const String checkCredentialsAlertMessage =
      'Please check your credentials!';

  static const String alertDialogGenericCloseButton = 'Close';
  static const String checkUsernameAlertMessage = 'Username already taken!';
  static const String welcomeMessage = 'Welcome to Storywood';
  static const String forgotPasswordButton = 'Forgot Password?';
  static const String emailFieldPrefix = ' email';
  static const String emailFieldError = 'Invalid email!';
  static const String usernameFieldPrefix = ' username';
  static const String usernameFieldError =
      'Username must be at least $usernameMinimumLength characters long!';
  static const String passwordFieldPrefix = ' password';
  static const String passwordFieldError =
      'Password must be at least $passwordMinimumLength characters long!';
  static const String confirmPasswordFieldPrefix = ' confirm password';
  static const String confirmPasswordFieldError = 'Passwords do not match!';
  static const String acceptAgreement =
      'By using Storywood you agree to our terms of service';
  static const String login = 'LOGIN';
  static const String signup = 'SIGNUP';
  static const String instead = 'INSTEAD';
}

/// constants strings used in the tour_screen

class ConstStringTourScreen {
  ConstStringTourScreen._();

  static const String errorMessage =
      'Unfortunately we could not load the tour pages due to connection issues. Please try again later.';

  static const String page1Text =
      'Get tips from your friends on what to read, watch or listen to. Stay up-to-date with their most recent discoveries.';
  static const String page2Text =
      'Share your recommendations or condemnations with your friends. Be their guide in the ever-expanding woods of content.';
  static const String page3Text =
      '\nTell your friends what you think of their tips via comments.';
  static const String page4Text =
      'Heard about something interesting but not ready to share? Just save it for now.';
  static const String page5Text =
      'Get the key content info: trailers, streaming availability, cast, podcast episodes, and much more.';
  static const String page6Text =
      'Keep your tips organised in easy-to-navigate collections.';

  static const String page1ImageMaterial = 'assets/images/android_1.png';
  static const String page2ImageMaterial = 'assets/images/android_2.png';
  static const String page3ImageMaterial = 'assets/images/android_3.png';
  static const String page4ImageMaterial = 'assets/images/android_4.png';
  static const String page5ImageMaterial = 'assets/images/android_5.png';
  static const String page6ImageMaterial = 'assets/images/android_6.png';

  static const String page1ImageCupertino = 'assets/images/ios_1.png';
  static const String page2ImageCupertino = 'assets/images/ios_2.png';
  static const String page3ImageCupertino = 'assets/images/ios_3.png';
  static const String page4ImageCupertino = 'assets/images/ios_4.png';
  static const String page5ImageCupertino = 'assets/images/ios_5.png';
  static const String page6ImageCupertino = 'assets/images/ios_6.png';

  static const String skipTextButton = 'SKIP';
  static const String homeTextButton = 'HOME';
  static const String enterTextButton = 'ENTER';
}

/// constants strings used in the friends screen
class ConstStringFriendsScreen {
  ConstStringFriendsScreen._();
  static const String screenTitle = 'Friends';
  static const String yourFriendsTabLabel = 'Your friends';
  static const String requestsTabLabel = 'Requests';
  static const String userSearchErrorMessage =
      'There was an error, please try again later.';
  static const String userNotFoundMessage =
      'User not found. Please type the username with the correct spelling (Storywood does not support fuzzy search yet).';
  static const String sendFriendRequestButton = 'Send friend request';
  static const String requestSentDummyButton = 'Friend request sent';
  static const String yourFriendDummyButton = 'Your friend';
  static const String youDummyButton = 'You';
  static const String rejectButton = 'Reject';
  static const String approveButton = 'Approve';
  static const String removeFriendAlertTitle = 'Are you sure?';
  static const String removeFriendMenuItem = 'Remove friend';
}

/// constant strings used in the playlists screen

class ConstStringPlaylistsScreen {
  ConstStringPlaylistsScreen._();
  static const String screenTitle = 'Collections';
  static const String newPlaylistAlertTitle = 'New collection';
  static const String newPlaylistAlertHintMessage = 'Enter name';
  static const String newPlaylistAlertSave = 'Save';
  static const String newPlaylistAlertCancel = 'Cancel';
  static const String errorMessageNoPlaylists =
      'You do not have any collections yet. \n\n Please press plus to create your first collection.';
  static const String playlistPrivacyStatusDisplayedPrivate = 'Private';
  static const String playlistPrivacyStatusDisplayedAllFriends = 'All friends';
  static const String playlistPrivacyStatusDisplayedPublic = 'Public';
  static const List<String> playlistPrivacyStatusOptionsDisplayed = [
    playlistPrivacyStatusDisplayedPrivate,
    playlistPrivacyStatusDisplayedAllFriends,
    playlistPrivacyStatusDisplayedPublic,
  ];
}

class ConstStringSinglePlaylistScreen {
  ConstStringSinglePlaylistScreen._();
  static const String loadingError = 'Loading error';
  static const String errorMessage1 =
      'Unfortunately we could not load the collection. Please try again later.';
  static const String errorMessage2 =
      'Unfortunately we could not load the collection due to connection issues. Please try again later.';
  static const String errorMessageNoTipsPart1 =
      'You do not have any tips yet in this collection. \n\nYou can go to Home screen and add your friends’ tips to this collection from there.';
  static const String errorMessageNoTipsPart2 =
      'You can add your own finds by going to New tip screen.';
  static const String deleteAlertDialogTitle = 'Delete collection?';
  static const String deleteAlertDialogContent =
      'This action cannot be reversed.';
  static const String deleteAlertDialogDelete = 'Delete';
  static const String menuButtonItem1 = 'Delete collection';
  static const String menuButtonItem2 = 'Rename collection';
  static const String menuButtonItem3 = 'Share collection';
  static const String menuButtonCancel = 'Cancel';
  static const String shareButton = 'Share';
  static const String titleCollectionSharedWith = 'Collection shared with: ';
  static const String titleChooseFriends = 'Choose friends to share with:';
  static const String removeTipAlertDialogTitle = 'Are you sure?';
  static const String removeTipAlertDialogContent =
      'You will still be able to access this tip via Home screen if you got this tip from a friend. If it is your personal record, you will lose it unless you assign it to another collection first.';
  static const String removeIconTitle = 'Remove';
  static const String tipStatusNotStarted = 'Not started';
  static const String tipStatusInProgress = 'In progress';
  static const String tipStatusFinished = 'Finished';
  static const List<String> tipStatusOptions = [
    tipStatusNotStarted,
    tipStatusInProgress,
    tipStatusFinished,
  ];

  static const String bookmarkPopupCreateCollectionTitle =
      'Create new collection';
  static const String bookmarkPopupCreateCollectionHint = 'Enter name';
  static const String bookmarkPopupCreateCollectionSave = 'Save';
  static const String bookmarkPopupTitle = 'Collections';
}

/// constants strings used in the new tip playlist screen
class ConstStringNewTipPlaylistScreen {
  ConstStringNewTipPlaylistScreen._();
  static const String subtitle = 'Choose collection';
  static const String saveButtonText = 'Save';
  static const String noPlaylistSelectedAlertTitle = 'No collection selected';
  static const String noPlaylistSelectedAlertMessage =
      'Please select at least one collection.\nIf you do not have any collections yet, you can create one by pressing the plus button.';
}

/// all the formatting used in the bottom navigation bar
class ConstBottomNavigationBar {
  ConstBottomNavigationBar._();
  static const String newsfeedScreen = 'Home';
  static const String friendsScreen = 'Friends';
  static const String newTipScreen = 'New Tip';
  static const String discoveryScreen = 'Discover';
  static const String userProfileScreen = 'Profile';
  static const String playlistsScreen = 'Collections';
  static const newsfeedScreenIcon = CupertinoIcons.home;
  static const friendsScreenIcon = CupertinoIcons.person_2;
  static const newTipScreenIcon = CupertinoIcons.plus_circle;
  static const discoveryScreenIcon = CupertinoIcons.search;
  static const userProfileScreenIcon = CupertinoIcons.person;
  static const playlistsScreenIcon = CupertinoIcons.bookmark;
  static const activeColor = Colors.white;
  static const inactiveColor = Colors.grey;
  static const backgroundColor = Colors.black;
  static const IconThemeData unselectedIconTheme = IconThemeData(
    color: inactiveColor,
  );
  static const IconThemeData selectedIconTheme =
      IconThemeData(color: activeColor);
}

/// constants strings used in the reset password screen
class ConstStringResetPasswordScreen {
  ConstStringResetPasswordScreen._();
  static const String message = 'Password reset email sent';
  static const String errorMessage = 'email not valid';
  static const String iosContent = 'check your inbox';
  static const String alertDialogGenericTitle = 'An Error Occured!';
  static const String alertDialogGenericCloseButton = 'Close';
  static const String screenTitle = 'Reset password';
  static const String screenBody =
      'Provide your email to\nreset your password.';
  static const String emailFieldPrefix = ConstStringAuthScreen.emailFieldPrefix;
  static const String resetPasswordButton = screenTitle;
  static const String emailFieldError = 'Please enter a valid email';
  static const String buttonText = screenTitle;
}

/// strings used in the verify email screen
class ConstStringVerifyEmailScreen {
  ConstStringVerifyEmailScreen._();
  static const String screenTitle = 'Verify email';
  static const String screenBody =
      'A verification email has been sent to your inbox.';

  static const String cancelButton = 'Cancel';
  static const String resendEmailButton = 'Resend email';
}

/// strings used in the notifications screen
class ConstStringNotificationsScreen {
  ConstStringNotificationsScreen._();
  static const String screenTitle = 'Notifications';
  static const String newTip = ' shared a new tip with you';
  static const String newMessage = ' left a new comment';
  static const String newFriendRequestReceived = ' sent you a friend request';
  static const String newFriendRequestApproved =
      ' approved your friend request';
  static const String newVote = ' placed a new vote';
  static const String newCollectionShared = ' shared a collection';
  static const String futureBuilderNotLoadingTitle = 'Error';
  static const String futureBuilderNotLoadingMessage =
      'Notifications are not available at the moment, please try again later';
}

/// strings used in the newsfeed screen
class ConstStringNewsfeedScreen {
  ConstStringNewsfeedScreen._();
  static const String screenTitle = 'Storywood';
  static const String friendsTabLabel = 'Friends';
  static const String publicTabLabel = 'Explore';
  static const String zeroFriends =
      "Looks like you're the trailblazer here! 🚀 \n\n Your feed is waiting to be filled with recommendations from friends, but it seems you haven't connected with anyone yet. \n\n Don't worry, every adventure starts with a single step. Invite friends to join you on this journey and let's build a community of sharers together!";
  static const String feedTourMessage =
      'New feature! 🚀 \n\n Tap the Public tab to see the newsfeed with all the public posts. \n\n Tap the Friends tab to see the newsfeed with only posts from your friends.';
  static const String futureBuilderNotLoadingTitle = 'Error';
  static const String userInfoNotLoadedError =
      'Could not load the user information. Please restart the app. \n\n If you see this error message after signup, please email us at contact.storywood@gmail.com and we will fix it for you. We value as a user and we want you to share your recommendations with us';
  static const String futureBuilderNotLoadingMessage =
      'Could not load the newsfeed. Please go to the Collection tab and back to trigger a refresh.';
  static const String aboutTitle = 'About';
  static const String contactUsTitle = 'Contact us';
  static const String tourTitle = 'Tour';
  static const String appVersionMessage = 'Storywood app version: ';
  static const String aboutMessage =
      ' \n\nThis product uses the TMDb API but is not endorsed or certified by TMDb.';
  static const String contactUsMessage =
      ' \nDid you find a bug?\nIs there a new feature you would like to see?\nEmail us at:\n';
  static const String reportTitle = 'Report issue';
  static const String reportMessage =
      ' \nStorywood has a zero tolerance policy towards offensive behaviour. Follow the link to report a user or content that you found offensive:';
  static const String deleteAccountTitle = 'Delete account';
  static const String deleteAccountMessage =
      ' \n We are sorry to see you go. Follow the link to delete your account:';

  static const String drawerLogout = 'Logout';
  static const String drawerNotFound = 'Not found';
  static const String archivedMessage = 'Archived';
  static const String archiveIconLabel = 'Archive';
  static const String privacyPolicyHyperlink =
      'Storywood privacy policy and T&C';
  static const String deleteAccountHyperlinkText = 'Delete Storywood account';
}

/// strings used in the newsfeed screen
class ConstStringTipScreen {
  ConstStringTipScreen._();
  static const String archivedMessage =
      ConstStringNewsfeedScreen.archivedMessage;
  static const String contentTypeMovie = 'movie info';
  static const String contentTypeTvSeries = 'tv-series info';
  static const String contentTypeBook = 'book info';
  static const String contentTypePodcast = 'podcast info';

  static const String archiveTipMenuItem = 'archive tip';
  static const String userNotFound = ConstStringNewsfeedScreen.drawerNotFound;
  static const String sendMessageLabel = 'Type here...';
  static const String theOneWhoSentTheTipLabel = 'Tip creator';
  static const String muteNotificationsLabel = 'Mute notifications';
  static const String playlistTileLabel = 'Playlists';
  static const String addNewPlaylistLabel = 'Add new playlist';
  static const String userCanVoteLabel = 'Tap to vote';
  static const String userHasNotYetVotedLabel = 'No vote yet';
  static const String dummyStringToMakeIfStatementHappy = 'dummy';
}

/// strings used in the content screen
class ConstStringContentScreen {
  ConstStringContentScreen._();
  static const String noTrailerMessage = 'No trailer available';
  static const String noTitleMessage = 'No title available';
  static const String noYearMessage = 'No year available';
  static const String noOverviewMessage = 'No overview available.';
  static const String streamingSectionTitle = 'Streaming';
  static const String releaseDateSectionTitle = 'Release Date';
  static const String streamingAvailabilityMessage =
      'This content is available in';
  static const String releaseDateMessage = 'Released in';
  static const String streamingNoAvailabilityMessage =
      'Content not available for streaming in your country';
  static const String castSectionTitle = 'Cast';
  static const String overviewSectionTitle = 'Overview';
  static const String bookAuthor = 'Author(s):';
  static const String bookGenre = 'Genre:';
  static const String bookPages = 'Pages:';
  static const String bookPublisher = 'Publisher:';
  static const String podcastItunesButton = 'Listen on iTunes';
  static const String podcastHost = 'Host(s):';
  static const String podcastGenre = 'Genre:';
  static const String podcastOverview = 'Overview:';
  static const String readMoreTextMore = ' show more';
  static const String readMoreEllipsisMore = ' ...more';
  static const String readMoreTextLess = ' show less';
  static const String previewBook = 'Preview e-book';
  static const String buyBook = 'Buy e-book';
}

/// strings used in the user profile screen
class ConstStringUserProfileScreen {
  ConstStringUserProfileScreen._();
  static const String screenTitle = 'Profile';
  static const String bottomSheetChangeUserImageTitle = 'Edit your picture';
  static const String pickImageFromGalleryLabel = 'Choose from gallery';
  static const String takePhotoLabel = 'Take photo';
  // static const String submitImageLabel = 'Submit';
  static const String errorDialogTitle = 'Loading error';
  static const String centerErrorMessage =
      'User profile not available, please try again later';
  static const String tabNamePosts = 'Posts';
  static const String tabNameCollections = 'Collections';
  static const String tabNameGenres = 'Favourite genres';
  static const String tabNameTopRecommendations = 'Top recommendations';
  static const String selectGenresScreenTitle = 'Select genres';
  static const String selectTopRecommendationsScreenTitle =
      'Select top recommendations';
  static const String futureBuilderNotLoadingMessage =
      'Unfortunately we could not load the posts. Please check your connection and try again later.';
  static const String futureBuilderPlaylistsNotLoadingMessage =
      'Unfortunately we could not load the collections. Please check your connection and try again later.';
  static const String snapshotErrorFetchTipsToChooseTop =
      'Unfortunately we could not load the posts. Please make sure you have created posts visible to all friends or public. If yes, please check your connection and try again later.';
  static const String topRecommendationsTipPrivacyWarning =
      'Only posts with privacy setting "All friends" or "Public" can be selected as top recommendations.';
  static const String noFavouriteGenresMessageMyProfile =
      'Oops! It looks like you are still in the sea of undecided.🌊 You can use edit button above to select your favourite genres.';
  static const String noTopTipsMessageMyProfile =
      'Know something awesome that others should not miss? 🌟 Share your gems! Drop your top picks here and help fellow explorers discover something fantastic.';
  static const String noCollectionsToDisplay =
      'Are you a curator at heart? 🎬📚✨ Gather your all-time favorites and create a collection that will wow the crowd! When creating a collection you can set privacy settings. Your current and future friends will be able to see here collections which you shared with public or all friends.';
  static const String noPostsToDisplay =
      'Kickstart your sharing journey! 🚀 Press on New Tip button and share your first recommendation: a must-see movie, a cannot-put-down book, a podcast that changed your perspective, or a binge-worthy TV series. Your taste can guide someone to their next favorite!';
}

/// strings used in the filters screen
class ConstStringFiltersScreen {
  ConstStringFiltersScreen._();
  static const String screenTitle = 'Filters';
  static const String applyFiltersButton = 'Apply filters';
  static const String clearAllButton = 'Clear all';
  static const String contentTypeLabel = 'Content type:';
  static const String tipTypeLabel = 'Tip type:';
  static const String contentStatusLabel = 'Content status:';
  static const String archivedTipsLabel = 'Show archived tips';
  static const String cupertinoChoosePlaylist = 'Choose playlists';
  static const String closePlaylist = 'Close';
  static const String noPlaylistDialogTitle = 'No playlists';
  static const String noPlaylistDialogBody =
      'You do not have any playlists at the moment. You can create one from any tip.';
}

/// strings used in the filters screen
class ConstStringPostScreen {
  ConstStringPostScreen._();
  static const String screenTitlePost = 'Post';
  static const String screenTitleBookmark = 'Bookmark';
  static const String emptyString = '';
  static const String loadingError = 'Loading error';
  static const String errorMessage1 =
      'Unfortunately we could not load the post. Please try again later.';
  static const String errorMessage2 =
      'Unfortunately we could not load the post due to connection issues. Please try again later.';
  static const String commentsBottomSheetTitleNewsfeedScreen = 'Comments';
  static const String commentsBottomSheetTitlePostScreen = 'Add a new comment';
  static const String commentsBottomSheetNoCommentsLine1 = 'No comments yet';
  static const String commentsBottomSheetNoCommentsLine2 =
      'Start the conversation.';
  static const String tipPrivacyModalBottomSheetTitle =
      'Who can see this post?';
}

/// Constants used in the new tip screen
class ConstNewTipScreen {
  ConstNewTipScreen._();
  static const String screenTitleNewTip = 'New tip';
  static const String screenTitleDiscover = 'Discover';
  static const String shareButton = 'Share';
  static const String commentLabel = 'Comment:';
  static const String shareCondemnationLabel = 'Condemn';
  static const String shareRecommendationLabel = 'Recommend';
  static const String tagFriendsLabel = 'Tag friends';
  static const String chooseFriendsLabel = 'Choose friends:';
  static const privacyStatusIcon = CupertinoIcons.lock;

  static const String tipPrivacyStatusDisplayedPublic = 'Public';
  static const String tipPrivacyStatusDisplayedAllFriends = 'Only friends';
  static const String tipPrivacyStatusDisplayedTaggedFriends =
      'Only tagged friends';

  static const List<String> tipPrivacyStatusOptionsDisplayed = [
    tipPrivacyStatusDisplayedTaggedFriends,
    tipPrivacyStatusDisplayedAllFriends,
    tipPrivacyStatusDisplayedPublic,
  ];

  static const String tipPrivacyInAppTourMessage =
      'You can control the visibility of your post with this drop down button. \n\n You can make the post Public so that anyone on the platform can see. \n\n You can also select so that Only tagged friends can see it.';

  static const String saveLabel = 'Save';

  static const String sendButton = 'Send';
  static const String clearButton = 'Clear';
  static const String shareWithLabel = 'Share with:';
  static const String contentTypeLabel = 'Content type:';
  static const String titleLabel = 'Title:';
  static const String searchForMovies = 'search for movies';
  static const String searchForTvSeries = 'search for TV-series';
  static const String searchForBooks = 'search for books';
  static const String searchForPodcast = 'search for podcasts';

  static const String noContentFoundMessage =
      'Your query returned no results, please try a different name';
  static const String shareWithAlertTitle = 'No friends were tagged';
  static const String shareWithAlertMessage =
      'Please tag at least one friend or adjust privacy settings to make post visible to all friends or public.';
  static const String titleAlertTitle = 'Title not valid';
  static const String titleAlertMessage = 'Please search for content ';
  static const String commentAlertTitle = 'No comment added';
  static const String commentAlertMessage =
      'You are about to create a tip without a comment. If you do not add a comment, we will add content overview instead of it. If you want to proceed just press "Send".';

  static const String commentOverwriteStartingWord = 'Overview: ';
  static const String podcastNoIdOldMessage = 'Podcast API has no ID';
  static const String bookNoIdOldMessage = 'Book API has no ID';
  static const List<Widget> tipType = [
    FittedBox(
      child: Text(
        '$clapEmoji Recommendation',
      ),
    ),
    FittedBox(
      child: Text(
        'Condemnation $poopEmoji',
      ),
    ),
  ];
  static const List<String> contentTypes = [
    constContentTypeMovie,
    constContentTypeTv,
    constContentTypePodcast,
    constContentTypeBook
  ];
  static const String shareWithDefaultValue = 'select friends';
  static const String contentTypeDefaultValue = constContentTypeMovie;
  static const String tipTypeRecommendation = 'Recommendation';
  static const String tipTypeCondemnation = 'Condemnation';
}

class ConstTipScreen {
  ConstTipScreen._();
  static const String tipStatusNotStarted = 'Not started';
  static const String tipStatusInProgress = 'In progress';
  static const String tipStatusFinished = 'Finished';
  static const String tipStatusNotInterested = 'Not interested';
  static const List<String> tipStatusOptions = [
    tipStatusNotStarted,
    tipStatusInProgress,
    tipStatusFinished,
    tipStatusNotInterested
  ];
}

class ConstPlaylistStatus {
  ConstPlaylistStatus._();
  static const String playlistStatusActive = 'Active';
  static const String playlistStatusDeleted = 'Deleted';
}

/// strings to be used in the alert dialogs throughtout the app
class ConstStringAlertDialog {
  ConstStringAlertDialog._();
  static const String genericTitle = 'An error occurred!';
  static const String newTipErrorMessage =
      'This is probably because you are offline. Storywood does not work offline (yet).';
  static const String archiveTipTitle = 'Are you sure?';
  static const String archiveTipBody =
      'You will be able to see the archived tips by selecting "Show archived tips" in the filters';
  static const String okayButton = 'Okay';
  static const String yesButton = 'Yes';
  static const String noButton = 'No';
  static const String closeButton = 'Close';
  static const String cancelButton = 'Cancel';
  static const String sendTipWithoutCommentButton = 'Send';
  static const String newPlaylistErrorTitle = 'Playlist';
  static const String newPlaylistErrorMessage = 'Playlist name must be unique';
}

class ConstStringCastScreen {
  ConstStringCastScreen._();
  static const String screenTitle = 'credits';
  static const String noInfo = 'No info to show';
  static const String futureBuilderError =
      'This page is not available at the moment, please try again later';
}

// TEXTSTYLE //
class ConstCupertinoDialog {
  ConstCupertinoDialog._();
  static const TextStyle title = TextStyle(fontFamily: 'ios');
  static const TextStyle message = TextStyle(
    fontFamily: 'ios',
  );
  static const TextStyle closeButton = TextStyle(
    fontFamily: 'ios',
  );
  static const TextStyle yes = TextStyle(
    fontFamily: 'ios',
  );
  static const TextStyle no = TextStyle(
    fontFamily: 'ios',
  );
}

class ConstMaterialDialog {
  ConstMaterialDialog._();
  static const TextStyle title = ConstCupertinoDialog.title;
  static const TextStyle message = ConstCupertinoDialog.message;
  static const TextStyle closeButton = ConstCupertinoDialog.closeButton;
  static const TextStyle yes = ConstCupertinoDialog.yes;
  static const TextStyle no = ConstCupertinoDialog.no;
}

// used for both text and icons on button (but not for the icon button)
const double constButtonFontSize = 18;

const constBigEmoji = TextStyle(fontSize: 48);

const constAppTitle = TextStyle(
  fontFamily: 'AbrilFatface',
  letterSpacing: 1,
  fontSize: 48,
  fontWeight: FontWeight.w100,
  color: Colors.white,
);

const constCupertinoTextFieldPrefix =
    TextStyle(fontFamily: 'ios', fontSize: 16, color: Colors.black);

const constCupertinoTextFieldInput = constCupertinoTextFieldPrefix;

const constCupertinoElevatedButtonLightText =
    TextStyle(fontFamily: 'ios', fontSize: 14, color: Colors.white);

const constCupertinoElevatedButtonDarkText = TextStyle(
    fontFamily: 'ios', fontSize: constButtonFontSize, color: Colors.black);

const constCupertinoDropdownButton = TextStyle(
    fontFamily: 'ios', fontSize: constButtonFontSize, color: Colors.black);

const constCupertinoDropdownExpanded = TextStyle(
    fontFamily: 'ios', fontSize: constButtonFontSize, color: Colors.black);

const constCupertinoSegmentedControl = TextStyle(
    fontFamily: 'ios', fontSize: constButtonFontSize, color: Colors.white);

const constCupertinoDropdownButtonLight = TextStyle(
    fontFamily: 'ios', fontSize: constButtonFontSize, color: Colors.white);

const constMaterialTextInputLabel =
    TextStyle(fontFamily: 'ios', color: Colors.black);

const constMaterialTextFieldInput = constCupertinoTextFieldInput;

const constMaterialElevatedButtonLightText =
    constCupertinoElevatedButtonLightText;

const constMaterialElevatedButtonDarkText =
    constCupertinoElevatedButtonDarkText;

const constMaterialDropdownButton = constMaterialDropdownExpanded;

const constMaterialDropdownExpanded = TextStyle(
  fontFamily: 'ios',
  fontSize: 18,
  color: Color.fromARGB(255, 102, 102, 102),
);

const constMaterialDropdownLight = TextStyle(
  fontFamily: 'ios',
  fontSize: 18,
  color: Color.fromARGB(255, 255, 255, 255),
);

const constNewTipScreenWidgetLabel = TextStyle(
  fontFamily: 'ios',
  fontSize: 14,
  color: Colors.white70,
);

const constNewTipScreenMaterialWidgetText = TextStyle(
    fontFamily: 'ios',
    fontSize: 18,
    color: Colors.black,
    overflow: TextOverflow.ellipsis);

const constAuthScreenWelcomeToStorywood = TextStyle(
  color: Colors.white,
  fontSize: 40,
  fontFamily: 'AbrilFatface',
  fontWeight: FontWeight.normal,
  letterSpacing: 0.5,
);

const constAuthScreenTextInputError = TextStyle(
  fontFamily: 'ios',
  fontSize: 10,
);

const constTextButtonLightUnderline = TextStyle(
    decoration: TextDecoration.underline,
    fontSize: 14,
    color: Colors.white,
    fontFamily: 'ios');

const constTextButtonDarkUnderline = TextStyle(
    decoration: TextDecoration.underline,
    fontSize: 14,
    color: Colors.black,
    fontFamily: 'ios');

const constTextButtonDark =
    TextStyle(fontSize: 16, color: Colors.black, fontFamily: 'ios');

const constTextButtonDarkSmall =
    TextStyle(fontSize: 14, color: Colors.black, fontFamily: 'ios');

const constSmallTextButtonLight =
    TextStyle(fontSize: 14, color: Colors.white, fontFamily: 'ios');
const constTextButtonLight =
    TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'ios');

const constSnackBarText =
    TextStyle(fontSize: 14, color: Colors.black, fontFamily: 'ios');

const constTopBar =
    TextStyle(fontSize: 28, fontFamily: 'ios', color: Colors.white);

const constBodyLargeDark =
    TextStyle(fontSize: 20, fontFamily: 'ios', color: Colors.black);

const constCupertinoAlertYesButton =
    TextStyle(fontFamily: 'ios', color: Colors.blueAccent);

const constCupertinoCreateCollectionSaveButton = TextStyle(
    fontFamily: 'ios', color: Colors.blueAccent, fontWeight: FontWeight.bold);

const constHyperlink = TextStyle(
    fontSize: 14,
    fontFamily: 'ios',
    color: Colors.blueAccent,
    decoration: TextDecoration.underline);

const constBodyLargeLight = TextStyle(
  fontFamily: 'ios',
  fontSize: 20,
  color: Colors.white,
  fontWeight: FontWeight.w500,
);

const constBodyMediumLight =
    TextStyle(fontSize: 18, fontFamily: 'ios', color: Colors.white70);

const constBodyMediumWhite =
    TextStyle(fontSize: 18, fontFamily: 'ios', color: Colors.white);

const constBodyMediumDark =
    TextStyle(fontSize: 18, fontFamily: 'ios', color: Colors.black);

const constBodyMediumBoldDark = TextStyle(
    fontSize: 18,
    fontFamily: 'ios',
    color: Colors.black,
    fontWeight: FontWeight.bold);

const constChatLight =
    TextStyle(fontSize: 16, fontFamily: 'ios', color: Colors.white);

const constChatDark =
    TextStyle(fontSize: 16, fontFamily: 'ios', color: Colors.black);

const constBodySmallLight = TextStyle(
  fontFamily: 'ios',
  fontSize: 14,
  color: Colors.white70,
);

const constBodySmallWhite = TextStyle(
  fontFamily: 'ios',
  fontSize: 14,
  color: Colors.white,
);

const constFilterScreenBodySmallLight = TextStyle(
  fontFamily: 'ios',
  fontSize: 18,
  color: Colors.white70,
);

const constNotificationBodyLight = TextStyle(
  fontFamily: 'ios',
  fontSize: 14,
  color: Colors.white70,
);

const constNotificationBodyLightBold = TextStyle(
  fontFamily: 'ios',
  fontWeight: FontWeight.bold,
  fontSize: 14,
  color: Colors.white70,
);

const constTitleSmallLightBold = TextStyle(
    fontFamily: 'ios',
    fontWeight: FontWeight.bold,
    fontSize: 16,
    color: Colors.white,
    letterSpacing: 0.5);

const constTitleMediumLightBold = TextStyle(
  fontFamily: 'ios',
  fontSize: 22,
  color: Colors.white,
  fontWeight: FontWeight.bold,
);

const constLabelSmallLight = TextStyle(
    fontFamily: 'ios', fontSize: 16, color: Colors.white, letterSpacing: 0.5);

const constLabelSmallDark = TextStyle(
    fontFamily: 'ios', fontSize: 16, color: Colors.black, letterSpacing: 0.5);

const constDisplaySmallDark = TextStyle(
    fontFamily: 'ios',
    fontSize: 10,
    color: Color.fromARGB(255, 102, 102, 102),
    letterSpacing: 0.5);

const constAuthCardLegalLink = TextStyle(
  fontFamily: 'ios',
  fontSize: 10,
  color: Color.fromARGB(255, 102, 102, 102),
  letterSpacing: 0.5,
  decoration: TextDecoration.underline,
);

const constDisplayMediumLight = TextStyle(
    fontFamily: 'ios', fontSize: 12, color: Colors.white, letterSpacing: 0.5);

const constDisplayMediumGrey = TextStyle(
    fontFamily: 'ios',
    fontSize: 12,
    color: Color.fromARGB(255, 102, 102, 102),
    letterSpacing: 0.5);

const constChatNewMessageLight = TextStyle(
  fontFamily: 'ios',
  fontSize: 14,
  color: Colors.white,
);
const constChatNewMessageDark = TextStyle(
  fontFamily: 'ios',
  fontSize: 14,
  color: Colors.black,
);

const constDisplaySmallBlack = TextStyle(
    fontFamily: 'ios', fontSize: 10, color: Colors.black, letterSpacing: 0.5);

const constDisplaySmallWhite = TextStyle(
    fontFamily: 'ios', fontSize: 10, color: Colors.white, letterSpacing: 0.5);

const constFilterScreenClearAllButtonText = TextStyle(
  fontFamily: 'ios',
  color: Color.fromARGB(255, 168, 168, 168),
  fontSize: 18,
  // decoration: TextDecoration.underline,
);

const constNewTipScreenClearAllButtonText = TextStyle(
  fontFamily: 'ios',
  color: Color.fromARGB(255, 168, 168, 168),
  fontSize: 18,
  // decoration: TextDecoration.underline,
);
const constVotesTipScreen = TextStyle(fontSize: 48);
const constTipMenuScreenEmojiiInDropdown = TextStyle(fontSize: 24);

TextStyle constTourTextLight(mediaQueryHeight) => TextStyle(
      fontFamily: 'ios',
      fontSize: mediaQueryHeight * 0.03146, //28,
      color: Colors.white,
    );

const constTourButtonLight = TextStyle(
  fontFamily: 'ios',
  fontSize: 18,
  color: Colors.white,
);
TextStyle constTextButtonDarkMediaQuery({required double mediaQuerywidth}) =>
    TextStyle(
        fontSize: mediaQuerywidth * 0.035,
        color: Colors.black,
        fontFamily: 'ios');

TextStyle constTextButtonDarkSmallMediaQuery(
        {required double mediaQuerywidth}) =>
    TextStyle(
        fontSize: mediaQuerywidth * 0.03,
        color: Colors.black,
        fontFamily: 'ios');

TextStyle constSmallTextButtonLightMediaQuery(
        {required double mediaQuerywidth}) =>
    TextStyle(
        fontSize: mediaQuerywidth * 0.03,
        color: Colors.white,
        fontFamily: 'ios');

TextStyle constPlaylistGridTextLight(mediaQueryHeight) => TextStyle(
      fontFamily: 'ios',
      fontSize: mediaQueryHeight * 0.021,
      color: Colors.white,
    );

TextStyle constNewCollectionAlertTite(mediaQueryHeight) => TextStyle(
    fontFamily: 'ios',
    fontSize: mediaQueryHeight * 0.023,
    color: Colors.black,
    letterSpacing: 0.5);

TextStyle constNewCollectionAlertHintMediumDark(mediaQueryHeight) => TextStyle(
    fontFamily: 'ios',
    fontSize: mediaQueryHeight * 0.021,
    color: Colors.black54,
    letterSpacing: 0.5);

TextStyle constNewCollectionInputMediumDark(mediaQueryHeight) => TextStyle(
    fontFamily: 'ios',
    fontSize: mediaQueryHeight * 0.021,
    color: Colors.black,
    letterSpacing: 0.5);

TextStyle constNewCollectionButtons(mediaQueryHeight) => TextStyle(
    fontFamily: 'ios',
    fontSize: mediaQueryHeight * 0.019,
    color: Colors.black,
    letterSpacing: 0.5);

TextStyle constSinglePlaylistErrorMessage(mediaQueryHeight) => TextStyle(
    fontFamily: 'ios',
    fontSize: mediaQueryHeight * 0.025,
    color: Colors.white,
    letterSpacing: 0.5);

TextStyle constSinglePlaylistIconSubtitle(mediaQueryHeight) => TextStyle(
    fontFamily: 'ios',
    fontSize: mediaQueryHeight * 0.018,
    color: Colors.white,
    letterSpacing: 0.5);

TextStyle constSinglePlaylistStatusButtonCupertino(mediaQueryHeight) =>
    TextStyle(
      fontFamily: 'ios',
      fontSize: mediaQueryHeight * 0.018,
      color: Colors.white,
    );

const constSinglePlaylistFilterLight = TextStyle(
  fontFamily: 'ios',
  fontSize: 18,
);

////////////
// COLORS //
////////////

// background color of the appbar (android) and navigation bar (ios)
const constTopBarBackgroundColor = Colors.black;

const constScaffoldBackground = Colors.black;
// this is the background color used for tiles in newsfeed item, notification item, and search delegate
const constTileBackground = Colors.black;

const constChatBubbleLight = Colors.white;
const constChatBubbleDark = constHintColor;

const constListDivider = Colors.grey;
const constCupertinoSlidingSegmentedControlThumb = Colors.grey;
const constTipMenuScreenSwitchNoNotifications = Colors.red;
const constTipMenuScreenSwitchYesNotifications = Colors.green;
const constTipMenuScreenPlaylistCupertinoInactiveSwitch = Colors.grey;

const constTipMenuScreenPlaylistCupertinoActiveSwitch = Colors.green;
final constFriendsScreenTabBackground = Colors.grey.shade800;

const constHintColor = Colors.white12;

const constSimpleNotificationBackground = Colors.black;
const constSimpleNotificationForeground = Colors.white;

const constCircularProgressIndicatorWhite = Colors.white;
const constCircularProgressIndicatorBlack = Colors.black;
const constAuthScreenShowHidePasswordIcon = Colors.grey;
const constAuthScreenCard = Colors.white;

const constAuthScreenElevatedButtonForeground = Colors.white;
const constAuthScreenElevatedButtonBackground = Colors.black87;
const constMaterialDropDownBackgroundDark = Colors.black;
const constElevatedButtonForegroundDark = Colors.black;
const constElevatedButtonBackgroundDark = Colors.black;
final constElevatedButtonBackgroundGrey = Colors.grey[200];
const constElevatedButtonBackgroundLight = Colors.white;
const constCircleAvatarBackgroundLight = Colors.white;
const constCircleAvatarBackgroundDark = Colors.black;
final constNewTipScreenWidgets = Colors.grey[200];
const constNewTipScreenWidgetsInactive = Color.fromARGB(255, 72, 72, 72);
const constNewTipScreenAndroidCommentBorder = Colors.white;
const constFilterScreenToggleActiveText = Colors.white;
final constFilterScreenToggleActiveFill = Colors.grey[850];
const constFilterScreenCheckboxBorder = Colors.white;
const constFilterScreenCheckboxMark = Colors.black;
const constFilterScreenCheckboxFill = Colors.white;
const constFilterScreenCheckboxBorderBlack = Colors.black;
const constFilterScreenCheckboxMarkWhite = Colors.white;
const constFilterScreenCheckboxFillBlack = Colors.black;
const constFilterScreenCheckboxTile = Colors.black;
const constFilterScreenMaterialClearAllButton =
    Color.fromARGB(255, 168, 168, 168);
final constRejectFriendRequestButtonBackground = Colors.grey.shade500;
const constFilterScreenToggleInactiveText = Colors.white70;
const constModalBottomSheetDefaultBackground = Colors.black;

const constCursorColorDark = Colors.black;
const constCursorColorLight = Colors.white70;

const constIconColorLight = Colors.white;
const constIconColorDark = Colors.black;

const constMaterialAlertDialogButton = Colors.black;
const constMaterialTextFieldUnderline = Colors.black;
final constMaterialDropdownButtonUnderline = Colors.white.withOpacity(0.5);

const constContentScreenGradient1 = Color.fromARGB(255, 0, 0, 0);
const constContentScreenGradient2 = Color.fromARGB(150, 0, 0, 0);

const constClickableText = Colors.blueAccent;
const constClickableDarkGrey = Color.fromARGB(255, 83, 81, 81);
const constYoutubePlayerColor = Colors.redAccent;

final constTransparentColorForBlurredBackground = Colors.black.withOpacity(0);

///////////
// ICONS //
///////////
const constAuthScreenCupertinoShowPasswordIcon = CupertinoIcons.eye_fill;
const constAuthScreenCupertinoHidePasswordIcon = CupertinoIcons.eye_slash_fill;
const constEmailCupertinoIcon = CupertinoIcons.envelope_fill;
const constMultiSelectDropdownCupertinoIcon = CupertinoIcons.ellipsis_circle;
const constClearTextFieldCupertinoIcon = CupertinoIcons.clear;
const constBackButtonCupertinoIcon = CupertinoIcons.back;
const constBellCupertinoIcon = CupertinoIcons.bell_solid;
const constFilterCupertinoIcon = CupertinoIcons.slider_horizontal_3;
const constArchiveCupertinoIcon = CupertinoIcons.archivebox;
const constLogoutCupertinoIcon = constLogoutMaterialIcon;
const constAboutCupertinoIcon = CupertinoIcons.info_circle;
const constContactUsCupertinoIcon = CupertinoIcons.at;
const constReportCupertinoIcon = CupertinoIcons.exclamationmark_triangle;
const constDeletAccountCupertinoIcon = CupertinoIcons.bin_xmark;
const constTourCupertinoIcon = CupertinoIcons.map;
// const constContactUsCupertinoIcon = CupertinoIcons.bubble_left_bubble_right;
// const constContactUsCupertinoIcon = CupertinoIcons.captions_bubble;
// const constContactUsCupertinoIcon = CupertinoIcons.envelope;
// const constContactUsCupertinoIcon = CupertinoIcons.exclamationmark_bubble;

const constCupertinoSendMessageIcon = CupertinoIcons.paperplane_fill;
const constCupertinoAddPlaylistIcon = CupertinoIcons.plus_app;
const constSearchCupertinoIcon = CupertinoIcons.search;
const constPictureGalleryCupertinoIcon = constPictureGalleryMaterialIcon;
const constTakePhotoCupertinoIcon = constTakePhotoMaterialIcon;
const constSubmitCupertinoIcon = constSubmitMaterialIcon;

const constAddPlaylistCupertinoIcon = constAddPlaylistMaterialIcon;

const constTagFriendsCupertinoIcon = constTagFriendsMaterialIcon;
const constCommentCupertinoIcon = constCommentMaterialIcon;

const constAuthScreenMaterialShowPasswordIcon =
    constAuthScreenCupertinoShowPasswordIcon;
const constAuthScreenMaterialHidePasswordIcon =
    constAuthScreenCupertinoHidePasswordIcon;
const constBellMaterialIcon = constBellCupertinoIcon;
const constFilterMaterialIcon = Icons.filter_alt;
const constArchiveMaterialIcon = constArchiveCupertinoIcon;
const constLogoutMaterialIcon = Icons.logout;
const constAboutMaterialIcon = constAboutCupertinoIcon;
const constContactUsMaterialIcon = constContactUsCupertinoIcon;

const constMaterialDropdownIcon = Icons.keyboard_double_arrow_down_sharp;
const constClearTextFieldMaterialIcon = constClearTextFieldCupertinoIcon;
const constBackButtonMaterialIcon = Icons.arrow_back;
const constMaterialSendMessageIcon = Icons.send;
const constMaterialAddPlaylistIcon = constCupertinoAddPlaylistIcon;
const constSearchMaterialIcon = constSearchCupertinoIcon;

const constPictureGalleryMaterialIcon = Icons.image;
const constTakePhotoMaterialIcon = Icons.camera_alt;
const constSubmitMaterialIcon = Icons.upload;

const constAddPlaylistMaterialIcon = Icons.library_add;
const constAddMaterialIcon = Icons.add;
const constRemoveMaterialIcon = Icons.remove_circle_outline;
const constThreeDotsHorizontalMaterialIcon = Icons.more_horiz;

const constTagFriendsMaterialIcon = Icons.people;

const constCommentMaterialIcon = Icons.chat_rounded;

const String poopEmoji = '💩';

const String heartEmoji = '❤️';

const String clapEmoji = '👏';

// the icons used througout the app for the content types
Map<String, IconData> constContentIcons = {
  constContentTypeMovie: CupertinoIcons.video_camera,
  constContentTypeTv: CupertinoIcons.tv,
  constContentTypePodcast: CupertinoIcons.mic,
  constContentTypeBook: CupertinoIcons.book
};

// the icons used througout the app for thumbs up or down
Map<String, IconData> constThumbsIcons = {
  ConstNewTipScreen.tipTypeRecommendation: Icons.thumb_up_alt_outlined,
  ConstNewTipScreen.tipTypeCondemnation: Icons.thumb_down_alt_outlined,
};

// the icons used througout the app for tip privacy settings
Map<String, IconData> constPrivacyIcons = {
  constTipPrivacySelfTip: CupertinoIcons.lock,
  constTipPrivacyTaggedFriends: CupertinoIcons.person_fill,
  constTipPrivacyAllFriends: CupertinoIcons.person_2_fill,
  constTipPrivacyPublic: CupertinoIcons.globe,
};

// the icons used througout the app for playlist privacy settings
Map<String, IconData> constPlaylistPrivacyIcons = {
  constPlaylistPrivacyPrivate: CupertinoIcons.lock,
  constPlaylistPrivacyTaggedFriends: CupertinoIcons.person_fill,
  constPlaylistPrivacyAllFriends: CupertinoIcons.person_2_fill,
  constPlaylistPrivacyPublic: CupertinoIcons.globe,
};
