import 'dart:ui' show Locale;

// Assets
const assetEnglish = 'assets/icons/en.svg';
const assetTurkish = 'assets/icons/tr.svg';

// Locales
const localeEnglish = Locale('en');
const localeTurkish = Locale('tr');

// Language images map
final languageImages = <Locale, String>{
  localeEnglish: assetEnglish,
  localeTurkish: assetTurkish,
};
