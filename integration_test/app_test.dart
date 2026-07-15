import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:irina_storywood_mockup/main.dart' as app;

void main() {
  /// check if we need this! in the video they use ensureInitialised, which is deprecated
  IntegrationTestWidgetsFlutterBinding().ensureFrameCallbacksRegistered();
  // defines a group of test
  group('app test', () {
    // encapsulates a test
    testWidgets('first test', (tester) async {
      // initialises our app
      app.main();
      // do something (pump) and wait for the app to load (settle)
      // in this example we wait for the app to load
      await tester.pumpAndSettle(const Duration(seconds: 5));
// we will start with the tour screen
      final skipTourButton = find.byKey(const Key('skipTour'));
      //login
      await tester.tap(skipTourButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
// identify email field, password field, and login button

      final emailFormField = find
          .byType(Platform.isIOS ? CupertinoTextFormFieldRow : TextFormField)
          .first;
      final passwordFormField = find
          .byType(Platform.isIOS ? CupertinoTextFormFieldRow : TextFormField)
          .last;
      final loginButton =
          find.byType(Platform.isIOS ? CupertinoButton : ElevatedButton);

      //input text
      await tester.enterText(emailFormField, 'luigi.cogliani@gmail.com');
      await tester.enterText(passwordFormField, 'culocul');
      await tester.pumpAndSettle(const Duration(seconds: 2));

      //login
      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });
  });
}
