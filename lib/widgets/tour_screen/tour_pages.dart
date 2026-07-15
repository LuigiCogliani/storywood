import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../data/theme_data.dart';
import '../../providers/navigation_bar_provider.dart';
import '../../screens/newsfeed_screen.dart';
import './tour_single_page.dart';

class TourPages extends ConsumerStatefulWidget {
  const TourPages({super.key, required this.tourSeenStatus});
  final bool tourSeenStatus;

  @override
  ConsumerState<TourPages> createState() => _TourPagesState();
}

class _TourPagesState extends ConsumerState<TourPages> {
  final controller = PageController();
  bool isLastPage = false;
  static const totalNumberOfTourPages = 6;

  Widget buildBottomSheet(
      {required double mediaQueryHeight, required double mediaQueryWidth}) {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: mediaQueryWidth * 0.025),
      height: mediaQueryHeight * 0.08,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: mediaQueryWidth * 0.15,
          ),
          Center(
            child: SmoothPageIndicator(
              controller: controller,
              count: totalNumberOfTourPages,
              effect: ScrollingDotsEffect(
                dotWidth: mediaQueryWidth * 0.025,
                dotHeight: mediaQueryWidth * 0.025,
                spacing: mediaQueryWidth * 0.025,
                activeDotColor: Colors.white,
              ),
              onDotClicked: (index) => controller.animateToPage(
                index,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeIn,
              ),
            ),
          ),
          isLastPage
              ? widget.tourSeenStatus
                  ? TextButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushReplacementNamed(NewsfeedScreen.routeName);
                      },
                      child: const Text(ConstStringTourScreen.homeTextButton,
                          style: constTourButtonLight),
                    )
                  : TextButton(
                      onPressed: () async {
                        ref.read(tourProvider.notifier).turnTourToSeen();
                      },
                      child: const Text(ConstStringTourScreen.enterTextButton,
                          style: constTourButtonLight),
                    )
              : TextButton(
                  key: const Key('skipTour'),
                  onPressed: () {
                    widget.tourSeenStatus
                        ? controller.jumpToPage(totalNumberOfTourPages - 1)
                        : ref.read(tourProvider.notifier).turnTourToSeen();
                  },
                  child: const Text(ConstStringTourScreen.skipTextButton,
                      style: constTourButtonLight),
                ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double mediaQueryHeight = MediaQuery.of(context).size.height;
    final double mediaQueryWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: constScaffoldBackground,
      body: Container(
        padding: EdgeInsets.only(bottom: mediaQueryHeight * 0.09),
        child: PageView(
            controller: controller,
            onPageChanged: (index) {
              setState(() {
                isLastPage = index == totalNumberOfTourPages - 1;
              });
            },
            children: [
              TourSinglePage(
                text: ConstStringTourScreen.page1Text,
                imagePath: Platform.isIOS
                    ? ConstStringTourScreen.page1ImageCupertino
                    : ConstStringTourScreen.page1ImageMaterial,
              ),
              TourSinglePage(
                text: ConstStringTourScreen.page2Text,
                imagePath: Platform.isIOS
                    ? ConstStringTourScreen.page2ImageCupertino
                    : ConstStringTourScreen.page2ImageMaterial,
              ),
              TourSinglePage(
                text: ConstStringTourScreen.page3Text,
                imagePath: Platform.isIOS
                    ? ConstStringTourScreen.page3ImageCupertino
                    : ConstStringTourScreen.page3ImageMaterial,
              ),
              TourSinglePage(
                text: ConstStringTourScreen.page4Text,
                imagePath: Platform.isIOS
                    ? ConstStringTourScreen.page4ImageCupertino
                    : ConstStringTourScreen.page4ImageMaterial,
              ),
              TourSinglePage(
                text: ConstStringTourScreen.page5Text,
                imagePath: Platform.isIOS
                    ? ConstStringTourScreen.page5ImageCupertino
                    : ConstStringTourScreen.page5ImageMaterial,
              ),
              TourSinglePage(
                text: ConstStringTourScreen.page6Text,
                imagePath: Platform.isIOS
                    ? ConstStringTourScreen.page6ImageCupertino
                    : ConstStringTourScreen.page6ImageMaterial,
              ),
            ]),
      ),
      bottomSheet: buildBottomSheet(
          mediaQueryHeight: mediaQueryHeight, mediaQueryWidth: mediaQueryWidth),
    );
  }
}
