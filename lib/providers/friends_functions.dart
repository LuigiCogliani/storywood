import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../providers/users_provider_riverpod.dart';
import '../../providers/notifications_functions.dart';
import '../../data/theme_data.dart';
import '../../data/environment.dart';
import '../../models/user_class.dart' as storywood;

Future<void> sendFriendRequest(
    {required WidgetRef ref, required storywood.User foundUser}) async {
  //Load existing friend requests for that user
  final List<String> friendRequestUserIds =
      foundUser.friendRequestsUserIds ?? [];

  String froundUserUserId = foundUser.userId!;

  //Add my user id to the friend requests list
  String myUserId = ref.read(userInfoProvider)?.userId ?? '';
  friendRequestUserIds.add(myUserId);

  String myImageUrl = ref.read(userInfoProvider)?.imageUrl ??
      constDefaultImageMisingPlaceholder;

  FirebaseFirestore.instance
      .collection('${ENVIRONMENT}users')
      .doc(froundUserUserId)
      .set({
    'friend_requests_user_ids': friendRequestUserIds,
  }, SetOptions(merge: true));

  //Send notification to the request receiver
  addNewNotification(
      timeStampCreated: DateTime.now().toUtc().toString(),
      tipId: '',
      notificationType: constNotifTypeNewFriendRequestReceived,
      sentBy: myUserId,
      sentTo: [froundUserUserId],
      imageUrl: myImageUrl,
      ref: ref);
}
