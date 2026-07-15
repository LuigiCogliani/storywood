import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../screens/friends_screen.dart';
import '../../data/theme_data.dart';

/// shows a dialog box asking the user to confirm the archiving action
removeFriendAlertDialog({
  required context,
  required friendUserId,
  required friendUserName,
  required removeFriend,
}) {
  const String title = ConstStringFriendsScreen.removeFriendAlertTitle;
  final String content =
      'You will not be able to share tips with $friendUserName or receive tips from $friendUserName if you remove $friendUserName from your friends';
  showDialog(
      context: context,
      builder: (ctx) {
        return Platform.isIOS
            ? CupertinoAlertDialog(
                title: const Text(title),
                content: Text(content),
                actions: [
                  CupertinoDialogAction(
                    onPressed: () {
                      removeFriend(
                        friendUserId: friendUserId,
                      );
                      // enter this if statement if you want to navigate back to the friend screen

                      Navigator.of(context).pushNamed(
                        FriendsScreen.routeNameYourFriendsTab,
                      );
                    },
                    child: const Text(
                      ConstStringAlertDialog.yesButton,
                      style: constCupertinoAlertYesButton,
                    ),
                  ),
                  CupertinoDialogAction(
                      isDestructiveAction: true,
                      child: const Text(ConstStringAlertDialog.noButton),
                      onPressed: () {
                        Navigator.of(ctx).pop(false);
                      }),
                ],
              )
            : AlertDialog(
                title: const Text(title),
                content: Text(content),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop(false);
                      },
                      child: const Text(ConstStringAlertDialog.noButton)),
                  TextButton(
                      onPressed: () {
                        removeFriend(
                          friendUserId: friendUserId,
                        );

                        Navigator.of(context).pushNamed(
                          FriendsScreen.routeNameYourFriendsTab,
                        );
                      },
                      child: const Text(ConstStringAlertDialog.yesButton))
                ],
              );
      });
}
