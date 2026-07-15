import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import './notification_item.dart';
import '../../data/environment.dart';
import '../../data/theme_data.dart';
import '../../models/notification_class.dart';
import '../adaptive_alert_dialog_single_button.dart';
import '../adaptive_circular_loading.dart';
import '../../providers/users_provider_riverpod.dart';

/// Loads the notifictions from firebase as the user srolls down, using pagination
class NotificationList extends ConsumerWidget {
  const NotificationList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // load current user ID (required for the pagination query)
    final String? userId = ref.read(userInfoProvider)?.userId;
// pagination query (tells Firebase what data to get and in what order)
    final query = FirebaseFirestore.instance
        .collection('${ENVIRONMENT}notifications')
        .where('sentTo', arrayContains: userId)
        .orderBy('timeStampCreated', descending: true)
        //converts the snapshot into notification class
        .withConverter<NotificationObject>(
          fromFirestore: (snapshot, _) =>
              NotificationObject.fromJson(snapshot.data()!),
          toFirestore: (notification, _) => notification.toJson(),
        );

    return FirestoreQueryBuilder(
      // number of notifications to load at time
      pageSize: 9,
      query: query,
      builder: (context, snapshot, child) {
        // defines the loading behaviour
        if (snapshot.isFetching) {
          return adaptiveCircularLoading(
              color: constCircularProgressIndicatorWhite);
        }
        // defines the error behaviour
        if (snapshot.hasError) {
          return const AdaptiveAlertDialogSingleButton(
              title:
                  ConstStringNotificationsScreen.futureBuilderNotLoadingTitle,
              message:
                  ConstStringNotificationsScreen.futureBuilderNotLoadingMessage,
              actionMessage: ConstStringAlertDialog.okayButton);
        }
        return ListView.builder(
          itemCount: snapshot.docs.length,
          itemBuilder: (BuildContext context, int index) {
            final isLastItem = index + 1 == snapshot.docs.length;
            // fecthes more data if user reaches the bottom of page (and there are more items)
            if (isLastItem && snapshot.hasMore) snapshot.fetchMore();
            // store the current snapshot into a notification object
            NotificationObject currentNotification =
                snapshot.docs[index].data();

            //add the notifiction id
            currentNotification.setNotifiationId = snapshot.docs[index].id;
            return NotificationItem(notificationObject: currentNotification);
          },
        );
      },
    );
  }
}
