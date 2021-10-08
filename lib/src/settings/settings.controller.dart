import 'package:flutter/material.dart';

import 'settings.service.dart';

/// A class that many Widgets can interact with to read user settings,
/// update user settings, or listen to user settings changes.
///
/// Controllers glue Data Services to Flutter Widgets.
/// The [SettingsController] uses the [SettingsService] to store
/// and retrieve user settings.
class SettingsController extends ChangeNotifier {
  SettingsController(this._settingsService);

  // Make SettingsService a private variable so it is not used directly.
  final SettingsService _settingsService;

  // Make locale a private variable so it is not updated directly without
  // also persisting the changes with the SettingsService.
  late Locale _locale;

  // Allow Widgets to read the user's preferred locale.
  Locale get locale => _locale;

  // Make ThemeMode a private variable so it is not updated directly without
  // also persisting the changes with the SettingsService.
  late ThemeMode _themeMode;

  // Allow Widgets to read the user's preferred ThemeMode.
  ThemeMode get themeMode => _themeMode;

  /// Load the user's settings from the SettingsService. It may load from a
  /// local database or the internet. The controller only knows it can load the
  /// settings from the service.
  Future<void> loadSettings() async {
    _locale = await _settingsService.locale();
    _themeMode = await _settingsService.themeMode();

    // Informs listeners a change has occurred.
    notifyListeners();
  }

  /// Update and persist the locale based on the user's selection.
  Future<void> updateLocale(Locale? newLocale) async {
    if (newLocale == null) {
      return;
    }

    // Dot not perform any work if new and old locale are identical
    if (newLocale == _locale) {
      return;
    }

    // Otherwise, store the new locale in memory
    _locale = newLocale;

    // Informs listeners a change has occurred.
    notifyListeners();

    // Persist the changes to a local database using the SettingService.
    await _settingsService.updateLocale(newLocale);
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) {
      return;
    }

    // Dot not perform any work if new and old ThemeMode are identical
    if (newThemeMode == _themeMode) {
      return;
    }

    // Otherwise, store the new theme mode in memory
    _themeMode = newThemeMode;

    // Informs listeners a change has occurred.
    notifyListeners();

    // Persist the changes to a local database or the internet using the
    // SettingService.
    await _settingsService.updateThemeMode(newThemeMode);
  }
}
