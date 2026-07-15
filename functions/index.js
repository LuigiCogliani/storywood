const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.prodNotification = functions.firestore
  .document("production/production/notifications/{notificationId}")
  .onCreate((snapshot, context) => {
    let visibleNotification = '';
    switch (snapshot.data().notificationType) {
      case 'newTip':
        visibleNotification = 'shared a new tip with you';
        break;
      case 'newChatMessage':
        visibleNotification = 'sent a new message';
        break;
      case 'newVote':
        visibleNotification = 'placed a new vote';
        break;
      case 'newFriendRequestReceived':
        visibleNotification =
        'sent you a friend request';
        break;
      case 'newFriendRequestApproved':
        visibleNotification =
        'approved your friend request';
        break;
      case 'newCollectionShared':
          visibleNotification =
          'shared a collection';
        break;
      default:
        visibleNotification = 'sent a notification';
    }

    return admin.messaging().sendToDevice(snapshot.data().sentToTokens, {
      notification: {
        title: snapshot.data().sentByUsername,
        body: visibleNotification,
        badge: String(snapshot.data().activeNotifications),
      },
      data: {
        tipId: snapshot.data().tipId,
        notificationType: snapshot.data().notificationType,
      }
    });
  });

exports.stagNotification = functions.firestore
  .document("staging/staging/notifications/{notificationId}")
  .onCreate((snapshot, context) => {
    let visibleNotification = '';
    switch (snapshot.data().notificationType) {
      case 'newTip':
        visibleNotification = 'shared a new tip with you';
        break;
      case 'newChatMessage':
        visibleNotification = 'sent a new message';
        break;
      case 'newVote':
        visibleNotification = 'placed a new vote';
        break;
      case 'newFriendRequestReceived':
        visibleNotification =
        'sent you a friend request';
        break;
      case 'newFriendRequestApproved':
        visibleNotification =
        'approved your friend request';
        break;
      case 'newCollectionShared':
          visibleNotification =
          'shared a collection';
         break;
      default:
        visibleNotification = 'sent a notification';
    }

    return admin.messaging().sendToDevice(snapshot.data().sentToTokens, {
      notification: {
        title: snapshot.data().sentByUsername,
        body: visibleNotification,
        badge: String(snapshot.data().activeNotifications),
      },
      data: {
        tipId: snapshot.data().tipId,
        notificationType: snapshot.data().notificationType,
      }
    });
  });

exports.devNotification = functions.firestore
  .document("development/development/notifications/{notificationId}")
  .onCreate((snapshot, context) => {

    let visibleNotification = '';
    switch (snapshot.data().notificationType) {
      case 'newTip':
        visibleNotification = 'shared a new tip with you';
        break;
      case 'newChatMessage':
        visibleNotification = 'sent a new message';
        break;
      case 'newVote':
        visibleNotification = 'placed a new vote';
        break;
      case 'newFriendRequestReceived':
        visibleNotification =
        'sent you a friend request';
        break;
      case 'newCollectionShared':
        visibleNotification =
        'shared a collection';
        break;
        case 'newFriendRequestApproved':
          visibleNotification =
          'approved your friend request';
          break;
      default:
        visibleNotification = 'sent a notification';
    }

    return admin.messaging().sendToDevice(snapshot.data().sentToTokens, {
      notification: {
        title: snapshot.data().sentByUsername,
        body: visibleNotification,
        badge: String(snapshot.data().activeNotifications),
      },
      data: {
        tipId: snapshot.data().tipId,
        notificationType: snapshot.data().notificationType,
      }
    });
  });


exports.devLuigiNotification = functions.firestore
  .document("development_luigi/development_luigi/notifications/{notificationId}")
  .onCreate((snapshot, context) => {
    let visibleNotification = '';
    switch (snapshot.data().notificationType) {
      case 'newTip':
        visibleNotification = 'shared a new tip with you';
        break;
      case 'newChatMessage':
        visibleNotification = 'sent a new message';
        break;
      case 'newVote':
        visibleNotification = 'placed a new vote';
        break;
      case 'newFriendRequestReceived':
        visibleNotification =
        'sent you a friend request';
        break;
      case 'newFriendRequestApproved':
        visibleNotification =
        'approved your friend request';
        break;
      case 'newCollectionShared':
        visibleNotification =
        'shared a collection';
        break;
      default:
        visibleNotification = 'sent a notification';
    }

    return admin.messaging().sendToDevice(snapshot.data().sentToTokens, {
      notification: {
        title: snapshot.data().sentByUsername,
        body: visibleNotification,
        badge: String(snapshot.data().activeNotifications),
      },
      data: {
        tipId: snapshot.data().tipId,
        notificationType: snapshot.data().notificationType,
      }
    });
  });