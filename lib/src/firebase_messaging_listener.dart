import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:loggy/loggy.dart' show logInfo;
import 'package:overlay_support/overlay_support.dart';

import 'chat/message_arguments.dart';
import 'chat/message_screen.dart';
import 'models/current_route.dart';
import 'models/notification_verb.dart';
import 'models/push_notification.dart';
import 'services/push_notification_service.dart';
import 'widgets/notification_overlay_item.dart';

/// Sets a message handler function which is called when the app is in the
/// foreground.
void subscribeToFCM() {
  final pushNotificationService = GetIt.I.get<PushNotificationService>();

  FirebaseMessaging.onMessage.listen(
    (RemoteMessage message) {
      logInfo('Got a message whilst in the foreground!');
      logInfo('Message data: ${message.data}');

      if (message.notification != null) {
        logInfo(
            'Message also contained a notification: ${message.notification}');

        // Constructs a PushNotification from the RemoteMessage.
        final notification = PushNotification(
          title: message.notification!.title!,
          body: message.notification!.body!,
          actor: message.data['actor'] as String,
          verb: NotificationVerb.values.byName(message.data['verb']! as String),
          object: message.data['object'] as String,
          avatar: message.data['avatar'] as String?,
          message: message.data['message'] as String?,
          uid: FirebaseAuth.instance.currentUser?.uid,
          createdAt: message.sentTime,
        );

        // Saves the notification into the database if the notification's verb
        // equals to NotificationVerb.comment.
        if (notification.verb == NotificationVerb.comment) {
          pushNotificationService
              .insert(notification)
              .then((value) => logInfo('Notification saved into the db.'));
        } else if (notification.verb == NotificationVerb.message) {
          final String currentRoute = GetIt.I.get<CurrentRoute>().routeName;
          final MessageArguments? messageArguments =
              GetIt.I.get<CurrentRoute>().messageArguments;
          final String? messageDocId = messageArguments?.docId;

          // Don't show notification if the conversation is on foreground.
          if (currentRoute != MessageScreen.routeName &&
              messageDocId != notification.object) {
            showOverlayNotification(
              (BuildContext context) => NotificationOverlayItem(notification),
              duration: const Duration(seconds: 3),
            );
          }
        }
      }
    },
  );
}

/// A Firebase message handler function which is called when the app is in the
/// background or terminated.
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initializes a new Firebase App instance.
  await Firebase.initializeApp();

  logInfo('Handling a background message: ${message.messageId}');

  // Creates a new PushNotificationServiceImpl instance.
  final pushNotificationService = PushNotificationService();
  // Loads the sqlite database.
  await pushNotificationService.load();
  // Constructs a PushNotification from the RemoteMessage.
  final notification = PushNotification(
    title: message.notification!.title!,
    body: message.notification!.body!,
    actor: message.data['actor'] as String,
    verb: NotificationVerb.values.byName(message.data['verb']! as String),
    object: message.data['object'] as String,
    message: message.data['message'] as String?,
    uid: FirebaseAuth.instance.currentUser?.uid,
    createdAt: message.sentTime,
  );

  // Saves the notification into the database if the notification's verb
  // equals to NotificationVerb.comment.
  if (notification.verb == NotificationVerb.comment) {
    pushNotificationService
        .insert(notification)
        .then((value) => logInfo('Background notification saved into the db.'));
  }
}
