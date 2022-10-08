import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loggy/loggy.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'src/app/app.dart';
import 'src/core/connection_service.dart';
import 'src/core/local_storage_repository.dart';
import 'src/core/package_info_provider.dart';
import 'src/core/shared_preferences_repository.dart';
import 'src/features/notifications/data/providers.dart';
import 'src/features/notifications/data/push_notification_service.dart';
import 'src/features/notifications/domain/push_notification.dart';
import 'src/l10n/timeago_tr_messages.dart';
import 'src/logging/crashlytics_printer.dart';
import 'src/logging/custom_loggy_printer.dart';
import 'src/logging/provider_logger.dart';

void _initLoggy() {
  Loggy.initLoggy(
    logOptions: const LogOptions(LogLevel.all, stackTraceLevel: LogLevel.error),
    logPrinter: kDebugMode
        ? CustomLoggyPrinter(printTime: true)
        : const CrashlyticsPrinter(),
  );
}

Future<void> _setupCrashlytics() async {
  PlatformDispatcher.instance.onError = (error, stack) {
    logError(error.toString());
    FirebaseCrashlytics.instance.recordError(error, stack);
    return true;
  };

  if (kDebugMode) {
    // Disable Crashlytics collection while doing every day development.
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  }

  final Function originalOnError = FlutterError.onError!;
  FlutterError.onError = (errorDetails) async {
    logError(errorDetails.toString());
    FlutterError.presentError(errorDetails);
    if (kReleaseMode) {
      // Pass all uncaught errors from the framework to Crashlytics.
      await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      // Forward to original handler.
      originalOnError(errorDetails);
    }
  };

  ErrorWidget.builder = (errorDetails) => Align(
        alignment: Alignment.center,
        child: Text(
          'Error!\n${errorDetails.exception}',
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        ),
      );
}

void _registerTimeagoLocales() {
  // Registers Turkish Locale messages for timeago package.
  timeago.setLocaleMessages('tr', TrMessages());
  timeago.setLocaleMessages('tr_short', TrShortMessages());
}

/// A Firebase message handler function which is called when the app is in the
/// background or terminated.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  logInfo('Handling a background message: ${message.messageId}');
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
      await pushNotificationService.insert(pushNotification);
      logInfo('Background notification saved into the db.');
    }
  }
}

Future<void> main() async {
  _initLoggy();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await _setupCrashlytics();

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const notificationChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );
  // Creates an Android Notification Channel.
  // We use this channel in the 'AndroidManifest.xml' file to override the
  // default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(notificationChannel);

  // Sets a message handler function which is called when the app is in the
  // background or terminated.
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  _registerTimeagoLocales();

  final pushNotificationService = PushNotificationService();
  final futures = await Future.wait([
    // See https://github.com/FirebaseExtended/flutterfire/issues/6011
    FirebaseMessaging.instance.getToken(),
    PackageInfo.fromPlatform(),
    SharedPreferences.getInstance(),
    pushNotificationService.load(),
  ], eagerError: true);

  runApp(
    ProviderScope(
      observers: kDebugMode ? [ProviderLogger()] : null,
      overrides: [
        androidNotificationChannelProvider
            .overrideWithValue(notificationChannel),
        connectionServiceProvider
            .overrideWithValue(ConnectionService()..initialize()),
        flutterLocalNotificationsPluginProvider
            .overrideWithValue(flutterLocalNotificationsPlugin),
        localStorageRepositoryProvider.overrideWithValue(
            SharedPreferencesRepository(futures[2] as SharedPreferences)),
        packageInfoProvider.overrideWithValue(futures[1] as PackageInfo),
        pushNotificationServiceProvider
            .overrideWithValue(pushNotificationService),
      ],
      child: const MyApp(),
    ),
  );
}
