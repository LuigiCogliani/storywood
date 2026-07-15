import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../data/theme_data.dart';

class ChooseThumbsIcon extends StatelessWidget {
  const ChooseThumbsIcon(
      {required this.tipType, required this.iconSize, super.key});
  final String tipType;
  final double iconSize;
  @override
  Widget build(BuildContext context) {
    //final double mediaQueryHeight = MediaQuery.of(context).size.height;
    IconData? icon;

    if (tipType == ConstNewTipScreen.tipTypeRecommendation) {
      icon = constThumbsIcons[ConstNewTipScreen.tipTypeRecommendation];
    } else {
      icon = constThumbsIcons[ConstNewTipScreen.tipTypeCondemnation];
    }
    return Icon(
      icon,
      size: iconSize,
      color: constIconColorLight,
    );
  }
}

class ChoosePrivacyIcon extends StatelessWidget {
  const ChoosePrivacyIcon(
      {required this.tipPrivacy, required this.iconSize, super.key});
  final String tipPrivacy;
  final double iconSize;
  @override
  Widget build(BuildContext context) {
    IconData? icon;

    if (tipPrivacy == constTipPrivacySelfTip) {
      icon = constPrivacyIcons[constTipPrivacySelfTip];
    } else if (tipPrivacy == constTipPrivacyTaggedFriends) {
      icon = constPrivacyIcons[constTipPrivacyTaggedFriends];
    } else if (tipPrivacy == constTipPrivacyAllFriends) {
      icon = constPrivacyIcons[constTipPrivacyAllFriends];
    } else {
      icon = constPrivacyIcons[constTipPrivacyPublic];
    }
    return Icon(
      icon,
      size: iconSize,
      color: constIconColorLight,
    );
  }
}

class ChoosePlayistPrivacyIcon extends StatelessWidget {
  const ChoosePlayistPrivacyIcon(
      {required this.playlistPrivacy, required this.iconSize, super.key});
  final String playlistPrivacy;
  final double iconSize;
  @override
  Widget build(BuildContext context) {
    IconData? icon;

    if (playlistPrivacy == constPlaylistPrivacyPrivate) {
      icon = constPlaylistPrivacyIcons[constPlaylistPrivacyPrivate];
    } else if (playlistPrivacy == constPlaylistPrivacyTaggedFriends) {
      icon = constPlaylistPrivacyIcons[constPlaylistPrivacyTaggedFriends];
    } else if (playlistPrivacy == constPlaylistPrivacyAllFriends) {
      icon = constPlaylistPrivacyIcons[constPlaylistPrivacyAllFriends];
    } else {
      icon = constPlaylistPrivacyIcons[constPlaylistPrivacyPublic];
    }
    return Icon(
      icon,
      size: iconSize,
      color: constIconColorLight,
    );
  }
}
