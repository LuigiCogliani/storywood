import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import '../widgets/android_ios_picker.dart';

import '../data/theme_data.dart';

/// Use this widget to create an appbar title object to use throughout the app with title and subtitle in a smaller font.
/// If the title is too long it will scale from fontsize 22 down to titleMinFontSize, and default to ellipsis after that
class AppBarTitleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final double titleMinFontSize;
  final double subtitleFontSize;
  final bool isClickable;
  final String route;
  const AppBarTitleTile(
      {required this.title,
      required this.subtitle,
      required this.titleMinFontSize,
      required this.subtitleFontSize,
      required this.isClickable,
      required this.route,
      super.key});

  @override
  Widget build(BuildContext context) {
    return androidIosPicker(
      androidVersion: ListTile(
        title: AutoSizeText(
          title,
          maxLines: 1,
          minFontSize: titleMinFontSize,
          maxFontSize: 22,
          style: constTitleMediumLightBold,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
              color: Colors.grey,
              fontSize: subtitleFontSize,
              overflow: TextOverflow.ellipsis),
        ),
      ),
      iosVersion: Column(children: [
        AutoSizeText(
          title,
          maxLines: 1,
          minFontSize: titleMinFontSize,
          maxFontSize: 22,
          style: const TextStyle(color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          subtitle,
          style: TextStyle(
              color: Colors.grey,
              fontSize: titleMinFontSize,
              overflow: TextOverflow.ellipsis),
        )
      ]),
    );
  }
}
