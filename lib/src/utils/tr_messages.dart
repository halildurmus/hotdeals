import 'package:timeago/timeago.dart';

/// Turkish messages for [timeago].
class TrMessages implements LookupMessages {
  @override
  String prefixAgo() => '';

  @override
  String prefixFromNow() => '';

  @override
  String suffixAgo() => 'önce';

  @override
  String suffixFromNow() => 'kaldı';

  @override
  String lessThanOneMinute(int seconds) => 'biraz';

  @override
  String aboutAMinute(int minutes) => 'bir dakika';

  @override
  String minutes(int minutes) => '$minutes dakika';

  @override
  String aboutAnHour(int minutes) => 'bir saat';

  @override
  String hours(int hours) => '$hours saat';

  @override
  String aDay(int hours) => 'bir gün';

  @override
  String days(int days) => '$days gün';

  @override
  String aboutAMonth(int days) => 'bir ay';

  @override
  String months(int months) => '$months ay';

  @override
  String aboutAYear(int year) => 'bir yıl';

  @override
  String years(int years) => '$years yıl';

  @override
  String wordSeparator() => ' ';
}

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
