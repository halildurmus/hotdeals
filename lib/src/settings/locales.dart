import 'dart:ui' show Locale;

const Locale en_US = Locale('en', 'US');

const Locale tr_TR = Locale('tr', 'TR');

const Map<String, Locale> _locales = <String, Locale>{
  'en-US': en_US,
  'tr-TR': tr_TR
};

Locale getLocale(String locale) => _locales[locale] ?? en_US;

const List<Locale> supportedLocales = <Locale>[
  en_US,
  tr_TR,
];
