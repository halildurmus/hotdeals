import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:loggy/loggy.dart' show NetworkLoggy;
import 'package:provider/provider.dart';

import 'constants.dart';
import 'error_screen.dart';
import 'models/categories.dart';
import 'models/my_user.dart';
import 'models/stores.dart';
import 'offline_builder.dart';
import 'routing/app_router.dart';
import 'settings/settings.controller.dart';
import 'sign_in/auth_widget.dart';
import 'sign_in/auth_widget_builder.dart';
import 'top_level_providers.dart';

enum _FutureState { loading, success, error }

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with NetworkLoggy {
  late final SettingsController settingsController;
  _FutureState _futureState = _FutureState.loading;

  @override
  void initState() {
    settingsController = GetIt.I.get<SettingsController>();
    _fetchCategoriesAndStores();
    super.initState();
  }

  void _fetchCategoriesAndStores([BuildContext? ctx]) {
    Future.wait<dynamic>([
      GetIt.I.get<Categories>().getCategories(),
      GetIt.I.get<Stores>().getStores(),
    ]).then((_) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        // If ctx is provided, pops the LoadingDialog in the ErrorScreen.
        if (ctx != null) {
          Navigator.of(ctx).pop();
        }
        setState(() => _futureState = _FutureState.success);
      });
    }).catchError((e) {
      loggy.error(e);
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        // If ctx is provided, pops the LoadingDialog in the ErrorScreen.
        if (ctx != null) {
          Navigator.of(ctx).pop();
        }
        setState(() => _futureState = _FutureState.error);
      });
    });
  }

  Widget _buildMaterialApp({
    Widget? home,
    AsyncSnapshot<MyUser?>? userSnapshot,
  }) =>
      MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: settingsController.locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: FlexColorScheme.light(
          scheme: usedFlexScheme,
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
        ).toTheme.copyWith(pageTransitionsTheme: pageTransitionsTheme),
        darkTheme: FlexColorScheme.dark(
          scheme: usedFlexScheme,
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
        ).toTheme.copyWith(pageTransitionsTheme: pageTransitionsTheme),
        themeMode: settingsController.themeMode,
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        home: home ?? AuthWidget(userSnapshot: userSnapshot!),
        onGenerateRoute: (routeSettings) => AppRouter.onGenerateRoute(
          routeSettings,
          userSnapshot!,
          settingsController,
        ),
        builder: home == null ? buildOfflineBuilder : null,
      );

  @override
  Widget build(BuildContext context) {
    if (_futureState == _FutureState.loading) {
      // TODO(halildurmus): Replace this with a splash screen
      return _buildMaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text(appTitle),
          ),
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    } else if (_futureState == _FutureState.error) {
      return _buildMaterialApp(
        home: ErrorScreen(
          onTap: _fetchCategoriesAndStores,
        ),
      );
    }

    return MultiProvider(
      providers: buildTopLevelProviders(),
      child: AuthWidgetBuilder(
        builder: (context, userSnapshot) => AnimatedBuilder(
          animation: settingsController,
          builder: (context, child) =>
              _buildMaterialApp(userSnapshot: userSnapshot),
        ),
      ),
    );
  }
}
