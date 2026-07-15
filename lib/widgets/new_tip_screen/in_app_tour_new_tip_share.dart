import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../data/theme_data.dart';

List<TargetFocus> newTipShareScreenTargets(
    {required GlobalKey tipPrivacyStatusKey}) {
  List<TargetFocus> targets = [];

  //Add a target for tip privacy status dropdown
  targets.add(TargetFocus(
    keyTarget: tipPrivacyStatusKey,
    alignSkip: Alignment.topRight, //controls where to position Skip button
    radius: 10,
    shape: ShapeLightFocus
        .RRect, //controls the shape around the highlighted object
    contents: [
      TargetContent(
        align: ContentAlign.bottom,
        builder: (context, controller) {
          return Container(
            padding: const EdgeInsets.only(top: 50, left: 50, right: 50),
            alignment: Alignment.center,
            child: const Text(
              ConstNewTipScreen.tipPrivacyInAppTourMessage,
              textAlign: TextAlign.center,
              style: constBodyLargeLight,
            ),
          );
        },
      )
    ], //controls the message
  ));

  return targets;
}
