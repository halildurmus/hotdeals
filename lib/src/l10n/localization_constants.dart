import 'dart:ui' show Locale;

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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

const localizationDelegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

const supportedLocales = AppLocalizations.supportedLocales;
