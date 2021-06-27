import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:overlay_support/overlay_support.dart';

import 'chat/message_arguments.dart';
import 'chat/message_screen.dart';
import 'models/current_route.dart';
import 'models/push_notification.dart';
import 'services/sqlite_service.dart';
import 'widgets/notification_overlay_item.dart';

/// Sets a message handler function which is called when the app is in the
/// foreground.
void subscribeToFCM() {
  final SQLiteService<PushNotification> sqliteService =
      GetIt.I.get<SQLiteService<PushNotification>>();

  FirebaseMessaging.onMessage.listen(
    (RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');

        // Constructs a PushNotification from the RemoteMessage.
        final PushNotification notification = PushNotification(
          title: message.notification!.title!,
          body: message.notification!.body!,
          actor: message.data['actor'] as String,
          verb: message.data['verb'] as String,
          object: message.data['object'] as String,
          avatar: message.data['avatar'] as String?,
          message: message.data['message'] as String?,
          uid: FirebaseAuth.instance.currentUser?.uid,
          createdAt: message.sentTime,
        );

        // Saves the notification into the database if the notification's verb
        // equals to 'comment'.
        if (notification.verb == 'comment') {
          sqliteService
              .insert(notification)
              .then((value) => print('Notification saved into the db.'));
        }
        // If the notification's verb is 'message',
        else if (notification.verb == 'message') {
          final String currentRoute = GetIt.I.get<CurrentRoute>().routeName;
          final MessageArguments? messageArguments =
              GetIt.I.get<CurrentRoute>().messageArguments;
          final String? messageDocId = messageArguments?.docId;

          // Don't show notification if the conversation is on foreground.
          if (currentRoute != MessageScreen.routeName &&
              messageDocId != notification.object) {
            showOverlayNotification(
              (BuildContext context) => NotificationOverlayItem(notification),
            );
          }
        }
      }
    },
  );
}
