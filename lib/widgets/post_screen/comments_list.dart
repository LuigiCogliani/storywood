import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import './single_comment_output.dart';
import '../../data/environment.dart';
import '../../data/theme_data.dart';

class CommentsList extends StatelessWidget {
  final String tipId;
  final ScrollController controller;

  const CommentsList(
      {required this.tipId, required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = (MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom);

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('${ENVIRONMENT}chats/$tipId/messages')
          .orderBy('createdAt')
          .snapshots(),
      builder: (ctx, streamSnapshot) {
        if (streamSnapshot.connectionState == ConnectionState.waiting) {
          return const Center();
        }
        final documents =
            streamSnapshot.data == null ? null : streamSnapshot.data!.docs;

        return (documents == null || documents.isEmpty)
            ? Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        mediaQueryHeight * 0.01,
                        mediaQueryHeight * 0.02,
                        mediaQueryHeight * 0.01,
                        mediaQueryHeight * 0.01),
                    child: const Text(
                      ConstStringPostScreen.commentsBottomSheetNoCommentsLine1,
                      style: constBodyMediumWhite,
                    ),
                  ),
                  const Text(
                    ConstStringPostScreen.commentsBottomSheetNoCommentsLine2,
                    style: constBodySmallLight,
                  ),
                ],
              ))
            : ListView.builder(
                shrinkWrap: true, //needed to avoid errors of noSize defined
                controller: controller,
                itemBuilder: (context, index) => Container(
                  padding:
                      EdgeInsets.symmetric(vertical: mediaQueryHeight * 0.008),
                  child: SingleCommentOutput(
                    documents[index]['text'] ??
                        ConstStringPostScreen.emptyString,
                    documents[index]['userId'] ??
                        ConstStringPostScreen.emptyString,
                    key: ValueKey(documents[index].id),
                  ),
                ),
                itemCount: documents.length,
              );
      },
    );
  }
}
