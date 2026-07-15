import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// alert dialog used for content screen and new tip screen (both iso and android)
class ContentNotAvailableAlertDialog extends StatelessWidget {
  const ContentNotAvailableAlertDialog({
    super.key,
  });
  final String title = 'Oops...';
  final String message =
      'The content is not available at the moment. Please try again later.';
  final String actionMessage = "I'll try again later";

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
