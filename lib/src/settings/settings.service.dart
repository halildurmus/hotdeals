import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Locale, ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

/// A class used for storing and retrieving user settings.
///
/// This service persist the user settings locally, using the
/// [shared_preferences] package.
class SettingsService {
  SettingsService(this._prefs);

  final SharedPreferences _prefs;
  static const String _languageKey = 'app-language';
  static const String _themeKey = 'app-theme';

  /// Loads the user's preferred language from [SharedPreferences].
  ///
  /// If the preferred language is not found then [Platform.localeName] is used.
  Future<Locale> locale() async {
    final languageTag =
        _prefs.getString(_languageKey) ?? Platform.localeName.split('_')[0];

    return Locale(languageTag);
  }

  /// Persists the user's preferred language to local storage.
  Future<void> updateLocale(Locale language) async {
    _prefs.setString(_languageKey, language.toLanguageTag());
  }

  /// Loads the user's preferred [ThemeMode] from [SharedPreferences].
  Future<ThemeMode> themeMode() async {
    final appThemeValue = _prefs.getString(_themeKey);
    if (appThemeValue == 'light') {
      return ThemeMode.light;
    } else if (appThemeValue == 'dark') {
      return ThemeMode.dark;
    }

    return ThemeMode.system;
  }

  /// Persists the user's preferred [ThemeMode] to local storage.
  Future<void> updateThemeMode(ThemeMode theme) async {
    _prefs.setString(_themeKey, describeEnum(theme));
  }
}
