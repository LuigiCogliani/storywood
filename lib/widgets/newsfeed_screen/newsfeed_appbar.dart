import 'package:flutter/material.dart';

import '../../screens/notification_screen.dart';
import '../../data/theme_data.dart';

///Function redirects to Notifications screen
void _selectNotificationBell(BuildContext ctx) {
  Navigator.of(ctx).pushNamed(
    NotificationScreen.routeName,
  );
}

///Newsfeed app bar widget
PreferredSizeWidget buildNewsfeedAppBar(
    Key feedTabKey, MediaQueryData mediaQuery, BuildContext context, ref) {
  const double iconScalingFactor = 0.04;

  return AppBar(
      // set size and color of the drawer icon
      iconTheme: IconThemeData(
          size: mediaQuery.size.height * iconScalingFactor,
          color: constIconColorLight),
      backgroundColor: constTopBarBackgroundColor,
      toolbarHeight: (mediaQuery.size.height - mediaQuery.padding.top) * 0.12,
      title: const FittedBox(
        child: Text(ConstStringNewsfeedScreen.screenTitle,
            textAlign: TextAlign.left, style: constAppTitle),
      ),
      actions: <Widget>[
        IconButton(
          onPressed: () => _selectNotificationBell(context),
          icon: Icon(
            constBellCupertinoIcon,
            color: constIconColorLight,
            size: mediaQuery.size.height * iconScalingFactor,
          ),
        ),
      ],
      bottom: TabBar(
          key: feedTabKey,
          // color between the tab bar and the body
          indicatorColor: Colors.white,
          dividerColor: constScaffoldBackground,
          //indicatorPadding: EdgeInsets.fromLTRB(0, 10, 0, 5),
          //  indicatorSize: TabBarIndicatorSize.label,
          // indicator: BoxDecoration(
          //     borderRadius: BorderRadius.circular(5),
          //     color: constCupertinoSlidingSegmentedControlThumb),
          tabs: [
            NewsfeedTabButton(title: ConstStringNewsfeedScreen.friendsTabLabel),
            NewsfeedTabButton(title: ConstStringNewsfeedScreen.publicTabLabel),
          ]));
}

class NewsfeedTabButton extends StatelessWidget {
  NewsfeedTabButton({super.key, required this.title});
  String title;
  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Align(
        alignment: Alignment.center,
        child: Text(
          title,
          style: constBodyMediumWhite,
        ),
      ),
    );
  }
}
