import 'package:flutter/material.dart';
import '../../data/theme_data.dart';

class TourSinglePage extends StatelessWidget {
  const TourSinglePage({
    super.key,
    required this.text,
    required this.imagePath,
  });

  final String text;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final double mediaQueryHeight = MediaQuery.of(context).size.height;
    final double mediaQueryWidth = MediaQuery.of(context).size.width;
    return Center(
      child: Stack(
        children: [
          Positioned(
              top: mediaQueryHeight * 0.3,
              // 0 at left and right ensure the widget is positioned in the middle
              left: 0,
              right: 0,
              child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: mediaQueryWidth * 0.05),
                  child: Image.asset(imagePath))),
          Container(
            alignment: const Alignment(-0.5, -0.71),
            padding: EdgeInsets.fromLTRB(
                mediaQueryWidth * 0.025,
                mediaQueryHeight * 0.005,
                mediaQueryWidth * 0.025,
                mediaQueryHeight * 0.05),
            child: Text(
              text,
              style: constTourTextLight(mediaQueryHeight),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
