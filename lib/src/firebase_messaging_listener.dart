import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:loggy/loggy.dart' show logDebug;

import 'chat/message_arguments.dart';
import 'chat/message_screen.dart';
import 'models/current_route.dart';
import 'models/notification_verb.dart';
import 'models/push_notification.dart';
import 'services/push_notification_service.dart';
import 'settings/settings.controller.dart';

final flutterLocalNotificationsPlugin =
    GetIt.I.get<FlutterLocalNotificationsPlugin>();
final channel = GetIt.I.get<AndroidNotificationChannel>();
final settingsController = GetIt.I.get<SettingsController>();

void showNotification(
  RemoteNotification notification, {
  String? payload,
  Importance importance = Importance.max,
  Priority priority = Priority.max,
  NotificationVisibility visibility = NotificationVisibility.public,
}) {
  final AppLocalizations l = lookupAppLocalizations(settingsController.locale);
  late final String title;
  late final String body;
  // TODO(halildurmus): Convert this into a switch case
  if (notification.titleLocKey == 'comment_title') {
    title = notification.titleLocArgs.first + l.commentedOnYourPost;
    body = notification.bodyLocArgs.first;
  } else if (notification.titleLocKey == 'file_message_title') {
    title = notification.titleLocArgs.first + l.sentYouMessage;
    body = notification.bodyLocArgs.first;
  } else if (notification.titleLocKey == 'image_message_title') {
    title = notification.titleLocArgs.first + l.sentYouMessage;
    body = notification.bodyLocArgs.first;
  } else if (notification.titleLocKey == 'text_message_title') {
    title = notification.titleLocArgs.first + l.sentYouMessage;
    body = notification.bodyLocArgs.first;
  }

  flutterLocalNotificationsPlugin.show(
    notification.hashCode,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        icon: 'ic_launcher',
        importance: importance,
        priority: priority,
        visibility: visibility,
      ),
    ),
    payload: payload,
  );
}

void selectNotification(String? payload) async {
  logDebug('Notification payload: $payload');
  if (payload != null) {
    // final String _docId = payload;
    // final MyUser _user = context.read<UserController>().user!;
    // final String _user2Id =
    //     ChatUtil.getUser2Uid(docID: _docId, user1Uid: _user.uid);
    // final MyUser user2 =
    //     await GetIt.I.get<SpringService>().getUserByUid(uid: _user2Id);

    // Navigator.of(context).pushNamed(
    //   MessageScreen.routeName,
    //   arguments: MessageArguments(docId: _docId, user2: user2),
    // );
  }
}

/// Sets a message handler function which is called when the app is in the
/// foreground.
Future<void> subscribeToFCM() async {
  final pushNotificationService = GetIt.I.get<PushNotificationService>();
  // Get any messages which caused the application to open from
  // a terminated state.
  final RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
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
        titleLocKey: notification.titleLocKey!,
        titleLocArgs: notification.titleLocArgs,
        bodyLocKey: notification.bodyLocKey!,
        bodyLocArgs: notification.bodyLocArgs,
        actor: message.data['actor'] as String,
        verb: NotificationVerb.values.byName(message.data['verb']! as String),
        object: message.data['object'] as String,
        avatar: message.data['avatar'] as String?,
        message: message.data['message'] as String?,
        uid: FirebaseAuth.instance.currentUser?.uid,
        createdAt: message.sentTime,
      );

      // equals to NotificationVerb.comment.
      if (pushNotification.verb == NotificationVerb.comment) {
        // Saves the notification into the database
        pushNotificationService
            .insert(pushNotification)
            .then((value) => logDebug('Notification saved into the db.'));
        showNotification(
          notification,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        );
      } else if (pushNotification.verb == NotificationVerb.message) {
        final String currentRoute = GetIt.I.get<CurrentRoute>().routeName;
        final MessageArguments? messageArguments =
            GetIt.I.get<CurrentRoute>().messageArguments;
        final String? messageDocId = messageArguments?.docId;
        // Don't show notification if the conversation is on foreground.
        if (currentRoute != MessageScreen.routeName &&
            messageDocId != pushNotification.object) {
          showNotification(notification, payload: pushNotification.object);
        }
      }
    }
  });

  // Handle any interaction when the app is in the background.
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
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
      titleLocKey: notification.titleLocKey!,
      titleLocArgs: notification.titleLocArgs,
      bodyLocKey: notification.bodyLocKey!,
      bodyLocArgs: notification.bodyLocArgs,
      actor: message.data['actor'] as String,
      verb: NotificationVerb.values.byName(message.data['verb']! as String),
      object: message.data['object'] as String,
      message: message.data['message'] as String?,
      uid: FirebaseAuth.instance.currentUser?.uid,
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
