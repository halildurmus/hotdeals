import 'package:timeago/timeago.dart';

/// Turkish short messages for [timeago].
class TrShortMessages implements LookupMessages {
  @override
  String prefixAgo() => '';

  @override
  String prefixFromNow() => '';

  @override
  String suffixAgo() => '';

  @override
  String suffixFromNow() => '';

  @override
  String lessThanOneMinute(int seconds) => 'şimdi';

  @override
  String aboutAMinute(int minutes) => '1 dk';

  @override
  String minutes(int minutes) => '$minutes dk';

  @override
  String aboutAnHour(int minutes) => '~1 sa';

  @override
  String hours(int hours) => '$hours sa';

  @override
  String aDay(int hours) => '~1 g';

  @override
  String days(int days) => '$days g';

  @override
  String aboutAMonth(int days) => '~1 ay';

  @override
  String months(int months) => '$months ay';

  @override
  String aboutAYear(int year) => '~1 yıl';

  @override
  String years(int years) => '$years yıl';

  @override
  String wordSeparator() => ' ';
}
