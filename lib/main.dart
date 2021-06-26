import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app.dart';
import 'src/models/categories.dart';
import 'src/models/category.dart';
import 'src/models/push_notification.dart';
import 'src/models/store.dart';
import 'src/models/stores.dart';
import 'src/services/connection_service.dart';
import 'src/services/firestore_service.dart';
import 'src/services/spring_service.dart';
import 'src/services/spring_service_impl.dart';
import 'src/services/sqlite_service.dart';
import 'src/services/sqlite_service_impl.dart';
import 'src/settings/settings.controller.impl.dart';
import 'src/settings/settings.service.impl.dart';
import 'src/settings/settings_controller.dart';
import 'src/widgets/loading_dialog.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initializes a new Firebase App instance.
  await Firebase.initializeApp();

  print('Handling a background message: ${message.messageId}');

  // Creates a new SQLiteServiceImpl instance.
  final SQLiteService<PushNotification> sqliteService = SQLiteServiceImpl();

  // Loads the sqlite database.
  await sqliteService.load();

  // Constructs a PushNotification from the RemoteMessage.
  final PushNotification notification = PushNotification(
    title: message.notification!.title!,
    body: message.notification!.body!,
    actor: message.data['actor'] as String,
    verb: message.data['verb'] as String,
    object: message.data['object'] as String,
    message: message.data['message'] as String?,
    createdAt: message.sentTime,
  );

  // Saves the notification into the database.
  sqliteService
      .insert(notification)
      .then((value) => print('Background notification saved into the db.'));
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initializes a new Firebase App instance.
  await Firebase.initializeApp();

  // Fetches the default FCM token for this device.
  await FirebaseMessaging.instance.getToken();

  // Sets a message handler function which is called when the app is in the
  // background or terminated.
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Registers Singleton classes.
  final GetIt getIt = GetIt.I;
  getIt.registerSingleton<ConnectionService>(ConnectionService());
  getIt.registerSingleton<SQLiteService<PushNotification>>(SQLiteServiceImpl());
  getIt.registerSingleton<FirestoreService>(FirestoreService());
  getIt.registerSingleton<SpringService>(SpringServiceImpl());
  getIt.registerSingleton<Categories>(Categories());
  getIt.registerSingleton<Stores>(Stores());
  getIt.registerSingleton<LoadingDialog>(const LoadingDialog());

  // Fetches categories and stores.
  await getIt
      .get<Categories>()
      .getCategories()
      .onError((Object? error, StackTrace stackTrace) => <Category>[]);
  await getIt
      .get<Stores>()
      .getStores()
      .onError((Object? error, StackTrace stackTrace) => <Store>[]);

  // Initializes the ConnectionService.
  getIt.get<ConnectionService>().initialize();

  // Loads the sqlite database.
  await getIt.get<SQLiteService<PushNotification>>().load();

  // Calculates the unread notifications count.
  await getIt
      .get<SQLiteService<PushNotification>>()
      .calculateUnreadNotifications();

  // Initializes a new SharedPreferences instance.
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // Sets up the SettingsController, and registers it as a Singleton class.
  getIt.registerSingleton<SettingsController>(
      SettingsControllerImpl(SettingsServiceImpl(prefs)));

  // Loads the user's preferred settings.
  await getIt.get<SettingsController>().loadSettings();

  // Runs the app with MyApp attached to the screen.
  runApp(const MyApp());
}
