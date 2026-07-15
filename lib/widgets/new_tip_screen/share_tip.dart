import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:irina_storywood_mockup/providers/users_provider_riverpod.dart';
import '../../providers/new_tip_provider.dart';
import '../../providers/tips_list_provider_riverpod.dart';
import '../../data/theme_data.dart';
import './new_tip_validation.dart';
import '../../widgets/home_button.dart';

void shareTip({
  required String tipType,
  required WidgetRef ref,
  required context,
  required bool shareWithFriends,
  required bool isSentWithoutComment,
  required List<String> listOfTaggedFriendsId,
  required String userId,
  required String overview,
  required String title,
  required String contentType,
  required String imageUrl,
  required String contentId,
  required Map contentInfo,
  required String storywoodContentId,
}) {
  // if (contentType == constContentTypePodcast) {
  //   overview = ref.read(contentOverviewNewTipProvider);
  // }

  final String comment = isSentWithoutComment
      ? '${ConstNewTipScreen.commentOverwriteStartingWord}$overview'
      : ref.read(commentNewTipProvider);

  final String tipPrivacy = ref.read(tipPrivacyStatusNewTipProvider);

  // add the current user to the list of user IDs
  listOfTaggedFriendsId.add(userId);

  //pull list of friendIds
  List<String>? friendIds = ref.read(userInfoProvider)!.friendsUserIds;

  if (friendIds == null) {
    friendIds = [userId];
  } else {
    friendIds.add(userId);
  }

  List<String> visibleTo;

  tipPrivacy == constTipPrivacyTaggedFriends
      ? visibleTo = listOfTaggedFriendsId
      : visibleTo = friendIds;

  resetProviders(ref);
  goToHomeScreen(context, ref);
  ref
      .read(tipListProvider.notifier)
      .addNewTip(
          txTitle: title,
          comment: comment,
          sentTo: listOfTaggedFriendsId,
          visibleTo: visibleTo,
          tipType: tipType,
          contentType: contentType,
          imageUrl: imageUrl,
          contentId: contentId,
          info: contentInfo,
          storywoodContentId: storywoodContentId,
          tipPrivacy: tipPrivacy,
          ref: ref)
      .catchError((error) {
    return showDialog(
        context: context,
        builder: (ctx) {
          return Platform.isIOS
              ? CupertinoAlertDialog(
                  title: const Text(
                    ConstStringAlertDialog.genericTitle,
                    style: ConstCupertinoDialog.title,
                  ),
                  content: const Text(
                    ConstStringAlertDialog.newTipErrorMessage,
                    style: ConstCupertinoDialog.message,
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: const Text(
                          ConstStringAlertDialog.okayButton,
                          style: ConstCupertinoDialog.closeButton,
                        ))
                  ],
                )
              : AlertDialog(
                  title: const Text(
                    ConstStringAlertDialog.genericTitle,
                    style: ConstMaterialDialog.title,
                  ),
                  content: const Text(
                    ConstStringAlertDialog.newTipErrorMessage,
                    style: ConstMaterialDialog.message,
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: const Text(
                          ConstStringAlertDialog.okayButton,
                          style: ConstMaterialDialog.closeButton,
                        ))
                  ],
                );
        });
  }).then((_) {
    resetProviders(ref);
    goToHomeScreen(context, ref);
  });
  // reset the share with validation status
  ref
      .read(shareWithNewTipValidationProvider.notifier)
      .setShareWithValidationStatus(true);

  // reset the title validation status
  ref
      .read(commentNewTipValidationProvider.notifier)
      .setCommentValidationStatus(true);

  // reset the comment validation status
  // ref
  //     .read(titleNewTipValidationProvider.notifier)
  //     .setTitleValidationStatus(true);
}

/// will go through the share with and comment alert. If no alert is triggered
/// will share the tip
void shareTipAndAlerts({
  required String tipType,
  required WidgetRef ref,
  required context,
  required bool shareWithFriends,
  required String overview,
  required String title,
  required String contentType,
  required String imageUrl,
  required String contentId,
  required Map contentInfo,
  required String storywoodContentId,
}) {
  bool isSentWithoutComment = ref.read(commentNewTipProvider) == '';
// get the id of the current user
  String? userId = ref.read(userInfoProvider)?.userId;
  // ref.read(sentToNewTipProvider.notifier).convertSelectedUsernamesToUserids(
  //     sentTo: ref.read(shareWithSelectionNewTipProvider));
  List<String> listOfTaggedFriendsId = ref.read(tagFriendsProvider);
  String tipPrivacyStatus = ref.read(tipPrivacyStatusNewTipProvider);

  //check if tagged friends for Only tagged friends can see privacy option
  if (listOfTaggedFriendsId.isEmpty &&
      tipPrivacyStatus == constTipPrivacyTaggedFriends) {
    showDialog(
        context: context,
        builder: (ctx) {
          return const ShareWithValidationAlert();
        });
  } else if (isSentWithoutComment) {
    showDialog(
        context: context,
        builder: (ctx) {
          return CommentValidationAlert(
            shareWithFriends: shareWithFriends,
            isSentWithoutComment: isSentWithoutComment,
            listOfTaggedFriendsId: listOfTaggedFriendsId,
            tipType: tipType,
            userId: userId!,
            contentId: contentId,
            contentInfo: contentInfo,
            contentType: contentType,
            imageUrl: imageUrl,
            overview: overview,
            title: title,
            storywoodContentId: storywoodContentId,
          );
        });
  } else {
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
  }
}
