import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../settings/settings.controller.dart';

/// A static class that contains useful utility functions for notification
/// functionality.
class NotificationUtil {
  static void _validateImageUrl(String url) {
    final pattern = RegExp(r'^http[s]?://');
    final hasMatch = pattern.hasMatch(url);
    if (!hasMatch) {
      throw Exception('`imageUrl` must start with `http://` or `https://`');
    }
  }

  static Future<AndroidBitmap<Object>> _createAndroidBitmap(
      String imageUrl) async {
    _validateImageUrl(imageUrl);
    final response = await http.get(Uri.parse(imageUrl));
    final base64Image = base64.encode(response.bodyBytes);

    return ByteArrayAndroidBitmap.fromBase64String(base64Image);
  }

  static final _flutterLocalNotificationsPlugin =
      GetIt.I.get<FlutterLocalNotificationsPlugin>();
  static final _channel = GetIt.I.get<AndroidNotificationChannel>();
  static final _settingsController = GetIt.I.get<SettingsController>();

  static Future<void> showNotification(
    RemoteNotification notification, {
    String? imageUrl,
    Importance importance = Importance.max,
    String? largeIconUrl,
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
    final title = titles[notification.titleLocKey] ??
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
}
