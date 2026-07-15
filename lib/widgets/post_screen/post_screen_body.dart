import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../models/tip_class.dart';
import '../../data/theme_data.dart';
import './comments_list.dart';
import './tagged_friends.dart';
import '../newsfeed_screen/post_item.dart';

class PostScreenBody extends StatelessWidget {
  PostScreenBody({super.key, required this.tip});
  final Tip tip;

  final ScrollController controller =
      ScrollController(initialScrollOffset: 0, keepScrollOffset: true);

  Widget bodyInput(Tip tip) {
    return SingleChildScrollView(
      physics: const ScrollPhysics(),
      controller: controller,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          PostItem(tip: tip, callFromNewsfeed: false),
          if (tip.sentTo!.isNotEmpty &&
              tip.sentTo!.length > 1 &&
              tip.tipPrivacy != constTipPrivacyAllFriends &&
              tip.tipPrivacy != constTipPrivacyPublic)
            TaggedFriendsOutput(
              sentTo: tip.sentTo ?? [],
              sentBy: tip.sentBy ?? ConstStringPostScreen.emptyString,
            ),
          CommentsList(
              tipId: tip.id ?? ConstStringPostScreen.emptyString,
              controller: controller),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String screenTitle = tip.tipPrivacy == constTipPrivacySelfTip
        ? ConstStringPostScreen.screenTitleBookmark
        : ConstStringPostScreen.screenTitlePost;
    return Platform.isIOS
        ? CupertinoPageScaffold(
            backgroundColor: constScaffoldBackground,
            navigationBar: CupertinoNavigationBar(
              backgroundColor: constTopBarBackgroundColor,
              middle: Text(
                screenTitle,
                style: constTopBar,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            child: Material(
              color: constScaffoldBackground,
              child: bodyInput(tip),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: constTopBarBackgroundColor,
              centerTitle: constIsAppBarTitleNotCentered,
              title: Text(
                screenTitle,
                style: constTopBar,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            body: bodyInput(tip),
          );
  }
}
