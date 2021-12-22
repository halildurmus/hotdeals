import 'dart:async';
import 'dart:isolate';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:loggy/loggy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'src/app.dart';
import 'src/config/environment.dart';
import 'src/firebase_messaging_listener.dart';
import 'src/models/categories.dart';
import 'src/models/current_route.dart';
import 'src/models/stores.dart';
import 'src/search/search_service.dart';
import 'src/services/connection_service.dart';
import 'src/services/firebase_storage_service.dart';
import 'src/services/firestore_service.dart';
import 'src/services/image_picker_service.dart';
import 'src/services/push_notification_service.dart';
import 'src/services/spring_service.dart';
import 'src/settings/settings.controller.dart';
import 'src/settings/settings.service.dart';
import 'src/utils/crashlytics_printer.dart';
import 'src/utils/custom_loggy_printer.dart';
import 'src/utils/tr_messages.dart';
import 'src/widgets/loading_dialog.dart';
import 'src/widgets/sign_in_dialog.dart';

void _initLoggy() {
  Loggy.initLoggy(
    logOptions: const LogOptions(LogLevel.all, stackTraceLevel: LogLevel.error),
    logPrinter: kDebugMode
        ? CustomLoggyPrinter(printTime: true)
        : const CrashlyticsPrinter(),
  );
}

Future<void> _setupCrashlytics() async {
  if (kDebugMode) {
    // Disable Crashlytics collection while doing every day development.
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  }
  Function originalOnError = FlutterError.onError!;
  FlutterError.onError = (errorDetails) async {
    logError(errorDetails.toString());
    if (kReleaseMode) {
      // Pass all uncaught errors from the framework to Crashlytics.
      await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      // Forward to original handler.
      originalOnError(errorDetails);
    }
  };

  if (kReleaseMode) {
    // Pass all uncaught errors outside of the Flutter context to Crashlytics.
    Isolate.current.addErrorListener(RawReceivePort((pair) async {
      final List<dynamic> errorAndStacktrace = pair;
      logError('Caught error outside of isolate: ${errorAndStacktrace.first}');
      await FirebaseCrashlytics.instance.recordError(
        errorAndStacktrace.first,
        errorAndStacktrace.last,
      );
    }).sendPort);
  }
}

Future<void> _setupLocalNotifications() async {
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
  GetIt.I.registerSingleton<AndroidNotificationChannel>(notificationChannel);
  GetIt.I.registerSingleton<FlutterLocalNotificationsPlugin>(
      flutterLocalNotificationsPlugin);
}

void _initEnvConfig() {
  // Reads the environment value.
  const environmentKey = String.fromEnvironment(
    'ENV',
    defaultValue: Environment.dev,
  );
  // Initializies the proper environment configuration.
  final environment = Environment()..initialize(environmentKey);
  GetIt.I.registerSingleton<Environment>(environment);
}

Future<void> _initSettings() async {
  // Initializes a new SharedPreferences instance.
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  // Sets up the SearchService, and registers it as a Singleton class.
  GetIt.I.registerSingleton<SearchService>(SearchService(prefs));
  // Sets up the SettingsController, and registers it as a Singleton class.
  GetIt.I.registerSingleton<SettingsController>(
      SettingsController(SettingsService(prefs)));
  // Loads the user's preferred settings.
  await GetIt.I.get<SettingsController>().loadSettings();
}

void _registerSingletonClasses() {
  final GetIt getIt = GetIt.I;
  getIt.registerSingleton<CurrentRoute>(CurrentRoute());
  getIt.registerSingleton<ConnectionService>(ConnectionService()..initialize());
  getIt.registerSingleton<PushNotificationService>(
      PushNotificationService()..load());
  getIt.registerSingleton<FirebaseStorageService>(FirebaseStorageService());
  getIt.registerSingleton<FirestoreService>(FirestoreService());
  getIt.registerSingleton<ImagePickerService>(ImagePickerService());
  getIt.registerSingleton<SpringService>(SpringService());
  getIt.registerSingleton<Categories>(Categories());
  getIt.registerSingleton<Stores>(Stores());
  getIt.registerSingleton<LoadingDialog>(const LoadingDialog());
  getIt.registerSingleton<SignInDialog>(const SignInDialog());
}

void main() async {
  runZonedGuarded<Future<void>>(() async {
    _initLoggy();
    WidgetsFlutterBinding.ensureInitialized();
    // Initializes a new Firebase App instance.
    await Firebase.initializeApp();
    _setupCrashlytics();
    _initEnvConfig();
    final futures = await Future.wait<dynamic>([
      DeviceInfoPlugin().androidInfo,
      // See https://github.com/FirebaseExtended/flutterfire/issues/6011
      FirebaseMessaging.instance.getToken(),
      _setupLocalNotifications(),
      _initSettings(),
    ]);
    final androidDeviceInfo = futures[0] as AndroidDeviceInfo;
    GetIt.I.registerSingleton<AndroidDeviceInfo>(androidDeviceInfo);
    // Sets a message handler function which is called when the app is in the
    // background or terminated.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    _registerSingletonClasses();
    // Registers Turkish messages for timeago.
    timeago.setLocaleMessages('tr', TrMessages());
    timeago.setLocaleMessages('tr_short', TrShortMessages());
    // Runs the app with MyApp attached to the screen.
    runApp(const MyApp());
  }, (error, stack) {
    logError(error.toString());
    FirebaseCrashlytics.instance.recordError(error, stack);
  });
}
