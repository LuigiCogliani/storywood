import 'package:flutter/material.dart';

import '../widgets/post_screen/post_screen_body.dart';
import '../data/theme_data.dart';
import '../models/tip_class.dart';
import '../providers/tips_list_provider_riverpod.dart';
import '../widgets/adaptive_circular_loading.dart';
import '../widgets/adaptive_alert_dialog_single_button.dart';

class PostScreen extends StatelessWidget {
  const PostScreen({super.key});
  static const routeName = '/post-screen-new';

  @override
  Widget build(BuildContext context) {
    final modalRouteArguments =
        ModalRoute.of(context)!.settings.arguments as List;
    final String tipId = modalRouteArguments[0].toString();
    final Tip? tip = modalRouteArguments[1] as Tip?;
    Future<Tip?> future = fetchSingleTipFromFirebase(tipId);

    return tip == null
        ? FutureBuilder(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return adaptiveCircularLoading(
                    color: constCircularProgressIndicatorWhite);
              } else {
                if (snapshot.hasError || snapshot.data == null) {
                  return const AdaptiveAlertDialogSingleButton(
                      title: ConstStringPostScreen.loadingError,
                      message: ConstStringPostScreen.errorMessage1,
                      actionMessage: ConstStringAlertDialog.okayButton);
                }
                if (snapshot.hasData && snapshot.data != null) {
                  final Tip snapshotTip = snapshot.data as Tip;
                  return PostScreenBody(tip: snapshotTip);
                }
                return const AdaptiveAlertDialogSingleButton(
                    title: ConstStringPostScreen.loadingError,
                    message: ConstStringPostScreen.errorMessage2,
                    actionMessage: ConstStringAlertDialog.okayButton);
              }
            })
        : PostScreenBody(tip: tip);
  }
}
