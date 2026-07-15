import 'package:flutter/material.dart';
import '../../data/theme_data.dart';
import '../../models/tip_class.dart';
import '../../screens/post_screen.dart';

class UserProfileTopRecommendationItem extends StatelessWidget {
  const UserProfileTopRecommendationItem({super.key, required this.tip});
  final Tip tip;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        Navigator.of(context)
            .pushNamed(PostScreen.routeName, arguments: [tip.id, tip]);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
        child: Align(
          alignment: Alignment.center,
          child: Container(
            width: screenWidth * 0.18,
            height: screenHeight * 0.1,
            padding: const EdgeInsets.all(2),
            child: Image.network(
              tip.imageUrl ?? constDefaultImageMisingPlaceholder,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
