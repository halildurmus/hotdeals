import 'package:flutter/material.dart' show Locale;
import 'package:timeago/timeago.dart';

/// Formats the provided [dateTime] to a fuzzy time like `a moment ago` or
/// much shorter `now` depending on the [useShortMessages] parameter.
String formatDateTime(
  DateTime dateTime, {
  Locale locale = const Locale('en'),
  bool useShortMessages = true,
}) =>
    format(
      dateTime,
      locale: useShortMessages
          ? '${locale.languageCode}_short'
          : locale.languageCode,
    );
