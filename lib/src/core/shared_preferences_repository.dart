import 'package:flutter/material.dart' show Locale, ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

import 'local_storage_repository.dart';

class SharedPreferencesRepository implements LocalStorageRepository {
  SharedPreferencesRepository(this._prefs);

  final SharedPreferences _prefs;

  static const String _appLocaleKey = 'app-locale';
  static const String _appRecentSearchesKey = 'app-recent-searches';
  static const String _appThemeKey = 'app-theme';

  @override
  Future<Locale?> loadLocale() async {
    final languageCode = _prefs.getString(_appLocaleKey);
    if (languageCode == null) return null;
    return Locale(languageCode);
  }

  @override
  Future<List<String>?> loadRecentSearchHistory() =>
      Future.value(_prefs.getStringList(_appRecentSearchesKey));

  @override
  Future<ThemeMode?> loadThemeMode() async {
    final themeModeName = _prefs.getString(_appThemeKey);
    if (themeModeName == null) return null;
    return ThemeMode.values.byName(themeModeName);
  }

  @override
  Future<void> saveLocale(Locale locale) =>
      _prefs.setString(_appLocaleKey, locale.toLanguageTag());

  @override
  Future<void> saveRecentSearchHistory(List<String> recentSearchHistory) =>
      _prefs.setStringList(_appRecentSearchesKey, recentSearchHistory);

  @override
  Future<void> saveThemeMode(ThemeMode themeMode) =>
      _prefs.setString(_appThemeKey, themeMode.name);
}
