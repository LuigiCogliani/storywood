import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/environment.dart';
import '../providers/users_provider_riverpod.dart';

///Helper function - look up tokens based on userids (takes list of strings as input, outputs list of strings)
Future<List<String>> fetchTokensByUserId(userIds) async {
  List<String> tokensByUserId = [];
  var usersCollection = await FirebaseFirestore.instance
      .collection('${ENVIRONMENT}users')
      .where(FieldPath.documentId, whereIn: userIds)
      .get();
  for (var doc in usersCollection.docs) {
    tokensByUserId.add(doc['token']);
  }
  return tokensByUserId;
}

///Helper function - look up number of unseen notifications based on userid
Future<int> lookUpUnseenNotifications(String userId) async {
  int unseenNotifications;

  var docSnapshot = await FirebaseFirestore.instance
      .collection('${ENVIRONMENT}users')
      .doc(userId)
      .get();

  docSnapshot.data().toString().contains('active_notifications')
      ? unseenNotifications = docSnapshot['active_notifications'] + 1
      : unseenNotifications = 1;
  return unseenNotifications;
}

//TODO: potentially expensive to scale function, need to explore alternative ways to set up
///Function to add new notification object
Future<void> addNewNotification(
    {required String timeStampCreated,
    required String tipId,
    required String notificationType,
    required String sentBy,
    required List<String> sentTo,
    required String imageUrl,
    required WidgetRef ref}) async {
  // remove the sender userId from the list of users to send the notification to
  List<String> sentToBuffer = [...sentTo];

  sentToBuffer.remove(sentBy);

  String sentByUsername = ref.read(usernameProvider)[sentBy]['username'] ?? '';

  for (var sentToForLoopCounter in sentToBuffer) {
    //Notification message was split to be sent individually to each sentTo to facilitate unread notifications count
    //Pull data from helper functions based on userIds
    //Futures had to be set up as void as they have different output types (List vs Integer)
    late List<String> tokens;
    late int unseenNotifications;
    Future.wait<void>(
      [
        fetchTokensByUserId([sentToForLoopCounter])
            .then((value) => tokens = value),
        lookUpUnseenNotifications(sentToForLoopCounter)
            .then((value) => unseenNotifications = value)
      ],
    ).then((values) {
      //Code to store new notification on Firebase
      FirebaseFirestore.instance.collection('${ENVIRONMENT}notifications').add({
        'timeStampCreated': timeStampCreated,
        'tipId': tipId,
        'notificationType': notificationType,
        'sentBy': sentBy,
        'sentByUsername': sentByUsername,
        'sentTo': [sentToForLoopCounter],
        'sentToTokens': tokens,
        'activeNotifications': unseenNotifications,
        'imageUrl': imageUrl
      }).then((docRef) {
        //Update number of unseen notifications on Firebase
        FirebaseFirestore.instance
            .collection('${ENVIRONMENT}users')
            .doc(sentToForLoopCounter)
            .set({
          'active_notifications': unseenNotifications,
        }, SetOptions(merge: true));
      }).catchError((error) {
        throw error;
      });
    }).catchError((error) {
      throw error;
    });
  }
}
