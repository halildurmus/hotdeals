import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../constants.dart';

extension LocalizationHelper on Widget {
  /// Shorter and easier way to access `AppLocalizations.of(context)!`.
  /// ```dart
  /// var titleText = l(context).title;
  /// ```
  AppLocalizations l(BuildContext ctx) => AppLocalizations.of(ctx)!;
}

extension LocalizationHelperStateless on StatelessWidget {
  /// Shorter and easier way to access `AppLocalizations.of(context)`.
  /// ```dart
  /// var titleText = l(context).title;
  /// ```
  AppLocalizations l(BuildContext ctx) => AppLocalizations.of(ctx)!;
}

extension LocalizationHelperStateful<T extends StatefulWidget> on State<T> {
  /// Shorter and easier way to access `AppLocalizations.of(context)`.
  /// ```dart
  /// var titleText = l(context).title;
  /// ```
  AppLocalizations l(BuildContext ctx) => AppLocalizations.of(ctx)!;
}

/// A static class that contains useful functions for localization.
class LocalizationUtil {
  /// Returns the asset name for the given [locale] mapped in [localeAssets].
  static String getAssetName(Locale locale) =>
      localeAssets[locale] ?? assetEnglish;

  /// Returns the locale name for the given [locale].
  static String getLocaleName(BuildContext context, Locale locale) {
    final languageNames = <Locale, String>{
      localeEnglish: AppLocalizations.of(context)!.english,
      localeTurkish: AppLocalizations.of(context)!.turkish,
    };

    return languageNames[locale] ?? AppLocalizations.of(context)!.english;
  }
}
