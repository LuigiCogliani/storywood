import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/new_tip_provider.dart';
import '../../data/theme_data.dart';

class CommentNewTipForm extends ConsumerStatefulWidget {
  const CommentNewTipForm({super.key});

  @override
  ConsumerState<CommentNewTipForm> createState() => _CommentNewTipFormState();
}

class _CommentNewTipFormState extends ConsumerState<CommentNewTipForm> {
  // required for the comment field
  var commentController = TextEditingController();
  var currentComment = '';

  @override
  void initState() {
    var currentComment = ref.read(commentNewTipProvider);
    commentController = TextEditingController(text: currentComment);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double mediaQueryWidth = MediaQuery.of(context).size.width;
    final double mediaQueryHeight = MediaQuery.of(context).size.height;

    bool isCommentNotValid = true;
    return Platform.isIOS
        ? CupertinoTextField(
            placeholder: 'Any special reasons...',
            placeholderStyle: TextStyle(color: Colors.white),
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            onChanged: (_) {
              setState(() {
                currentComment = commentController.text;
              });
              ref
                  .read(commentNewTipProvider.notifier)
                  .assignComment(currentComment.toString());
              currentComment.toString().isNotEmpty
                  ? isCommentNotValid = false
                  : isCommentNotValid = true;
              ref
                  .read(commentNewTipValidationProvider.notifier)
                  .setCommentValidationStatus(isCommentNotValid);
            },
            controller: commentController,
            maxLength: 1000,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            autocorrect: true,
            cursorColor: constCursorColorLight,
            style: constBodyLargeLight,
            // arbitrary number just to make sure we show enough lines
            // it also works nicely because it push the "share button to the bottom of the page"
            maxLines: 20,
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              onChanged: (_) {
                setState(() {
                  currentComment = commentController.text;
                });
                ref
                    .read(commentNewTipProvider.notifier)
                    .assignComment(currentComment.toString());
                currentComment.toString().isNotEmpty
                    ? isCommentNotValid = false
                    : isCommentNotValid = true;
                ref
                    .read(commentNewTipValidationProvider.notifier)
                    .setCommentValidationStatus(isCommentNotValid);
              },
              controller: commentController,
              decoration: const InputDecoration(
                  hintText: 'Any special reasons...',
                  hintStyle: constChatLight,
                  border: InputBorder.none,
                  counterStyle:
                      TextStyle(color: constNewTipScreenAndroidCommentBorder)),
              maxLength: 1000,
              maxLines: 20,
              autocorrect: true,
              cursorColor: constCursorColorLight,
              style: constBodyMediumLight,
            ),
          );
  }
}
