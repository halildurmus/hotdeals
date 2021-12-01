import 'dart:ui' show Locale;

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
