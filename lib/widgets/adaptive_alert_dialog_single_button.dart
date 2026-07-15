import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// alert dialog used for content screen and new tip screen (both ios and android)
class AdaptiveAlertDialogSingleButton extends StatelessWidget {
  const AdaptiveAlertDialogSingleButton({
    required this.title,
    required this.message,
    required this.actionMessage,
    super.key,
  });
  final String title;
  final String message;
  final String actionMessage;

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text(actionMessage),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      );
    } else {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: Text(actionMessage),
            onPressed: () {
              // Navigate to the login page or perform other actions
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    }
  }
}
