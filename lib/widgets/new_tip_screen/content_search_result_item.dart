import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/theme_data.dart';
import '../../providers/tips_list_provider_riverpod.dart';

import '../material_wrapped.dart';

class ContentSearchResultItem extends StatelessWidget {
  const ContentSearchResultItem(
      {super.key,
      required this.ref,
      required this.contentId,
      required this.screenWidth,
      required this.screenHeight,
      required this.imageUrl,
      required this.overview,
      required this.title,
      required this.year,
      required this.contentType,
      this.podcastUrl = ''});
  final WidgetRef ref;
  final String contentId;
  final double screenWidth;
  final double screenHeight;
  final String imageUrl;
  final String title;
  final String year;
  final String overview;
  final String contentType;
  final String podcastUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: constTileBackground,
      child: MaterialWrapped(
        child: InkWell(
          onTap: () {
            ref.read(tipListProvider.notifier).navigateToContentScreen(
                context: context,
                contentType: contentType,
                contentId: contentId,
                podcastUrl: podcastUrl);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.001,
              vertical: screenHeight * 0.0005,
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.01),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                        height: screenHeight * 0.12,
                        width: screenWidth * 0.15,
                        child: Image.network(imageUrl, fit: BoxFit.fitWidth)),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        '$title ($year)',
                        overflow: TextOverflow.ellipsis,
                        style: constBodyMediumWhite,
                      ),
                      Text(
                        overview,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: constBodySmallLight,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
