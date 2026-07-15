import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readmore/readmore.dart';

import '../../models/tip_class.dart';
import '../../providers/tips_list_provider_riverpod.dart';
import '../../providers/users_provider_riverpod.dart';
import '../../data/theme_data.dart';
import '../../screens/user_profile_screen.dart';
import '../../models/user_class.dart' as storywood;

import '../single_playlist_screen/single_playlist_bookmark.dart';
import '../post_screen/comments_button.dart';
import '../choose_content_icon.dart';
import '../choose_thumbs_icon.dart';
import './post_privacy_icon.dart';

class PostItem extends ConsumerWidget {
  const PostItem(
      {super.key, required this.tip, required this.callFromNewsfeed});
  final Tip tip;
  final bool callFromNewsfeed;

  ///Generates a positive random integer uniformly distributed on the range
  ///from [min], inclusive, to [max], exclusive.
  int next({required int min, required int max}) =>
      min + Random().nextInt(max - min);

  /// turn a poster into a 16:9 image with blurred background
  Widget blurredBackdrop(
      {required double screenWidth, required String imageUrl}) {
    return SizedBox(
      width: screenWidth,
      height: screenWidth / 16 * 9,
      child:
          //Image.network(tip.imageUrl, fit: BoxFit.cover)
          Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
          ),
          ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                    color: constTransparentColorForBlurredBackground),
              ),
            ),
          ),
          Image.network(imageUrl, fit: BoxFit.fitHeight),
        ],
      ),
    );
  }

  /// if there is no backdrop, default to image,
  /// then to logo, then to poster.
  /// If you get to poster use the same format as per podcast and books
  Widget movieOrTvSeriesImage(
      {required Map info,
      required double screenWidth,
      required String posterUrl}) {
    if (info.isEmpty) {
      return blurredBackdrop(screenWidth: screenWidth, imageUrl: posterUrl);
    } else {
      return Image.network(
          info['images'][next(min: 0, max: info['images'].length)],
          fit: BoxFit.cover);
    }
  }

  /// we need to have a try catch statement that will check for the field
  /// storywoodContentId in the tip.
  String checkForStorywoodContentId({required Tip tip}) {
    try {
      // the tip was added after we started using storywood content Id, so it will have the field
      if (tip.storywoodContentId!.toString() != '') {
        return tip.storywoodContentId!.toString();
      } else {
        return tip.contentId!.toString();
      }
    } catch (error) {
      // the tip was added BEFORE we started using storywood content Id, so we will use the contentId
      return tip.contentId!.toString();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final String contentType = tip.contentType!;
    final String tipType = tip.tipType!;
// load current user ID
    String? userId = ref.read(userInfoProvider)?.userId;
    final sentByUsername = ref
        .read(usernameProvider.notifier)
        .convertUseridToUsername(sentBy: tip.sentBy!);

    final Widget specialWidget =
        // fetch the backdrop
        ((contentType == constContentTypeMovie) ||
                (contentType == constContentTypeTv))
            ? movieOrTvSeriesImage(
                info: tip.info!,
                screenWidth: screenWidth,
                posterUrl: tip.imageUrl!)
            : blurredBackdrop(
                screenWidth: screenWidth, imageUrl: tip.imageUrl!);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.0095, horizontal: 0),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                    screenWidth * 0.0293, 0, screenWidth * 0.0196, 0),
                // first commit
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(UserProfileScreen.routeName, arguments: [
                      // whether or not the user is accessing their own page
                      false,
                      // the User object
                      null,
                      // the userId of the tip sender
                      tip.sentBy!
                    ]);
                  },
                  child: CircleAvatar(
                    backgroundColor: constCircleAvatarBackgroundDark,
                    radius: 14,
                    foregroundImage: NetworkImage(
                        ref.read(usernameProvider)[tip.sentBy]['imageUrl']),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(UserProfileScreen.routeName, arguments: [
                    // whether or not the user is accessing their own page
                    false,
                    // the User object
                    null,
                    // the userId of the tip sender
                    tip.sentBy!
                  ]);
                },
                child: Text(
                  sentByUsername,
                  style: constBodyMediumWhite,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (tip.tipPrivacy !=
                  constTipPrivacySelfTip) //do not show icon for self-tips
                Padding(
                    padding: EdgeInsets.fromLTRB(screenWidth * 0.0196, 0, 0, 0),
                    child: ChooseThumbsIcon(
                        tipType: tipType, iconSize: screenWidth * 0.075)),
              Expanded(child: Container()),
              PostPrivacyButton(tip: tip, sentByUsername: sentByUsername)
            ],
          ),
        ),
        Stack(
          children: [
            InkWell(
              onTap: () {
                if (tip.contentType == constContentTypePodcast) {
                  /**The following code snippet allows us to work with both
             * podcast tips added before and after we started storing the podcast info in 
             * the database. Legacy tips will have the feedUrl. If we are dealing with a new tip
             * (i.e. one where the content data is already in firebase) then we don't need the feed url
             * and we can default to an empty string
             */
                  /// We need to initialise an empty string. If we don't do that the linter
                  /// will not recosnigse that we defined podcastUrl (even if the try catch statement will
                  /// always give us a value)

                  String podcastUrl = '';
                  try {
                    /// if we are working with a legacy tip it means we don't have this content stored.
                    /// we will need to read the feedUrl to search for the content
                    podcastUrl = tip.info!['feedUrl'];
                  } catch (error) {
                    ///if we are dealing with a new tip we don't need the feedUrl to get the content,
                    ///because we already sotred it in firebase
                    podcastUrl = '';
                  }
                  ref.read(tipListProvider.notifier).navigateToContentScreen(
                      context: context,
                      contentType: tip.contentType.toString(),
                      contentId: checkForStorywoodContentId(tip: tip),
                      podcastUrl: podcastUrl);
                } else {
                  // the non podcast contents do not need anything beside the ID
                  ref.read(tipListProvider.notifier).navigateToContentScreen(
                        context: context,
                        contentType: tip.contentType.toString(),
                        contentId: checkForStorywoodContentId(tip: tip),
                      );
                }
              },
              child: specialWidget,
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.0196),
                  child: ChooseContentIcon(
                      contentType: contentType, iconSize: screenWidth * 0.075)),
            )
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.034, vertical: screenHeight * 0.0094),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 7,
                child: Text(
                  tip.title!,
                  style: constBodyLargeLight,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CommentsButton(
                      tip: tip,
                      callFromNewsfeed: callFromNewsfeed,
                    ),
                    Padding(
                        padding:
                            EdgeInsets.fromLTRB(screenWidth * 0.05, 0, 0, 0),
                        child: SinglePlaylistBookmark(
                          tip: tip,
                          iconScalingFactor: 0.03,
                        ))
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.034, vertical: screenHeight * 0.0071),
          child: ReadMoreText(
            tip.originalComment?.substring(
                        0,
                        min(
                            tip.originalComment!.length,
                            ConstNewTipScreen
                                .commentOverwriteStartingWord.length)) ==
                    ConstNewTipScreen.commentOverwriteStartingWord
                ? tip.originalComment!
                : '$sentByUsername: ${tip.originalComment!}',
            style: constChatLight,
            trimLines: 2,
            colorClickableText: constClickableDarkGrey,
            trimMode: TrimMode.Line,
            trimCollapsedText: ConstStringContentScreen.readMoreEllipsisMore,
            trimExpandedText: ConstStringContentScreen.readMoreTextLess,
          ),
        ),
      ],
    );
  }
}
