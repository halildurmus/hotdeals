import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:loggy/loggy.dart' show LogLevel, LogRecord, LoggyPrinter;

class CrashlyticsPrinter extends LoggyPrinter {
  const CrashlyticsPrinter() : super();

  @override
  void onLog(LogRecord record) {
    if (record.level == LogLevel.error) {
      // Pass all errors to Crashlytics.
      FirebaseCrashlytics.instance.recordError(record.error, record.stackTrace);
    }
  }
}
