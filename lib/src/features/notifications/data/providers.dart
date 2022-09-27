import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final androidNotificationChannelProvider = Provider<AndroidNotificationChannel>(
    (ref) => throw UnimplementedError(),
    name: 'AndroidNotificationChannelProvider');

final flutterLocalNotificationsPluginProvider =
    Provider<FlutterLocalNotificationsPlugin>(
        (ref) => throw UnimplementedError(),
        name: 'FlutterLocalNotificationsPluginProvider');
