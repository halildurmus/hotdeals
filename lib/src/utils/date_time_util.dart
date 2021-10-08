import 'package:get_it/get_it.dart';
import 'package:timeago/timeago.dart';

import '../settings/settings.controller.dart';

/// A static class that contains useful utility functions for formatting
/// `DateTime` with [timeago].
class DateTimeUtil {
  static final String _languageCode =
      GetIt.I.get<SettingsController>().locale.languageCode;

  /// Formats the provided [dateTime] to a fuzzy time like 'a moment ago' or
  /// much shorter 'now' depending on the [useShortMessages] parameter.
  static String formatDateTime(
    DateTime dateTime, {
    bool useShortMessages = true,
  }) =>
      format(
        dateTime,
        locale: useShortMessages ? _languageCode + '_short' : _languageCode,
      );
}
