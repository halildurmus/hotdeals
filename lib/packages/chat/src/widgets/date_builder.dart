part of dash_chat;

class DateBuilder extends StatelessWidget {
  const DateBuilder({
    Key? key,
    required this.date,
    this.customDateBuilder,
    this.dateFormat,
  }) : super(key: key);

  final DateTime date;
  final Widget Function(String)? customDateBuilder;
  final DateFormat? dateFormat;

  /// Returns the difference (in full days) between the provided date and today.
  int calculateDifference(DateTime date) {
    final DateTime now = DateTime.now();
    return DateTime(date.year, date.month, date.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    String getDateText() {
      if (calculateDifference(date) == -1) {
        return AppLocalizations.of(context)!.yesterday;
      } else if (calculateDifference(date) == 0) {
        return AppLocalizations.of(context)!.today;
      } else {
        return dateFormat != null
            ? dateFormat!.format(date)
            : DateFormat(
                    'MMM d, yyy', Localizations.localeOf(context).languageCode)
                .format(date);
      }
    }

    if (customDateBuilder != null) {
      return customDateBuilder!(getDateText());
    } else {
      return Container(
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.light
              ? theme.primaryColor
              : theme.backgroundColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.only(
          bottom: 5.0,
          top: 5.0,
          left: 10.0,
          right: 10.0,
        ),
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Text(
          getDateText().toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      );
    }
  }
}
