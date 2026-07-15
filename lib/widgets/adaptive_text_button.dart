import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/theme_data.dart';

/// a text button that works for both ios and android and opens an external link
class AdaptiveUrlTextButton extends StatelessWidget {
  const AdaptiveUrlTextButton(
      {super.key, required this.urlLink, required this.text});
  final String urlLink;
  final String text;
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      width: screenWidth * 0.4,
      height: screenHeight * 0.047,
      child: Platform.isIOS
          ? CupertinoButton(
              onPressed: () {
                launchUrl(Uri.parse(urlLink),
                    mode: LaunchMode.externalApplication);
              },
              color: constElevatedButtonBackgroundLight,
              padding: const EdgeInsets.all(1),
              child: Text(
                text,
                style: constTextButtonDark,
              ),
            )
          : ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                )),
                foregroundColor: MaterialStateProperty.all(
                    constElevatedButtonForegroundDark),
                backgroundColor: MaterialStateProperty.all(
                    constElevatedButtonBackgroundLight),
              ),
              onPressed: () {
                launchUrl(Uri.parse(urlLink),
                    mode: LaunchMode.externalApplication);
              },
              child: Text(
                text,
                style:
                    constTextButtonDarkMediaQuery(mediaQuerywidth: screenWidth),
              )),
    );
  }
}

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
