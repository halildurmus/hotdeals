import 'package:flutter/material.dart';

/// An abstract class used for storing and retrieving user settings.
abstract class SettingsService {
  /// Loads the user's preferred [Locale].
  Future<Locale> locale();

  /// Loads the user's preferred [ThemeMode].
  Future<ThemeMode> themeMode();

  /// Persists the user's preferred locale to local storage.
  Future<void> updateLocale(Locale locale);

  /// Persists the user's preferred [ThemeMode] to local storage.
  Future<void> updateThemeMode(ThemeMode theme);
}
