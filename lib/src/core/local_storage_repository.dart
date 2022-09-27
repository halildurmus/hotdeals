import 'package:flutter/material.dart' show Locale, ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localStorageRepositoryProvider =
    Provider<LocalStorageRepository>((ref) => throw UnimplementedError());

abstract class LocalStorageRepository {
  Future<Locale?> loadLocale();

  Future<List<String>?> loadRecentSearchHistory();

  Future<ThemeMode?> loadThemeMode();

  Future<void> saveLocale(Locale locale);

  Future<void> saveRecentSearchHistory(List<String> recentSearchHistory);

  Future<void> saveThemeMode(ThemeMode themeMode);
}
