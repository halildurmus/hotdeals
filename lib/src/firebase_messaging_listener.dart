import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:loggy/loggy.dart' show logDebug;

import 'chat/message_screen.dart';
import 'models/current_route.dart';
import 'notification/notification_util.dart';
import 'notification/push_notification.dart';
import 'services/push_notification_service.dart';

/// Sets a message handler function which is called when the app is in the
/// foreground.
Future<void> subscribeToFCM() async {
  final pushNotificationService = GetIt.I.get<PushNotificationService>();
  // Get any messages which caused the application to open from
  // a terminated state.
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    // TODO(halildurmus): Handle initialMessage
    logDebug('Initial message: $initialMessage');
  }

  FirebaseMessaging.onMessage.listen((message) {
    logDebug('Got a message whilst in the foreground!');
    logDebug('Message data: ${message.data}');
    final notification = message.notification;
    final android = message.notification?.android;
    if (notification != null && android != null) {
      logDebug('Message also contained a notification: $notification');
      // Constructs a PushNotification from the RemoteMessage.
      final pushNotification = PushNotification(
        title: notification.title,
        titleLocKey: notification.titleLocKey,
        titleLocArgs: notification.titleLocArgs,
        body: notification.body,
        bodyLocKey: notification.bodyLocKey,
        bodyLocArgs: notification.bodyLocArgs,
        actor: message.data['actor'] as String,
        verb: NotificationVerb.values.byName(message.data['verb']! as String),
        object: message.data['object'] as String,
        avatar: message.data['avatar'] as String,
        message: message.data['message'] as String,
        image: message.data['image'] as String?,
        uid: FirebaseAuth.instance.currentUser!.uid,
        createdAt: message.sentTime,
      );

      switch (pushNotification.verb) {
        case NotificationVerb.comment:
          // Saves the notification into the database
          pushNotificationService
              .insert(pushNotification)
              .then((value) => logDebug('Notification saved into the db.'));
          NotificationUtil.showNotification(
            notification,
            largeIconUrl: pushNotification.avatar,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          );
          break;
        case NotificationVerb.message:
          final currentRoute = GetIt.I.get<CurrentRoute>().routeName;
          final messageArguments = GetIt.I.get<CurrentRoute>().messageArguments;
          final messageDocId = messageArguments?.docId;
          // Don't show notification if the conversation is on foreground.
          if (currentRoute != MessageScreen.routeName &&
              messageDocId != pushNotification.object) {
            NotificationUtil.showNotification(
              notification,
              imageUrl: pushNotification.image,
              largeIconUrl: pushNotification.avatar,
              payload: pushNotification.object,
            );
          }
          break;
      }
    }
  });

  // Handle any interaction when the app is in the background.
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    // TODO(halildurmus): Handle onMessageOpenedApp event
    logDebug('A new onMessageOpenedApp event was published!');
  });
}

/// A Firebase message handler function which is called when the app is in the
/// background or terminated.
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  logDebug('Handling a background message: ${message.messageId}');
  // Initializes a new Firebase App instance.
  await Firebase.initializeApp();
  final notification = message.notification;
  final android = message.notification?.android;
  if (notification != null && android != null) {
    // Creates a new PushNotificationServiceImpl instance.
    final pushNotificationService = PushNotificationService();
    // Loads the sqlite database.
    await pushNotificationService.load();
    // Constructs a PushNotification from the RemoteMessage.
    final pushNotification = PushNotification(
      title: notification.title,
      titleLocKey: notification.titleLocKey,
      titleLocArgs: notification.titleLocArgs,
      body: notification.body,
      bodyLocKey: notification.bodyLocKey,
      bodyLocArgs: notification.bodyLocArgs,
      actor: message.data['actor'] as String,
      verb: NotificationVerb.values.byName(message.data['verb']! as String),
      object: message.data['object'] as String,
      avatar: message.data['avatar'] as String,
      message: message.data['message'] as String,
      image: message.data['image'] as String?,
      uid: FirebaseAuth.instance.currentUser!.uid,
      createdAt: message.sentTime,
    );

    // Saves the notification into the database if the notification's verb
    // equals to NotificationVerb.comment.
    if (pushNotification.verb == NotificationVerb.comment) {
      pushNotificationService.insert(pushNotification).then(
          (value) => logDebug('Background notification saved into the db.'));
    }
  }
}
