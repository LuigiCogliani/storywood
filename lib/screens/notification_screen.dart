import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/theme_data.dart';
import '../widgets/notifications_screen/notification_list.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});
  static const routeName = '/notification-screen';

  PreferredSizeWidget _buildNotificationsAppBar(
      {required MediaQueryData mediaQuery}) {
    return AppBar(
        centerTitle: constIsAppBarTitleNotCentered,
        backgroundColor: constTopBarBackgroundColor,
        toolbarHeight: (mediaQuery.size.height - mediaQuery.padding.top) * 0.12,
        title: const SizedBox(
          width: double.infinity,
          child: Text(ConstStringNotificationsScreen.screenTitle,
              textAlign: TextAlign.left, style: constTopBar),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Platform.isIOS
        ? CupertinoPageScaffold(
            backgroundColor: constScaffoldBackground,
            navigationBar: const CupertinoNavigationBar(
              backgroundColor: constTopBarBackgroundColor,
              middle: Text(
                ConstStringNotificationsScreen.screenTitle,
                style: constTopBar,
              ),
            ),
            child: SizedBox(
                height:
                    (mediaQuery.size.height - mediaQuery.padding.top) * 0.88,
                child: Material(
                    child: Container(
                        color: constScaffoldBackground,
                        child: const NotificationList()))),
          )
        : Scaffold(
            backgroundColor: constScaffoldBackground,
            appBar: _buildNotificationsAppBar(mediaQuery: mediaQuery),
            body: SizedBox(
                height:
                    (mediaQuery.size.height - mediaQuery.padding.top) * 0.88,
                child: const NotificationList()));
  }
}
