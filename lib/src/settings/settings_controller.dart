import 'package:flutter/material.dart';

/// An abstract class that many Widgets can interact with to read user settings,
/// update user settings, or listen to user settings changes.
abstract class SettingsController extends ChangeNotifier {
  /// Returns the user's preferred [Locale].
  Locale get locale;

  /// Returns the user's preferred [ThemeMode].
  ThemeMode get themeMode;

  /// Loads the user's settings.
  Future<void> loadSettings();

  /// Updates and persists the locale based on the user's selection.
  Future<void> updateLocale(Locale? newLocale);

  /// Updates and persists the [ThemeMode] based on the user's selection.
  Future<void> updateThemeMode(ThemeMode? newThemeMode);
}
