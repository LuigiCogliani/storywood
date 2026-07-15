import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/tip_class.dart';
import '../../data/theme_data.dart';
import '../../widgets/choose_content_icon.dart';
import '../../providers/users_provider_riverpod.dart';

class UserProfilePostSearchTile extends ConsumerWidget {
  const UserProfilePostSearchTile({super.key, required this.tip});
  final Tip tip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double screenHeight = MediaQuery.of(context).size.height;
    List<String> topRecommendationIds =
        ref.watch(userInfoProvider)?.topRecommendationIds ?? ['placeholder'];
    bool tipTopRecommendationSelected =
        (topRecommendationIds.contains(tip.id) ? true : false);
    return InkWell(
      onTap: () {
        if (tipTopRecommendationSelected == false) {
          ref
              .read(userInfoProvider.notifier)
              .addTopRecommendationId(tip.id ?? '');
        } else {
          ref
              .read(userInfoProvider.notifier)
              .removeTopRecommendationId(tip.id ?? '');
        }
      },
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.all(2),
            child: Image.network(
              tip.imageUrl ?? constDefaultImageMisingPlaceholder,
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              color: Colors.black.withOpacity(0.8),
              width: double.infinity,
              child: Text(
                tip.title!,
                style: constDisplaySmallWhite,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
                padding: const EdgeInsets.all(7),
                child: ChooseContentIcon(
                    contentType: tip.contentType!,
                    iconSize: screenHeight * 0.03)),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Checkbox(
              activeColor: Colors.blue,
              checkColor: Colors.white,
              //fillColor: MaterialStatePropertyAll(Colors.white),
              shape: const CircleBorder(),
              side: const BorderSide(color: Colors.white),
              value: tipTopRecommendationSelected,
              onChanged: (bool? newValue) {
                if (newValue!) {
                  ref
                      .read(userInfoProvider.notifier)
                      .addTopRecommendationId(tip.id ?? '');
                } else {
                  ref
                      .read(userInfoProvider.notifier)
                      .removeTopRecommendationId(tip.id ?? '');
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
