import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'localization_constants.dart';

/// Returns the asset name for the given [locale] mapped in [localeAssets].
String assetNameFromLocale(Locale locale) =>
    localeAssets[locale] ?? assetEnglish;

/// Returns the locale name for the given [locale].
String localeNameFromLocale(BuildContext context, Locale locale) {
  final languageNames = {
    localeEnglish: AppLocalizations.of(context)!.english,
    localeTurkish: AppLocalizations.of(context)!.turkish,
  };

  return languageNames[locale] ?? AppLocalizations.of(context)!.english;
}

/// Returns the [ThemeMode] text for the given [themeMode].
String themeModeTextFromThemeMode(BuildContext context, ThemeMode themeMode) {
  switch (themeMode) {
    case ThemeMode.dark:
      return AppLocalizations.of(context)!.dark;
    case ThemeMode.light:
      return AppLocalizations.of(context)!.light;
    case ThemeMode.system:
      return AppLocalizations.of(context)!.system;
  }
}
