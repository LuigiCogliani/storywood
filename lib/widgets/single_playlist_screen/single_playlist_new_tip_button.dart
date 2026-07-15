import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/theme_data.dart';
import '../android_ios_picker.dart';
import '../../screens/new_tip_search_screen.dart';
import '../../providers/navigation_bar_provider.dart';

/// navigate to newsfeed screen and reset the index of the bottom navigation bar
void goToNewTipScreen(BuildContext ctx, ref) {
  // update the provider for the bottom navigation bar
  ref
      .read(bottomNavigationBarIndexProvider.notifier)
      .updatebottomNavigationBarIndexNotifier(
          constNewTipScreenBottomNavigationBarIndex);

  // go to new tip screen
  const bool isNewTipScreen = true;
  Navigator.of(ctx)
      .pushNamed(NewTipSearchScreen.routeName, arguments: [isNewTipScreen]);
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
          goToNewTipScreen(context, ref);
        },
        icon: Icon(
          ConstBottomNavigationBar.newTipScreenIcon,
          color: constIconColorLight,
          size: MediaQuery.of(context).size.height * 0.040,
        ),
      ),
      Text(
        ConstBottomNavigationBar.newTipScreen,
        style:
            constSinglePlaylistIconSubtitle(MediaQuery.of(context).size.height),
      )
    ],
  );
}

class SinglePlaylistNewTipButton extends StatelessWidget {
  const SinglePlaylistNewTipButton({super.key, required this.ref});
  final WidgetRef ref;
  @override
  Widget build(BuildContext context) {
    return androidIosPicker(
        androidVersion: _androidVersion(ref, context),
        iosVersion: _iosVersion(ref, context));
  }
}
