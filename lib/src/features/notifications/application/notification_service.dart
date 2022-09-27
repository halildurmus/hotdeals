import 'dart:convert';

import 'package:android_id/android_id.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart' show Locale;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';

import '../../../core/hotdeals_api.dart';
import '../../../core/hotdeals_repository.dart';
import '../../settings/presentation/locale_controller.dart';
import '../data/providers.dart';
import '../data/push_notification_service.dart';
import '../domain/push_notification.dart';

final notificationServiceProvider = Provider<NotificationService>(
    NotificationService.new,
    name: 'NotificationServiceProvider');

class NotificationService {
  NotificationService(Ref ref)
      : _channel = ref.read(androidNotificationChannelProvider),
        _flutterLocalNotificationsPlugin =
            ref.read(flutterLocalNotificationsPluginProvider),
        _hotdealsRepository = ref.read(hotdealsRepositoryProvider),
        _locale = ref.watch(localeControllerProvider),
        _pushNotificationService = ref.read(pushNotificationServiceProvider);

  final AndroidNotificationChannel _channel;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  final HotdealsApi _hotdealsRepository;
  final Locale _locale;
  final PushNotificationService _pushNotificationService;

  void _validateImageUrl(String url) {
    final pattern = RegExp(r'^http[s]?://');
    final hasMatch = pattern.hasMatch(url);
    if (!hasMatch) {
      throw Exception('`imageUrl` must start with `http://` or `https://`');
    }
  }

  Future<AndroidBitmap<Object>> _createAndroidBitmap(String imageUrl) async {
    _validateImageUrl(imageUrl);
    final response = await http.get(Uri.parse(imageUrl));
    final base64Image = base64.encode(response.bodyBytes);

    return ByteArrayAndroidBitmap.fromBase64String(base64Image);
  }

  Future<void> showNotification(
    RemoteNotification notification, {
    String? imageUrl,
    Importance importance = Importance.max,
    String? largeIconUrl,
    String? payload,
    Priority priority = Priority.max,
    NotificationVisibility visibility = NotificationVisibility.public,
  }) async {
    final l = lookupAppLocalizations(_locale);
    final titles = <String, String>{
      'comment_title': notification.titleLocArgs.first + l.commentedOnYourPost,
      'file_message_title': notification.titleLocArgs.first + l.sentYouFile,
      'image_message_title': notification.titleLocArgs.first + l.sentYouImage,
      'text_message_title': notification.titleLocArgs.first + l.sentYouMessage
    };
    final title = titles[notification.titleLocKey] ??
        'Unknown titleLocKey: ${notification.titleLocKey}';

    return _flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title ?? title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          icon: 'ic_launcher',
          importance: importance,
          largeIcon: largeIconUrl != null
              ? await _createAndroidBitmap(largeIconUrl)
              : null,
          styleInformation: imageUrl != null
              ? BigPictureStyleInformation(await _createAndroidBitmap(imageUrl))
              : null,
          priority: priority,
          visibility: visibility,
        ),
      ),
      payload: payload,
    );
  }

  Future<void> _saveFCMTokenToDatabase(String token) async {
    final deviceId = await const AndroidId().getId() ?? 'unknown';
    logInfo('Saving FCM token to database: $token, $deviceId');
    if (deviceId != 'unknown') {
      await _hotdealsRepository.addFCMToken(deviceId: deviceId, token: token);
    }
  }

  Future<void> subscribe() async {
    // Gets the FCM token each time the user logs in.
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await _saveFCMTokenToDatabase(token);
      // Any time the token refreshes, store it in the database.
      FirebaseMessaging.instance.onTokenRefresh.listen(_saveFCMTokenToDatabase);
      // Subscribes to Firebase Cloud Messaging.
      await subscribeToFCM();
    }
  }

  /// Sets a message handler function which is called when the app is in the
  /// foreground.
  Future<void> subscribeToFCM() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      // TODO(halildurmus): Handle initialMessage
      logInfo('Initial message: $initialMessage');
    }

    FirebaseMessaging.onMessage.listen((message) {
      logInfo('Got a message whilst in the foreground!');
      logInfo('Message data: ${message.data}');
      final notification = message.notification;
      final android = message.notification?.android;
      if (notification != null && android != null) {
        logInfo('Message also contained a notification: $notification');
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
            _pushNotificationService
                .insert(pushNotification)
                .then((value) => logInfo('Notification saved into the db.'));
            showNotification(
              notification,
              largeIconUrl: pushNotification.avatar,
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
            );
            break;
          case NotificationVerb.message:
            showNotification(
              notification,
              imageUrl: pushNotification.image,
              largeIconUrl: pushNotification.avatar,
              payload: pushNotification.object,
            );
            break;
        }
      }
    });

    // Handle any interaction when the app is in the background.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // TODO(halildurmus): Handle onMessageOpenedApp event
      logInfo('A new onMessageOpenedApp event was published!');
    });
  }
}
