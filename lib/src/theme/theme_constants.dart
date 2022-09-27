import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

/// The FlexScheme used throughout the app.
const currentFlexScheme = FlexScheme.deepBlue;

/// ZoomPageTransitionsBuilder will make animations on Android devices
/// match the default animations seen on Android 10 and above.
const pageTransitionsTheme = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: ZoomPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
  },
);

final lightAppTheme = FlexColorScheme.light(
  scheme: currentFlexScheme,
  visualDensity: FlexColorScheme.comfortablePlatformDensity,
).toTheme.copyWith(pageTransitionsTheme: pageTransitionsTheme);

final darkAppTheme = FlexColorScheme.dark(
  scheme: currentFlexScheme,
  visualDensity: FlexColorScheme.comfortablePlatformDensity,
).toTheme.copyWith(pageTransitionsTheme: pageTransitionsTheme);
