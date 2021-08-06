import 'dart:ui' show Locale;

import 'package:flutter/material.dart';

const Locale en_US = Locale('en', 'US');
const Locale tr_TR = Locale('tr', 'TR');
const Map<String, Locale> _locales = <String, Locale>{
  'en-US': en_US,
  'tr-TR': tr_TR
};

/// Returns the given [localeString] as [Locale] object.
///
/// e.g. If the given [localeString] is `en-US` then `Locale('en', 'US')` will
/// be returned.
Locale getLocale(String localeString) => _locales[localeString] ?? en_US;

/// Returns the supported locales.
///
/// At the moment, supported locales are `en_US` and `tr_TR`.
const List<Locale> supportedLocales = <Locale>[
  en_US,
  tr_TR,
];
