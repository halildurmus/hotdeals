import 'package:loggy/loggy.dart' show LogRecord, LoggyPrinter;

class CrashlyticsPrinter extends LoggyPrinter {
  const CrashlyticsPrinter() : super();

  @override
  void onLog(LogRecord record) {}
}
