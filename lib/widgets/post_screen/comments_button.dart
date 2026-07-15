import 'package:flutter/material.dart';

import '../../data/theme_data.dart';
import '../../models/tip_class.dart';
import './new_comment_input.dart';
import './tagged_friends.dart';
import './comments_list.dart';

class CommentsButton extends StatefulWidget {
  const CommentsButton(
      {super.key, required this.tip, required this.callFromNewsfeed});
  final Tip tip;
  final bool callFromNewsfeed;

  @override
  State<CommentsButton> createState() => _CommentsButtonState();
}

class _CommentsButtonState extends State<CommentsButton> {
  final ScrollController controller =
      ScrollController(initialScrollOffset: 0, keepScrollOffset: true);

  @override
  Widget build(BuildContext context) {
    final String tipId = widget.tip.id ?? ConstStringPostScreen.emptyString;

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    buildBottomSheet({required context}) {
      return showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(screenHeight * 0.02)),
        ),
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
                    child: Text(
                      widget.callFromNewsfeed
                          ? ConstStringPostScreen
                              .commentsBottomSheetTitleNewsfeedScreen
                          : ConstStringPostScreen
                              .commentsBottomSheetTitlePostScreen,
                      style: constBodyLargeLight,
                    ),
                  ),
                  const Divider(
                    color: Colors.grey,
                    thickness: 0.5,
                  ),
                  //tagged friends
                  if (widget.callFromNewsfeed == true &&
                      widget.tip.sentTo!.isNotEmpty &&
                      widget.tip.sentTo!.length > 1 &&
                      widget.tip.tipPrivacy != constTipPrivacyAllFriends &&
                      widget.tip.tipPrivacy != constTipPrivacyPublic)
                    TaggedFriendsOutput(
                      sentBy: widget.tip.sentBy ??
                          ConstStringPostScreen.emptyString,
                      sentTo: widget.tip.sentTo ?? [],
                    ),
                  if (widget.callFromNewsfeed == true &&
                      widget.tip.sentTo!.isNotEmpty &&
                      widget.tip.sentTo!.length > 1 &&
                      widget.tip.tipPrivacy != constTipPrivacyAllFriends &&
                      widget.tip.tipPrivacy != constTipPrivacyPublic)
                    const Divider(
                      color: Colors.grey,
                      thickness: 0.5,
                    ),
                  //comments list
                  if (widget.callFromNewsfeed == true)
                    SizedBox(
                        height: screenHeight > 600
                            ? screenHeight * 0.3
                            : screenHeight * 0.22,
                        child:
                            CommentsList(tipId: tipId, controller: controller)),
                  //new comment input
                  NewCommentInput(
                    tipId: tipId,
                    sentToUserIds: widget.tip.sentTo ?? [],
                    imageUrl: widget.tip.imageUrl ??
                        constDefaultImageMisingPlaceholder,
                  )
                ],
              ),
            ]),
          );
        }),
      );
    }

    return IconButton(
        onPressed: () {
          buildBottomSheet(context: context);
        },
        icon: const Icon(constCommentMaterialIcon, color: constIconColorLight));
  }
}
