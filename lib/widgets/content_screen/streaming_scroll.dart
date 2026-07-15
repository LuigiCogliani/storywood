import 'dart:io';

import 'package:flutter/material.dart';

import '../../data/theme_data.dart';

/// checks if the type of streaming service is not of google sort
bool isNotGoogle({required Map streamingPlatformEntity}) {
  return !streamingPlatformEntity['providerName']
      .toString()
      .toLowerCase()
      .contains('google');
}

/// checks whtether or not the streaming object is empty
/// and returns a widget accordingly
Widget streamingCardOrSingleSizedBox(
    {required Map streamingPlatformEntity, required double cardHeight}) {
  if (streamingPlatformEntity.isNotEmpty) {
    return StreamingProviderCardAndName(
        cardHeight: cardHeight,
        streamingPlatformEntity: streamingPlatformEntity);
  } else {
    return const SingleWidthSizedBox();
  }
}

class StreamingScroll extends StatelessWidget {
  final List<Map> streamingPlatforms;
  final double cardHeight;
  final double mediaQueryWidth;
  final double mediaQueryHeight;
  const StreamingScroll(
      {required this.streamingPlatforms,
      required this.cardHeight,
      required this.mediaQueryWidth,
      required this.mediaQueryHeight,
      super.key});
  @override
  Widget build(BuildContext context) {
    // don't believe the linter, streamingPlatforms can be null!!!!
    if ((streamingPlatforms.isEmpty) || (streamingPlatforms == null)) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: mediaQueryWidth * 0.05),
        child: const Text(
            ConstStringContentScreen.streamingNoAvailabilityMessage,
            style: constBodySmallLight),
      );
    } else {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: mediaQueryWidth * 0.02),
        child: SizedBox(
          // the bit after cardHeight is to account for the text with the straming type
          height: cardHeight + (mediaQueryHeight * 0.02),
          child: ListView.builder(
            shrinkWrap: true,
            // horizontal scroll
            scrollDirection: Axis.horizontal,
            itemCount: streamingPlatforms.length,
            itemBuilder: (context, index) {
              final streamingPlatformEntity = streamingPlatforms[index];
              /**
               * We will return the card only if the following conditions
               * are met:
               * if the platform is ios, the streaming service has not to be
               * google AND the streaming object is not empty
               * If the platform is android then anthing goes :)
               
               */
              if (Platform.isIOS) {
                if (isNotGoogle(
                    streamingPlatformEntity: streamingPlatformEntity)) {
                  return streamingCardOrSingleSizedBox(
                      cardHeight: cardHeight,
                      streamingPlatformEntity: streamingPlatformEntity);
                } else {
                  return const SingleWidthSizedBox();
                }
              }
              // if we are in android
              else {
                return streamingCardOrSingleSizedBox(
                    cardHeight: cardHeight,
                    streamingPlatformEntity: streamingPlatformEntity);
              }
            },
          ),
        ),
      );
    }
  }
}

/// a sized box with width 1
class SingleWidthSizedBox extends StatelessWidget {
  const SingleWidthSizedBox({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 1,
    );
  }
}

class StreamingProviderCardAndName extends StatelessWidget {
  const StreamingProviderCardAndName({
    super.key,
    required this.cardHeight,
    required this.streamingPlatformEntity,
  });

  final double cardHeight;
  final Map streamingPlatformEntity;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamingProviderCard(
            cardHeight: cardHeight,
            streamingPlatformEntity: streamingPlatformEntity),
        Text(
          streamingPlatformEntity['streamingType'],
          style: constDisplaySmallWhite,
          overflow: TextOverflow.ellipsis,
        )
      ],
    );
  }
}

class StreamingProviderCard extends StatelessWidget {
  const StreamingProviderCard({
    super.key,
    required this.cardHeight,
    required this.streamingPlatformEntity,
  });

  final double cardHeight;
  final Map streamingPlatformEntity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ClipRRect(
          borderRadius: const BorderRadius.all(
            Radius.circular(8),
          ),
          child: Container(
            height: cardHeight,
            width: cardHeight,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('${streamingPlatformEntity['logoUrl']}' ??
                    constDefaultImageMisingPlaceholder),
                fit: BoxFit.cover,
              ),
            ),
          )),
    );
  }
}
