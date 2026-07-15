import 'package:flutter/material.dart';

import '../data/theme_data.dart';

class ChooseContentIcon extends StatelessWidget {
  ChooseContentIcon(
      {required this.contentType, required this.iconSize, super.key});
  final String contentType;
  double iconSize;
  @override
  Widget build(BuildContext context) {
    //final double mediaQueryHeight = MediaQuery.of(context).size.height;
    IconData? icon;

    if (contentType == constContentTypeMovie) {
      icon = constContentIcons[constContentTypeMovie];
      iconSize = iconSize * 1.3;
    } else if (contentType == constContentTypeTv) {
      icon = constContentIcons[constContentTypeTv];
    } else if (contentType == constContentTypePodcast) {
      icon = constContentIcons[constContentTypePodcast];
    } else if (contentType == constContentTypeBook) {
      icon = constContentIcons[constContentTypeBook];
    }
    return Icon(
      icon,
      size: iconSize,
      color: constIconColorLight,
    );
  }
}
