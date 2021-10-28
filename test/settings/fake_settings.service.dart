import 'dart:io';

import 'package:flutter/material.dart' show Locale;
import 'package:flutter/src/material/app.dart';
import 'package:hotdeals/src/settings/settings.service.dart';

/// A fake [SettingsService] implementation that used in testing.
class FakeSettingsService implements SettingsService {
  @override
  Future<Locale> locale() async {
    final languageCode = Platform.localeName.split('_')[0];
    final locale = Locale(languageCode);

    return Future<Locale>.value(locale);
  }

  @override
  Future<ThemeMode> themeMode() => Future<ThemeMode>.value(ThemeMode.dark);

  @override
  Future<void> updateLocale(Locale locale) => throw UnimplementedError();

  @override
  Future<void> updateThemeMode(ThemeMode theme) => throw UnimplementedError();
}
