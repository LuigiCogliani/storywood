import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/theme_data.dart';
import '../android_ios_picker.dart';
import '../../screens/newsfeed_screen.dart';
import '../../providers/navigation_bar_provider.dart';

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
  return Column(
    children: [
      IconButton(
        onPressed: () {
          goToHomeScreen(context, ref);
        },
        icon: Icon(
          ConstBottomNavigationBar.newsfeedScreenIcon,
          color: constIconColorLight,
          size: MediaQuery.of(context).size.height * 0.040,
        ),
      ),
      Text(
        ConstBottomNavigationBar.newsfeedScreen,
        style:
            constSinglePlaylistIconSubtitle(MediaQuery.of(context).size.height),
      )
    ],
  );
}

class SinglePlaylistHomeButton extends StatelessWidget {
  const SinglePlaylistHomeButton({super.key, required this.ref});
  final WidgetRef ref;
  @override
  Widget build(BuildContext context) {
    return androidIosPicker(
        androidVersion: _androidVersion(ref, context),
        iosVersion: _iosVersion(ref, context));
  }
}
