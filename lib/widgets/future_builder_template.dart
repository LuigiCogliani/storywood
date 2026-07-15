import 'package:flutter/material.dart';

import '../data/theme_data.dart';

import 'adaptive_circular_loading.dart';
import './adaptive_alert_dialog_single_button.dart';
//TODO the child of the future needs to have access to the snapshot and/or other properties as well

/// Future buildet template that has already filled in the
/// loading behaviour and the error behaviour.
/// Takes an optional parameter for empty snapshot behaviour
class FutureBuilderStorywood extends StatelessWidget {
  const FutureBuilderStorywood(
      {super.key,
      required this.alertDialogMessage,
      required this.alertDialogTitle,
      required this.child,
      required this.future,
      this.emptyChild: const Center()});
  final Future future;
  final String alertDialogTitle;
  final String alertDialogMessage;
  final Widget child;
  final Widget emptyChild;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return adaptiveCircularLoading(
                color: constCircularProgressIndicatorWhite);
          } else {
            if (snapshot.hasError) {
              return AdaptiveAlertDialogSingleButton(
                  title: alertDialogTitle,
                  message: alertDialogMessage,
                  actionMessage: ConstStringAlertDialog.okayButton);
            }
            if (snapshot.hasData) {
              if (snapshot.data.length == 0) {
                return emptyChild;
              } else {
                return child;
              }
            }
            return child;
          }
        });
  }
}
