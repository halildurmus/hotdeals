import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:loggy/loggy.dart' show NetworkLoggy;
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

import 'error_screen.dart';
import 'firebase_messaging_listener.dart';
import 'models/categories.dart';
import 'models/category.dart';
import 'models/my_user.dart';
import 'models/store.dart';
import 'models/stores.dart';
import 'offline_builder.dart';
import 'routing/app_router.dart';
import 'settings/locales.dart' as locales;
import 'settings/settings_controller.dart';
import 'sign_in/auth_widget.dart';
import 'sign_in/auth_widget_builder.dart';
import 'top_level_providers.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with NetworkLoggy {
  final FlexScheme usedFlexScheme = FlexScheme.deepBlue;
  late SettingsController settingsController;
  late List<Category>? categories;
  late List<Store>? stores;

  Widget buildMaterialApp({
    Widget? home,
    AsyncSnapshot<MyUser?>? userSnapshot,
  }) {
    return OverlaySupport.global(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: settingsController.locale,
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: locales.supportedLocales,
        theme: FlexColorScheme.light(
          scheme: usedFlexScheme,
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
        ).toTheme,
        darkTheme: FlexColorScheme.dark(
          scheme: usedFlexScheme,
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
        ).toTheme,
        themeMode: settingsController.themeMode,
        onGenerateTitle: (BuildContext context) =>
            AppLocalizations.of(context)!.appTitle,
        home: home ?? AuthWidget(userSnapshot: userSnapshot!),
        onGenerateRoute: (RouteSettings routeSettings) =>
            AppRouter.onGenerateRoute(
                routeSettings, userSnapshot!, settingsController),
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
    // Subscribes to Firebase Cloud Messaging.
    subscribeToFCM();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget buildErrorScreen() {
      Future<void> onTap() async {
        try {
          await Future.wait<dynamic>(
            <Future<dynamic>>[
              GetIt.I
                  .get<Categories>()
                  .getCategories()
                  .then<void>((List<Category> value) => categories = value),
              GetIt.I
                  .get<Stores>()
                  .getStores()
                  .then<void>((List<Store> value) => stores = value),
            ],
          );
        } on Exception {
          loggy.error('Failed to fetch categories and stores!');
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
      providers: buildTopLevelProviders(),
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
