import 'package:flutter/material.dart';

import '../../data/theme_data.dart';
import '../../models/tip_class.dart';
import '../choose_thumbs_icon.dart';

class PostPrivacyButton extends StatelessWidget {
  const PostPrivacyButton(
      {super.key, required this.tip, required this.sentByUsername});
  final Tip tip;
  final String sentByUsername;

  @override
  Widget build(BuildContext context) {
    // privacy status icon tooltip messages
    Map<String, String> constPrivacyTooltipMessages = {
      constTipPrivacySelfTip:
          'Only you can see this post or add it to your collection (including collections shared with others)',
      constTipPrivacyTaggedFriends:
          'Only tagged people can see this post or add it to their collection (including collections shared with others)',
      constTipPrivacyAllFriends:
          'Only $sentByUsername\'s friends can see this post or add it to their collection (including collections shared with others)',
      constTipPrivacyPublic: 'Anyone on the platform can see this post.',
    };

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    buildBottomSheet({required context}) {
      return showModalBottomSheet(
        enableDrag: true,
        useSafeArea: true, //ensures we leave padding on the top
        isScrollControlled: true,
        context: context,
        builder: ((BuildContext context) {
          return Container(
            color: constScaffoldBackground,
            padding: EdgeInsets.fromLTRB(
                screenWidth * 0.03,
                MediaQuery.of(context).viewInsets.top,
                screenWidth * 0.03,
                MediaQuery.of(context).viewInsets.bottom +
                    MediaQuery.of(context).viewPadding.bottom),
            child: Wrap(children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //title
                  Padding(
                    padding: EdgeInsets.all(screenHeight * 0.01),
                    child: const Text(
                      ConstStringPostScreen.tipPrivacyModalBottomSheetTitle,
                      style: constBodyLargeLight,
                    ),
                  ),
                  const Divider(
                    color: Colors.grey,
                    thickness: 0.5,
                  ),
                  //post privacy message
                  Padding(
                    padding: EdgeInsets.all(screenHeight * 0.01),
                    child: Text(
                      constPrivacyTooltipMessages[tip.tipPrivacy!] ?? '',
                      style: constBodyMediumWhite,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ]),
          );
        }),
      );
    }

    return Padding(
        padding: EdgeInsets.fromLTRB(0, 0, screenWidth * 0.0196, 0),
        child: IconButton(
            onPressed: () {
              buildBottomSheet(context: context);
            },
            icon: ChoosePrivacyIcon(
              tipPrivacy: tip.tipPrivacy!,
              iconSize: screenWidth * 0.055,
            )));
  }
}
