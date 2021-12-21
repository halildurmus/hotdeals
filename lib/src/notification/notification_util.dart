import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../settings/settings.controller.dart';

class NotificationUtil {
  static Future<AndroidBitmap<Object>> getBitmapFromUrl(String imageUrl) async {
    final http.Response response = await http.get(Uri.parse(imageUrl));
    final base64Image = base64.encode(response.bodyBytes);

    return ByteArrayAndroidBitmap.fromBase64String(base64Image);
  }

  static final _flutterLocalNotificationsPlugin =
      GetIt.I.get<FlutterLocalNotificationsPlugin>();
  static final _channel = GetIt.I.get<AndroidNotificationChannel>();
  static final _settingsController = GetIt.I.get<SettingsController>();

  static void showNotification(
    RemoteNotification notification, {
      String? imageUrl,
    String? largeIconUrl,
    Importance importance = Importance.max,
    String? payload,
    Priority priority = Priority.max,
    NotificationVisibility visibility = NotificationVisibility.public,
  }) async {
    final l = lookupAppLocalizations(_settingsController.locale);
    final titles = <String, String>{
      'comment_title': notification.titleLocArgs.first + l.commentedOnYourPost,
      'file_message_title': notification.titleLocArgs.first + l.sentYouFile,
      'image_message_title': notification.titleLocArgs.first + l.sentYouImage,
      'text_message_title': notification.titleLocArgs.first + l.sentYouMessage
    };
    final String title = titles[notification.titleLocKey] ??
        'Unknown titleLocKey: ${notification.titleLocKey}';

    _flutterLocalNotificationsPlugin.show(
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
              ? await getBitmapFromUrl(largeIconUrl)
              : null,
              styleInformation:  imageUrl != null
              ? BigPictureStyleInformation(await getBitmapFromUrl(imageUrl)) : null,
          priority: priority,
          visibility: visibility,
        ),
      ),
      payload: payload,
    );
  }
}
