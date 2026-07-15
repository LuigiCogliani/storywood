import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import './android_ios_picker.dart';
import './material_wrapped.dart';

import '../data/theme_data.dart';
import '../screens/new_tip_share_screen.dart';
import '../screens/new_tip_save_screen.dart';

void sendTip(
    {required isSave,
    required ref,
    required context,
    required isPoop,
    required year,
    required imageUrl,
    required overview,
    required contentType,
    required title,
    required contentId,
    required contentInfo,
    required storywoodContentId}) {
  // if we are saving the tip
  if (isSave) {
    Navigator.of(context).pushNamed(NewTipSaveScreen.routeName, arguments: [
      isPoop,
      year,
      imageUrl,
      overview,
      contentType,
      contentInfo,
      contentId,
      title,
      storywoodContentId
    ]);
  } else {
    Navigator.of(context).pushNamed(NewTipShareScreen.routeName, arguments: [
      isPoop,
      year,
      imageUrl,
      overview,
      contentType,
      contentInfo,
      contentId,
      title,
      storywoodContentId
    ]);
  }
}

Widget iconAndText(
    {required IconData icon,
    required String text,
    required context,
    required ref,
    required isSave,
    isPoop,
    year,
    required imageUrl,
    required title,
    required contentType,
    required contentInfo,
    required contentId,
    required overview,
    required storywoodContentId}) {
  return MaterialWrapped(
    child: InkWell(
      child: Container(
        color: constScaffoldBackground,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(icon, color: constIconColorLight, size: 28),
            ),
            Text(
              text,
              style: constBodyMediumWhite,
            )
          ],
        ),
      ),
      onTap: () {
        sendTip(
            isSave: isSave,
            ref: ref,
            context: context,
            isPoop: isPoop,
            year: year,
            overview: overview,
            contentId: contentId,
            contentInfo: contentInfo,
            contentType: contentType,
            imageUrl: imageUrl,
            title: title,
            storywoodContentId: storywoodContentId);
      },
    ),
  );
}

Widget adaptiveIconAndText(
    {required IconData icon,
    required String text,
    required context,
    required ref,
    required isSave,
    isPoop,
    year,
    required imageUrl,
    required title,
    required contentType,
    required contentInfo,
    required contentId,
    required overview,
    required storywoodContentId}) {
  return androidIosPicker(
      androidVersion: iconAndText(
          icon: icon,
          text: text,
          context: context,
          ref: ref,
          isSave: isSave,
          isPoop: isPoop,
          year: year,
          overview: overview,
          contentId: contentId,
          contentInfo: contentInfo,
          contentType: contentType,
          imageUrl: imageUrl,
          title: title,
          storywoodContentId: storywoodContentId),
      iosVersion: Material(
          child: iconAndText(
              icon: icon,
              text: text,
              context: context,
              ref: ref,
              isSave: isSave,
              isPoop: isPoop,
              year: year,
              overview: overview,
              contentId: contentId,
              contentInfo: contentInfo,
              contentType: contentType,
              imageUrl: imageUrl,
              title: title,
              storywoodContentId: storywoodContentId)));
}

class ThreeShareButtons extends ConsumerWidget {
  const ThreeShareButtons(
      {super.key,
      required this.year,
      required this.overview,
      required this.imageUrl,
      required this.title,
      required this.contentType,
      required this.contentInfo,
      required this.contentId,
      required this.storywoodContentId});
  final String year;
  final String overview;
  final String imageUrl;
  final String title;
  final String contentId;
  final String contentType;
  final Map contentInfo;
  final String storywoodContentId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
      color: constScaffoldBackground,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          adaptiveIconAndText(
              icon: Icons.thumb_down_alt_outlined,
              text: ConstNewTipScreen.shareCondemnationLabel,
              context: context,
              ref: ref,
              isSave: false,
              isPoop: true,
              year: year,
              overview: overview,
              contentId: contentId,
              contentInfo: contentInfo,
              contentType: contentType,
              imageUrl: imageUrl,
              title: title,
              storywoodContentId: storywoodContentId),
          adaptiveIconAndText(
              icon: Icons.bookmark,
              text: ConstNewTipScreen.saveLabel,
              context: context,
              ref: ref,
              isSave: true,
              isPoop: false,
              year: year,
              overview: overview,
              contentId: contentId,
              contentInfo: contentInfo,
              contentType: contentType,
              imageUrl: imageUrl,
              title: title,
              storywoodContentId: storywoodContentId),
          adaptiveIconAndText(
              icon: Icons.thumb_up_alt_outlined,
              text: ConstNewTipScreen.shareRecommendationLabel,
              context: context,
              ref: ref,
              isSave: false,
              isPoop: false,
              year: year,
              overview: overview,
              contentId: contentId,
              contentInfo: contentInfo,
              contentType: contentType,
              imageUrl: imageUrl,
              title: title,
              storywoodContentId: storywoodContentId)
        ],
      ),
    );
  }
}
