import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
import 'src/services/connection_service.dart';
import 'src/services/firebase_storage_service.dart';
import 'src/services/firebase_storage_service_impl.dart';
import 'src/services/firestore_service.dart';
import 'src/services/firestore_service_impl.dart';
import 'src/services/image_picker_service.dart';
import 'src/services/image_picker_service_impl.dart';
import 'src/services/push_notification_service.dart';
import 'src/services/push_notification_service_impl.dart';
import 'src/services/spring_service.dart';
import 'src/services/spring_service_impl.dart';
import 'src/settings/settings.controller.impl.dart';
import 'src/settings/settings.service.impl.dart';
import 'src/settings/settings_controller.dart';
import 'src/utils/crashlytics_printer.dart';
import 'src/utils/custom_loggy_printer.dart';
import 'src/utils/tr_messages.dart';
import 'src/widgets/loading_dialog.dart';

Future<void> main() async {
  runZonedGuarded<Future<void>>(() async {
    Loggy.initLoggy(
      logOptions:
          const LogOptions(LogLevel.all, stackTraceLevel: LogLevel.error),
      logPrinter: kDebugMode
          ? CustomLoggyPrinter(printTime: true)
          : const CrashlyticsPrinter(),
    );

    WidgetsFlutterBinding.ensureInitialized();
    // Initializes a new Firebase App instance.
    await Firebase.initializeApp();

    if (kDebugMode) {
      // Disable Crashlytics collection while doing every day development.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    }
    FlutterError.onError = (errorDetails) async {
      logError(errorDetails.toString());
      if (!kDebugMode) {
        // Pass all uncaught errors from the framework to Crashlytics.
        await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      }
    };

    // Fetches the default FCM token for this device.
    await FirebaseMessaging.instance.getToken();

    // Sets a message handler function which is called when the app is in the
    // background or terminated.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    GetIt.I.registerSingleton<Environment>(Environment());
    // Reads the environment value.
    const String environment = String.fromEnvironment(
      'ENV',
      defaultValue: Environment.dev,
    );
    // Initializes the Environment configuration.
    GetIt.I.get<Environment>().initialize(environment);

    // Registers Singleton classes.
    final GetIt getIt = GetIt.I;
    getIt.registerSingleton<CurrentRoute>(CurrentRoute());
    getIt.registerSingleton<ConnectionService>(ConnectionService());
    getIt.registerSingleton<PushNotificationService>(
        PushNotificationServiceImpl());
    getIt.registerSingleton<FirebaseStorageService>(
        FirebaseStorageServiceImpl());
    getIt.registerSingleton<FirestoreService>(FirestoreServiceImpl());
    getIt.registerSingleton<ImagePickerService>(ImagePickerServiceImpl());
    getIt.registerSingleton<SpringService>(SpringServiceImpl());
    getIt.registerSingleton<Categories>(Categories());
    getIt.registerSingleton<Stores>(Stores());
    getIt.registerSingleton<LoadingDialog>(const LoadingDialog());

    // Fetches categories and stores.
    try {
      await Future.wait<dynamic>(
        <Future<dynamic>>[
          getIt.get<Categories>().getCategories(),
          getIt.get<Stores>().getStores(),
        ],
      );
    } on Exception catch (e, stack) {
      logError('Failed to fetch categories and stores!');
      FirebaseCrashlytics.instance.recordError(e, stack);
    }

    // Initializes the ConnectionService.
    getIt.get<ConnectionService>().initialize();

    // Loads the sqlite database.
    await getIt.get<PushNotificationService>().load();

    // Calculates the unread notifications count if there is a signed in user.
    if (FirebaseAuth.instance.currentUser != null) {
      await getIt.get<PushNotificationService>().calculateUnreadNotifications();
    }

    // Initializes a new SharedPreferences instance.
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Sets up the SettingsController, and registers it as a Singleton class.
    getIt.registerSingleton<SettingsController>(
        SettingsControllerImpl(SettingsServiceImpl(prefs)));

    // Loads the user's preferred settings.
    await getIt.get<SettingsController>().loadSettings();

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
