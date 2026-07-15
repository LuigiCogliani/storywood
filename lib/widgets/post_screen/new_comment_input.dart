import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/users_provider_riverpod.dart';
import '../../providers/notifications_functions.dart';
import '../../providers/tips_list_provider_riverpod.dart';
import '../../data/environment.dart';
import '../../data/theme_data.dart';

class NewCommentInput extends ConsumerStatefulWidget {
  final String tipId;
  final List<String> sentToUserIds;
  final String imageUrl;
  const NewCommentInput(
      {required this.tipId,
      required this.sentToUserIds,
      required this.imageUrl,
      super.key});

  @override
  ConsumerState<NewCommentInput> createState() => _NewCommentInputState();
}

class _NewCommentInputState extends ConsumerState<NewCommentInput> {
  final _controller = TextEditingController();
  var _enteredMessage = ConstStringPostScreen.emptyString;

  @override
  Widget build(BuildContext context) {
    String? userId = ref.read(userInfoProvider)?.userId;
    final String tipId = widget.tipId;
    final List<String> sentToUserIds = widget.sentToUserIds;
    final String imageUrl = widget.imageUrl;

    return Platform.isIOS
        ? Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: CupertinoTextField(
                  //autofocus: true, removed autofocus as it was forcing newsfeed rebuild
                  placeholder: ConstStringTipScreen.sendMessageLabel,
                  maxLines: 2,
                  cursorColor: constCursorColorDark,
                  controller: _controller,
                  style: constChatNewMessageDark,
                  onChanged: (value) {
                    setState(() {
                      _enteredMessage = value;
                    });
                  },
                ),
              ),
              CupertinoButton(
                onPressed: _enteredMessage.trim().isEmpty
                    ? null
                    : () {
                        FocusScope.of(context).unfocus();

                        //Record message on Firebase
                        FirebaseFirestore.instance
                            .collection('${ENVIRONMENT}chats/$tipId/messages')
                            .add({
                          'text': _enteredMessage,
                          'createdAt': DateTime.now().toUtc().toString(),
                          'userId': userId,
                        });

                        //Launch notification for this chat message
                        addNewNotification(
                          timeStampCreated: DateTime.now().toUtc().toString(),
                          tipId: tipId,
                          notificationType: constNotifTypeNewChatMessage,
                          sentBy: userId ?? ConstStringPostScreen.emptyString,
                          sentTo: sentToUserIds,
                          imageUrl: imageUrl,
                          ref: ref,
                        );

                        //Update timeStampLastUpdated for this tip
                        ref
                            .read(tipListProvider.notifier)
                            .updateTipTimeStampLastUpdated(tipId);

                        //Add sender's ID to tip's sentTo if it's not already there to get notified about comments in the future

                        if (sentToUserIds.contains(userId) == false) {
                          addUserIdToTipSentTo(
                              tipId: tipId,
                              userId:
                                  userId ?? ConstStringPostScreen.emptyString);
                        }
                        _controller.clear();

                        setState(() {
                          _enteredMessage = ConstStringPostScreen.emptyString;
                        });

                        Navigator.pop(context);
                      },
                child: const Icon(
                  constMaterialSendMessageIcon,
                  color: constIconColorLight,
                ),
              ),
            ],
          )
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(
                Radius.circular(8),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                color: constHintColor,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        // autofocus: true, //ensures that keyboard pops up straight away
                        cursorColor: constCursorColorLight,
                        maxLines: 2,
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: ConstStringTipScreen.sendMessageLabel,
                          hintStyle: constDisplayMediumLight,
                        ),
                        style: constChatNewMessageLight,
                        onChanged: (value) {
                          setState(() {
                            _enteredMessage = value;
                          });
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: _enteredMessage.trim().isEmpty
                          ? () {}
                          : () {
                              FocusScope.of(context).unfocus();

                              //Record message on Firebase
                              FirebaseFirestore.instance
                                  .collection(
                                      '${ENVIRONMENT}chats/$tipId/messages')
                                  .add({
                                'text': _enteredMessage,
                                'createdAt': DateTime.now().toUtc().toString(),
                                'userId': userId,
                              });

                              //Launch notification for this chat message
                              addNewNotification(
                                timeStampCreated:
                                    DateTime.now().toUtc().toString(),
                                tipId: tipId,
                                notificationType: constNotifTypeNewChatMessage,
                                sentBy:
                                    userId ?? ConstStringPostScreen.emptyString,
                                sentTo: sentToUserIds,
                                imageUrl: imageUrl,
                                ref: ref,
                              );
                              //Update timeStampLastUpdated for this tip
                              ref
                                  .read(tipListProvider.notifier)
                                  .updateTipTimeStampLastUpdated(tipId);
                              //Add sender's ID to tip's sentTo if it's not already there to get notified about comments in the future

                              if (sentToUserIds.contains(userId) == false) {
                                addUserIdToTipSentTo(
                                    tipId: tipId,
                                    userId: userId ??
                                        ConstStringPostScreen.emptyString);
                              }

                              _controller.clear();
                              setState(() {
                                _enteredMessage =
                                    ConstStringPostScreen.emptyString;
                              });

                              Navigator.pop(context);
                            },
                      icon: const Icon(constCupertinoSendMessageIcon),
                      color: constIconColorLight,
                    )
                  ],
                ),
              ),
            ),
          );
  }
}
