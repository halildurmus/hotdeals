import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension BuildContextHelper on BuildContext {
  /// Shorter and easier way to access `AppLocalizations.of(context)`.
  /// ```dart
  /// var titleText = l.title;
  /// ```
  AppLocalizations get l => AppLocalizations.of(this)!;

  /// Shorter and easier way to access `Localizations.localeOf(context)`.
  Locale get locale => Localizations.localeOf(this);

  /// Shorter and easier way to access `MediaQuery.of(context)`.
  MediaQueryData get mq => MediaQuery.of(this);

  /// Shorter and easier way to show a [SnackBar].
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
      SnackBar snackBar) {
    return ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }

  /// Shorter and easier way to access `Theme.of(context)`.
  ThemeData get t => Theme.of(this);

  /// Shorter and easier way to access `Theme.of(context).colorScheme`.
  ColorScheme get colorScheme => t.colorScheme;

  /// Shorter and easier way to access `Theme.of(context).textTheme`.
  TextTheme get textTheme => t.textTheme;

  /// Whether the current theme brightness is [Brightness.dark].
  bool get isDarkMode => t.brightness == Brightness.dark;

  /// Whether the current theme brightness is [Brightness.light].
  bool get isLightMode => !isDarkMode;
}
