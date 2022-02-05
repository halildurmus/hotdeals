import 'package:flex_color_scheme/flex_color_scheme.dart' show FlexScheme;
import 'package:flutter/material.dart';

const appTitle = 'hotdeals';

// Assets
const assetEnglish = 'assets/icons/en.svg';
const assetTurkish = 'assets/icons/tr.svg';

// Locales
const localeEnglish = Locale('en');
const localeTurkish = Locale('tr');

final localeAssets = <Locale, String>{
  localeEnglish: assetEnglish,
  localeTurkish: assetTurkish,
};

// The FlexScheme used throughout the app.
const usedFlexScheme = FlexScheme.deepBlue;

// ZoomPageTransitionsBuilder will make animations on Android devices
// match the default animations seen on Android 10 and above.
const pageTransitionsTheme = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: ZoomPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
  },
);

const errors = <String, String>{
  'aborted-by-user': 'Sign in aborted by user',
  'missing-google-auth-token': 'Missing Google Auth Token',
  'mongo-create-user-failed': 'An error occurred. Please try again later.',
  'sign-in-failed': 'Sign in failed',
  'sign-in-operation-in-progress':
      'You have a previous login operation in progress'
};
