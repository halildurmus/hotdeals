import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../common_widgets/loading_dialog.dart';

extension BuildContextHelper on BuildContext {
  /// Easier way to access `AppLocalizations.of(context)`.
  /// ```dart
  /// var titleText = l.title;
  /// ```
  AppLocalizations get l => AppLocalizations.of(this)!;

  /// Easier way to access `Localizations.localeOf(context)`.
  Locale get locale => Localizations.localeOf(this);

  /// Easier way to access `MediaQuery.of(context)`.
  MediaQueryData get mq => MediaQuery.of(this);

  /// Easier way to show a [LoadingDialog].
  void showLoadingDialog() => const LoadingDialog().showLoadingDialog(this);

  /// Easier way to show a [SnackBar].
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
      SnackBar snackBar) {
    return ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }

  /// Easier way to access `Theme.of(context)`.
  ThemeData get t => Theme.of(this);

  /// Easier way to access `Theme.of(context).colorScheme`.
  ColorScheme get colorScheme => t.colorScheme;

  /// Easier way to access `Theme.of(context).textTheme`.
  TextTheme get textTheme => t.textTheme;

  /// Whether the current theme brightness is [Brightness.dark].
  bool get isDarkMode => t.brightness == Brightness.dark;

  /// Whether the current theme brightness is [Brightness.light].
  bool get isLightMode => !isDarkMode;
}
