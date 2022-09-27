import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loggy/loggy.dart';

import '../common_widgets/error_indicator.dart';
import '../core/connection_service.dart';
import '../core/hotdeals_repository.dart';
import '../features/browse/data/categories_provider.dart';
import '../features/browse/data/stores_provider.dart';
import '../features/browse/domain/category.dart';
import '../features/browse/domain/store.dart';
import '../features/settings/presentation/locale_controller.dart';
import '../features/settings/presentation/theme_mode_controller.dart';
import '../l10n/localization_constants.dart';
import '../routing/router.dart';
import '../theme/theme_constants.dart';
import 'no_internet_screen.dart';
import 'offline_builder.dart';

final _categoriesAndStoresFutureProvider = FutureProvider<List<Object>>(
  (ref) async => await Future.wait([
    ref.read(hotdealsRepositoryProvider).getCategories(),
    ref.read(hotdealsRepositoryProvider).getStores(),
  ], eagerError: true),
  name: 'CategoriesAndStoresFutureProvider',
);

class MyApp extends ConsumerWidget with NetworkLoggy {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAndStores = ref.watch(_categoriesAndStoresFutureProvider);
    if (categoriesAndStores.isLoading || categoriesAndStores.isRefreshing) {
      return _MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text(appTitle),
          ),
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return categoriesAndStores.maybeWhen(
      data: (data) {
        loggy.info('Categories and stores loaded successfully.');
        ref.read(categoriesProvider).categories = data[0] as List<Category>;
        ref.read(storesProvider).stores = data[1] as List<Store>;
        final connectionService = ref.watch(connectionServiceProvider);
        final locale = ref.watch(localeControllerProvider);
        final themeMode = ref.watch(themeModeControllerProvider);
        final router = ref.watch(routerProvider);

        return MaterialApp.router(
          builder: (context, child) => OfflineBuilder(
            connectionService: connectionService,
            connectivityBuilder: (context, isConnected, child) =>
                isConnected ? child : const NoInternetScreen(),
            errorBuilder: (context) => const NoInternetScreen(),
            child: child,
          ),
          darkTheme: darkAppTheme,
          debugShowCheckedModeBanner: false,
          locale: locale,
          localizationsDelegates: localizationDelegates,
          routeInformationParser: router.routeInformationParser,
          routeInformationProvider: router.routeInformationProvider,
          routerDelegate: router.routerDelegate,
          supportedLocales: supportedLocales,
          theme: lightAppTheme,
          themeMode: themeMode,
          title: appTitle,
        );
      },
      orElse: () => _MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text(appTitle),
          ),
          body: NoConnectionError(
            onPressed: () =>
                ref.refresh(_categoriesAndStoresFutureProvider.future),
          ),
        ),
      ),
    );
  }
}

class _MaterialApp extends ConsumerWidget {
  const _MaterialApp({required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);
    final themeMode = ref.watch(themeModeControllerProvider);

    return MaterialApp(
      darkTheme: darkAppTheme,
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: localizationDelegates,
      supportedLocales: supportedLocales,
      theme: lightAppTheme,
      themeMode: themeMode,
      title: appTitle,
      home: home,
    );
  }
}
