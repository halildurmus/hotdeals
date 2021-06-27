import 'package:flutter/material.dart';

class Constants {
  static Locale english = const Locale('en', 'US');
  static Locale turkish = const Locale('tr', 'TR');

  static final List<Locale> supportedLocales = <Locale>[
    english,
    turkish,
  ];
}
