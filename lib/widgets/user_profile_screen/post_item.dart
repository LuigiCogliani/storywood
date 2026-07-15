import 'package:flutter/material.dart';

import '../../models/tip_class.dart';
import '../../data/theme_data.dart';
import '../../widgets/choose_content_icon.dart';
import '../../screens/post_screen.dart';
import '../choose_thumbs_icon.dart';

class UserProfilePostItem extends StatelessWidget {
  const UserProfilePostItem({super.key, required this.tip});
  final Tip tip;

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(
          PostScreen.routeName,
          arguments: [tip.id, tip],
        );
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
              child: Row(
                children: [
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 2, 0),
                      child: ChooseThumbsIcon(
                          tipType: tip.tipType!,
                          iconSize: screenHeight * 0.02)),
                  Expanded(
                    child: Text(
                      tip.title!,
                      style: constDisplaySmallWhite,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
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
        ],
      ),
    );
  }
}
