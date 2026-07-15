import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/theme_data.dart';
import './android_ios_picker.dart';
import '../screens/newsfeed_screen.dart';
import '../providers/navigation_bar_provider.dart';
import '../providers/new_tip_provider.dart';

/// empty all the providers
void resetProviders(WidgetRef ref) {
  // empty the list of selected playlists
  ref.read(playlistNewTipProvider.notifier).resetProvider();
// empty the list of tagged friends
  ref.read(tagFriendsProvider.notifier).resetProvider();
  // reset the default value of the search widget
  ref
      .read(queryResultNewTipProvider.notifier)
      .assignQueryResult('search for movies');

// reset the content type to movie
  ref
      .read(contentTypeSelectionNewTipProvider.notifier)
      .assignContentTypeSelection(ConstNewTipScreen.contentTypeDefaultValue);

  // reset the comment to empty string
  ref.read(commentNewTipProvider.notifier).assignComment('');

  // reset the tip privacy status to default value
  ref
      .read(tipPrivacyStatusNewTipProvider.notifier)
      .assignPrivacyStatus(constTipPrivacyAllFriends);
}

/// navigate to newsfeed screen and reset the index of the bottom navigation bar
void goToHomeScreen(BuildContext ctx, ref) {
  // update the provider for the bottom navigation bar
  ref
      .read(bottomNavigationBarIndexProvider.notifier)
      .updatebottomNavigationBarIndexNotifier(
          constHomeScreenBottomNavigationBarIndex);

  // go to home screen
  Navigator.of(ctx).pushNamed(NewsfeedScreen.routeName);
}

Widget _iosVersion(ref, context) {
  return Material(
    child: Container(
      color: constScaffoldBackground,
      child: _androidVersion(ref, context),
    ),
  );
}

Widget _androidVersion(ref, context) {
  return IconButton(
    onPressed: () {
      resetProviders(ref);
      goToHomeScreen(context, ref);
    },
    icon: Icon(
      ConstBottomNavigationBar.newsfeedScreenIcon,
      color: constIconColorLight,
      size: MediaQuery.of(context).size.height * 0.029,
    ),
  );
}

class HomeButton extends StatelessWidget {
  const HomeButton({super.key, required this.ref});
  final WidgetRef ref;
  @override
  Widget build(BuildContext context) {
    return androidIosPicker(
        androidVersion: _androidVersion(ref, context),
        iosVersion: _iosVersion(ref, context));
  }
}
