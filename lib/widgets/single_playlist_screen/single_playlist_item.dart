import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:irina_storywood_mockup/providers/playlist_provider.dart';

import '../../screens/post_screen.dart';
import '../../models/tip_class.dart';
import '../../models/playlist_class.dart';
import '../../providers/users_provider_riverpod.dart';
import '../../data/theme_data.dart';
import '../choose_content_icon.dart';
import './single_playlist_tip_status.dart';
import './single_playlist_bookmark.dart';

class SinglePlaylistItem extends ConsumerWidget {
  const SinglePlaylistItem(
      {super.key,
      required this.tip,
      required this.playlist,
      required this.myPlaylistInterface});
  final Tip tip;
  final Playlist playlist;
  final bool myPlaylistInterface;

  ///Function redirects to Post screen
  void _selectPostScreen(BuildContext ctx, Tip tip) {
    Navigator.of(ctx).pushNamed(
      PostScreen.routeName,
      arguments: [tip.id, tip],
    );
  }

  Widget _buildPoster(String posterLink, double mediaQueryWidth,
      String contentType, double mediaQueryHeight) {
    // check that the url is not empty to prevent the next statement from throwing an error
    if (posterLink.isNotEmpty) {
      // turn "http" into "https" to prevent "Content-Length must contain only digits" error
      if (posterLink.substring(0, 5) == 'http:') {
        posterLink = '${posterLink.substring(0, 4)}s${posterLink.substring(4)}';
      }
    }
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(posterLink),
              fit: BoxFit.cover,
            ),
            border: Border(
              right: BorderSide(width: mediaQueryWidth * 0.02),
            ),
          ),
          alignment: Alignment.center,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: CircleAvatar(
              minRadius: mediaQueryWidth * 0.035,
              maxRadius: mediaQueryWidth * 0.035,
              backgroundColor: constCircleAvatarBackgroundDark,
              child: ChooseContentIcon(
                  contentType: contentType, iconSize: mediaQueryHeight * 0.02),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildTitle(String contentTitleInput, context, double titleHeight,
      String contentTypeInput, mediaQuery, tipType) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: mediaQuery.size.width * 0.02),
        ),
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: mediaQuery.size.width * 0.65,
            child: Text(
              contentTitleInput,
              style: constTitleSmallLightBold,
              textAlign: TextAlign.left,
              overflow:
                  TextOverflow.ellipsis, //crops the text and adds three dots
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusAndBookmark(
      {required Tip loadedTip, required String userId}) {
    dynamic alignment;

    if (myPlaylistInterface) {
      alignment = MainAxisAlignment.spaceBetween;
    } else {
      alignment = MainAxisAlignment.end;
    }
    return Row(
      mainAxisAlignment: alignment,
      children: [
        if (myPlaylistInterface)
          SinglePlaylistTipStatusDropdown(
            loadedTip: loadedTip,
            userId: userId,
          ),
        SinglePlaylistBookmark(
            tip: tip, screenPlaylistId: playlist.id, iconScalingFactor: 0.03),
      ],
    );
  }

  Widget _buildMessagesBox(String originalComment, username, context,
      titleHeight, loadedTip, userId) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          alignment: Alignment.topLeft,
          child: Text(
            originalComment.substring(
                        0,
                        min(
                            originalComment.length,
                            ConstNewTipScreen
                                .commentOverwriteStartingWord.length)) ==
                    ConstNewTipScreen.commentOverwriteStartingWord
                ? originalComment
                : '$username: $originalComment',
            style: constBodySmallWhite,
            textAlign: TextAlign.left,
            overflow:
                TextOverflow.ellipsis, //crops the text and adds three dots
            maxLines: 3,
          ),
        ),
      ],
    );
  }

  // customize the BG of the dimissible widget
  Widget _buildDismissableBackground(mediaQueryHeight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                constRemoveMaterialIcon,
                color: constIconColorLight,
                size: mediaQueryHeight * 0.05,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  ConstStringSinglePlaylistScreen.removeIconTitle,
                  style: constLabelSmallLight,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInkWellChildOfDismissible(
      {required context,
      required tip,
      required itemHeight,
      required titleHeight,
      required mediaQuery,
      required sentByUsername,
      required ref,
      required userId}) {
    // wrap InkWell with material to make it work in both android and ios
    return InkWell(
      onTap: () => _selectPostScreen(context, tip),
      child: SizedBox(
        height: itemHeight,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Hero(
                  tag: tip.id,
                  child: _buildPoster(tip.imageUrl, mediaQuery.size.width,
                      tip.contentType, mediaQuery.size.height)),
            ),
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Expanded(
                      flex: 1,
                      child: _buildTitle(tip.title, context, titleHeight,
                          tip.contentType, mediaQuery, tip.tipType)),
                  Expanded(
                      flex: 3,
                      child: _buildMessagesBox(tip.originalComment,
                          sentByUsername, context, titleHeight, tip, userId)),
                  Expanded(
                      flex: 1,
                      child: _buildStatusAndBookmark(
                          loadedTip: tip, userId: userId)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final String? userId = ref.read(userInfoProvider)?.userId;

    final sentByUsername = ref
        .read(usernameProvider.notifier)
        .convertUseridToUsername(sentBy: tip.sentBy!);

    //Size variables

    final itemHeight = (mediaQueryHeight - mediaQuery.padding.top) * 0.9 * 0.2;

    final titleHeight = (mediaQueryHeight - mediaQuery.padding.top) *
        0.9 *
        0.2 /
        3; //divider determined by flex between title and messages, currently 1:2

    return Column(children: [
      Dismissible(
          confirmDismiss: (direction) {
            return showDialog(
                context: context,
                builder: (ctx) {
                  const String title =
                      ConstStringSinglePlaylistScreen.removeTipAlertDialogTitle;
                  const String content = ConstStringSinglePlaylistScreen
                      .removeTipAlertDialogContent;
                  return Platform.isIOS
                      ? CupertinoAlertDialog(
                          title: const Text(title),
                          content: const Text(content),
                          actions: [
                            CupertinoDialogAction(
                              isDestructiveAction: true,
                              onPressed: () {
                                ref
                                    .read(playlistProvider.notifier)
                                    .updatePlaylistInFirebase(
                                        playlistId: playlist.id,
                                        tipId: tip.id!,
                                        checkboxState: false,
                                        tipImageUrl: tip.imageUrl!,
                                        ref: ref,
                                        removeTipSinglePlaylistProvider: true);

                                Navigator.of(ctx).pop(true);
                                // remove the tip from homeScreenTitle
                              },
                              child: const Text(
                                ConstStringAlertDialog.yesButton,
                              ),
                            ),
                            CupertinoDialogAction(
                              onPressed: () {
                                Navigator.of(ctx).pop(false);
                              },
                              child:
                                  const Text(ConstStringAlertDialog.noButton),
                            ),
                          ],
                        )
                      : AlertDialog(
                          title: const Text(ConstStringSinglePlaylistScreen
                              .removeTipAlertDialogTitle),
                          content: const Text(ConstStringSinglePlaylistScreen
                              .removeTipAlertDialogContent),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop(false);
                                },
                                child: const Text(
                                  ConstStringAlertDialog.noButton,
                                  style: constTextButtonDark,
                                )),
                            TextButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop(true);
                                },
                                child: const Text(
                                  ConstStringAlertDialog.yesButton,
                                  style: constTextButtonDark,
                                ))
                          ],
                        );
                });
          },
          key: ValueKey(tip.id),
          background: _buildDismissableBackground(mediaQueryHeight),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            ref.read(playlistProvider.notifier).updatePlaylistInFirebase(
                playlistId: playlist.id,
                tipId: tip.id!,
                checkboxState: false,
                tipImageUrl: tip.imageUrl!,
                ref: ref,
                removeTipSinglePlaylistProvider: true);
          },
          child: _buildInkWellChildOfDismissible(
              context: context,
              itemHeight: itemHeight,
              mediaQuery: mediaQuery,
              sentByUsername: sentByUsername,
              tip: tip,
              titleHeight: titleHeight,
              ref: ref,
              userId: userId)),
      const Divider(
        color: constListDivider,
      )
    ]);
  }
}
