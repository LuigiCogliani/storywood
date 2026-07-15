import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/theme_data.dart';
import './single_playlist_home_button.dart';
import './single_playlist_new_tip_button.dart';

class SinglePlaylistErrorNoTips extends ConsumerWidget {
  const SinglePlaylistErrorNoTips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double mediaQueryHeight = MediaQuery.of(context).size.height;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.all(mediaQueryHeight * 0.03),
          child: Center(
            child: Text(
              ConstStringSinglePlaylistScreen.errorMessageNoTipsPart1,
              style: constSinglePlaylistErrorMessage(mediaQueryHeight),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SinglePlaylistHomeButton(ref: ref),
        Padding(
          padding: EdgeInsets.all(mediaQueryHeight * 0.03),
          child: Center(
            child: Text(
              ConstStringSinglePlaylistScreen.errorMessageNoTipsPart2,
              style: constSinglePlaylistErrorMessage(mediaQueryHeight),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SinglePlaylistNewTipButton(ref: ref),
      ],
    );
  }
}
