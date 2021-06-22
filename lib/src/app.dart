import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'error_screen.dart';
import 'models/categories.dart';
import 'models/category.dart';
import 'models/my_user.dart';
import 'models/push_notification.dart';
import 'models/store.dart';
import 'models/stores.dart';
import 'no_internet.dart';
import 'profile/profile.dart';
import 'services/auth_service.dart';
import 'services/auth_service_adapter.dart';
import 'services/connection_service.dart';
import 'services/sqlite_service.dart';
import 'settings/settings.view.dart';
import 'settings/settings_controller.dart';
import 'sign_in/auth_widget.dart';
import 'sign_in/auth_widget_builder.dart';
import 'widgets/offline_builder.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlexScheme usedFlexScheme = FlexScheme.deepBlue;
  late SettingsController settingsController;
  late List<Category>? categories;
  late List<Store>? stores;

  List<SingleChildStatelessWidget> buildProviders() {
    return <SingleChildStatelessWidget>[
      Provider<AuthService>(
        create: (_) => AuthServiceAdapter(),
        dispose: (_, AuthService authService) => authService.dispose(),
      ),
    ];
  }

  MaterialPageRoute<void> buildRoutes(
      RouteSettings routeSettings, AsyncSnapshot<MyUser?> userSnapshot) {
    return MaterialPageRoute<void>(
      settings: routeSettings,
      builder: (BuildContext context) {
        switch (routeSettings.name) {
          case Profile.routeName:
            return const Profile();
          case SettingsView.routeName:
            return SettingsView(controller: settingsController);
          default:
            return AuthWidget(userSnapshot: userSnapshot);
        }
      },
    );
  }

  Widget buildOfflineBuilder(BuildContext context, Widget? child) {
    return OfflineBuilder(
      connectionService: GetIt.I.get<ConnectionService>(),
      connectivityBuilder: (
        BuildContext context,
        bool isConnected,
        Widget child,
      ) {
        return isConnected ? child : const NoInternet();
      },
      errorBuilder: (BuildContext context) => const NoInternet(),
      child: child,
    );
  }

  Widget buildMaterialApp({
    Widget? home,
    AsyncSnapshot<MyUser?>? userSnapshot,
  }) {
    return OverlaySupport.global(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'hotdeals',
        theme: FlexColorScheme.light(
          scheme: usedFlexScheme,
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
        ).toTheme,
        darkTheme: FlexColorScheme.dark(
          scheme: usedFlexScheme,
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
        ).toTheme,
        themeMode: settingsController.themeMode,
        // onGenerateTitle: (BuildContext context) =>
        // AppLocalizations.of(context)!.appTitle,
        home: home ?? AuthWidget(userSnapshot: userSnapshot!),
        onGenerateRoute: home == null
            ? (RouteSettings routeSettings) =>
                buildRoutes(routeSettings, userSnapshot!)
            : null,
        builder: home == null
            ? (BuildContext context, Widget? child) =>
                buildOfflineBuilder(context, child)
            : null,
      ),
    );
  }

  @override
  void initState() {
    settingsController = GetIt.I.get<SettingsController>();
    categories = GetIt.I.get<Categories>().categories;
    stores = GetIt.I.get<Stores>().stores;
    final SQLiteService<PushNotification> sqliteService =
        GetIt.I.get<SQLiteService<PushNotification>>();

    // Sets a message handler function which is called when the app is in the
    // foreground.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');

        final PushNotification notification = PushNotification(
          title: message.notification!.title!,
          body: message.notification!.body!,
          dataTitle: message.data['title'] as String,
          dataBody: message.data['body'] as String,
          createdAt: message.sentTime,
        );
        // Saves the notification into the database.
        sqliteService
            .insert(notification)
            .then((value) => print('Notification saved into the db.'));

        showOverlayNotification(
          (BuildContext context) {
            return MessageNotification(notification: notification);
          },
          duration: const Duration(seconds: 5),
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget buildErrorScreen() {
      Future<void> onTap() async {
        try {
          categories = await GetIt.I.get<Categories>().getCategories();
          stores = await GetIt.I.get<Stores>().getStores();
        } on Exception catch (e) {
          print('Failed to fetch categories and stores!');
          print(e);
        } finally {
          if (categories != null && stores != null) {
            setState(() {});
          }
        }
      }

      return buildMaterialApp(home: ErrorScreen(onTap: onTap));
    }

    if (categories == null || stores == null) {
      return buildErrorScreen();
    }

    return MultiProvider(
      providers: buildProviders(),
      child: AuthWidgetBuilder(
        builder: (BuildContext context, AsyncSnapshot<MyUser?> userSnapshot) {
          return AnimatedBuilder(
            animation: settingsController,
            builder: (BuildContext context, Widget? child) {
              return buildMaterialApp(userSnapshot: userSnapshot);
            },
          );
        },
      ),
    );
  }
}

class MessageNotification extends StatelessWidget {
  const MessageNotification({Key? key, required this.notification})
      : super(key: key);

  final PushNotification notification;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: SafeArea(
        child: ListTile(
          leading: SizedBox.fromSize(
            size: const Size(40, 40),
            child: const CircleAvatar(),
          ),
          title: Text(notification.title),
          subtitle: Text(notification.body),
          // trailing: IconButton(
          //   onPressed: () {},
          //   icon: const Icon(Icons.reply),
          // ),
        ),
      ),
    );
  }
}
