import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/theme_data.dart';
import '../../providers/new_tip_provider.dart';
import '../../providers/tips_list_provider_riverpod.dart';
import '../../providers/users_provider_riverpod.dart';

import './share_tip.dart';

// alert message if the "share with" field is not valid
class ShareWithValidationAlert extends StatelessWidget {
  const ShareWithValidationAlert({super.key});
  final title = ConstNewTipScreen.shareWithAlertTitle;
  final message = ConstNewTipScreen.shareWithAlertMessage;
  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? CupertinoAlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                child: const Text(ConstStringAlertDialog.closeButton),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          )
        : AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(ConstStringAlertDialog.closeButton))
            ],
          );
  }
}

// alert message if the "comment" field is not valid
class CommentValidationAlert extends ConsumerWidget {
  const CommentValidationAlert(
      {super.key,
      required this.shareWithFriends,
      required this.tipType,
      required this.isSentWithoutComment,
      required this.listOfTaggedFriendsId,
      required this.userId,
      required this.overview,
      required this.contentType,
      required this.imageUrl,
      required this.contentId,
      required this.contentInfo,
      required this.title,
      required this.storywoodContentId});
  final shareWithFriends;
  final AlertBoxTitle = ConstNewTipScreen.commentAlertTitle;
  final message = ConstNewTipScreen.commentAlertMessage;
  final String tipType;
  final bool isSentWithoutComment;
  final List<String> listOfTaggedFriendsId;
  final String userId;
  final String overview;
  final String contentType;
  final String imageUrl;
  final String contentId;
  final Map contentInfo;
  final String title;
  final String storywoodContentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Platform.isIOS
        ? CupertinoAlertDialog(
            title: Text(AlertBoxTitle),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                child: const Text(
                    ConstStringAlertDialog.sendTipWithoutCommentButton),
                onPressed: () {
                  shareTip(
                      tipType: tipType,
                      ref: ref,
                      context: context,
                      shareWithFriends: shareWithFriends,
                      isSentWithoutComment: isSentWithoutComment,
                      listOfTaggedFriendsId: listOfTaggedFriendsId,
                      userId: userId!,
                      contentId: contentId,
                      contentInfo: contentInfo,
                      contentType: contentType,
                      imageUrl: imageUrl,
                      overview: overview,
                      title: title,
                      storywoodContentId: storywoodContentId);
                },
              ),
              CupertinoDialogAction(
                child: const Text(ConstStringAlertDialog.cancelButton),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          )
        : AlertDialog(
            title: Text(AlertBoxTitle),
            content: Text(message),
            actions: [
              TextButton(
                  onPressed: () {
                    shareTip(
                        tipType: tipType,
                        ref: ref,
                        context: context,
                        shareWithFriends: shareWithFriends,
                        isSentWithoutComment: isSentWithoutComment,
                        listOfTaggedFriendsId: listOfTaggedFriendsId,
                        userId: userId!,
                        contentId: contentId,
                        contentInfo: contentInfo,
                        contentType: contentType,
                        imageUrl: imageUrl,
                        overview: overview,
                        title: title,
                        storywoodContentId: storywoodContentId);
                  },
                  child: const Text(
                      ConstStringAlertDialog.sendTipWithoutCommentButton)),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(ConstStringAlertDialog.cancelButton)),
            ],
          );
  }
}

// alert message if the "title" field is not valid
class TitleValidationAlert extends StatelessWidget {
  const TitleValidationAlert({super.key});

  final title = ConstNewTipScreen.titleAlertTitle;
  final message = ConstNewTipScreen.titleAlertMessage;
  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? CupertinoAlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                child: const Text(ConstStringAlertDialog.closeButton),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          )
        : AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(ConstStringAlertDialog.closeButton))
            ],
          );
  }
}
