import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Locale, ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_service.dart';

/// A service that stores and retrieves user settings.
///
/// This class persist the user settings locally, using the
/// [shared_preferences] package.
class SettingsServiceImpl implements SettingsService {
  SettingsServiceImpl(this.prefs);

  final SharedPreferences prefs;
  static const String _languageKey = 'language';
  static const String _themeKey = 'appTheme';

  /// Loads the user's preferred language from [SharedPreferences].
  ///
  /// If the preferred language is not found then [Platform.localeName] is used.
  @override
  Future<Locale> locale() async {
    final String language = prefs.getString(_languageKey) ??
        Platform.localeName.replaceFirst('_', '-');
    final Locale locale = Locale.fromSubtags(
      languageCode: language.split('-')[0],
      countryCode: language.split('-')[1],
    );

    return locale;
  }

  /// Persists the user's preferred language to local storage.
  @override
  Future<void> updateLocale(Locale language) async {
    prefs.setString(_languageKey, language.toLanguageTag());
  }

  /// Loads the user's preferred [ThemeMode] from [SharedPreferences].
  @override
  Future<ThemeMode> themeMode() async {
    final String? appThemeValue = prefs.getString(_themeKey);
    if (appThemeValue == 'light') {
      return ThemeMode.light;
    } else if (appThemeValue == 'dark') {
      return ThemeMode.dark;
    }

    return ThemeMode.system;
  }

  /// Persists the user's preferred [ThemeMode] to local storage.
  @override
  Future<void> updateThemeMode(ThemeMode theme) async {
    prefs.setString(_themeKey, describeEnum(theme));
  }
}
