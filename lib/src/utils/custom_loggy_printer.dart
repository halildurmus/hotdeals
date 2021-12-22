// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:loggy/loggy.dart';

/// An implementation of [LoggyPrinter].
///
/// Output looks like this:
/// ```
/// ┌──────────────────────────
/// │ Error info
/// ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
/// │ Method stack history
/// ├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
/// │ Log message
/// └──────────────────────────
/// ```
class CustomLoggyPrinter extends LoggyPrinter {
  CustomLoggyPrinter({
    this.stackTraceBeginIndex = 0,
    this.errorMethodCount = 8,
    this.lineLength = 120,
    this.colors = true,
    this.printEmojis = true,
    this.printTime = false,
    this.excludeBox = const {},
    this.noBoxingByDefault = false,
  }) : super() {
    _startTime ??= DateTime.now();

    var doubleDividerLine = StringBuffer();
    var singleDividerLine = StringBuffer();
    for (var i = 0; i < lineLength - 1; i++) {
      doubleDividerLine.write(_doubleDivider);
      singleDividerLine.write(_singleDivider);
    }

    _topBorder = '$_topLeftCorner$doubleDividerLine';
    _middleBorder = '$_middleCorner$singleDividerLine';
    _bottomBorder = '$_bottomLeftCorner$doubleDividerLine';

    // Translate excludeBox map (constant if default) to includeBox map with all
    // LogLevel enum possibilities
    includeBox = {};
    for (final l in LogLevel.values) {
      includeBox[l] = !noBoxingByDefault;
    }
    excludeBox.forEach((k, v) => includeBox[k] = !v);
  }

  static const _topLeftCorner = '┌';
  static const _bottomLeftCorner = '└';
  static const _middleCorner = '├';
  static const _verticalLine = '│';
  static const _doubleDivider = '─';
  static const _singleDivider = '┄';

  static final _levelColors = {
    LogLevel.debug: AnsiColor(),
    LogLevel.info: AnsiColor(foregroundColor: 12),
    LogLevel.warning: AnsiColor(foregroundColor: 208),
    LogLevel.error: AnsiColor(foregroundColor: 196),
  };

  static final _levelEmojis = {
    LogLevel.debug: '🐛 ',
    LogLevel.info: '💡 ',
    LogLevel.warning: '⚠️',
    LogLevel.error: '⛔ ',
  };

  /// Matches a stacktrace line as generated on Android/iOS devices.
  /// For example:
  /// #1      Logger.log (package:logger/src/logger.dart:115:29)
  static final _deviceStackTraceRegex =
      RegExp(r'#[0-9]+[\s]+(.+) \(([^\s]+)\)');

  /// Matches a stacktrace line as generated by Flutter web.
  /// For example:
  /// packages/logger/src/printers/custom_loggy_printer.dart 91:37
  static final _webStackTraceRegex =
      RegExp(r'^((packages|dart-sdk)\/[^\s]+\/)');

  /// Matches a stacktrace line as generated by browser Dart.
  /// For example:
  /// dart:sdk_internal
  /// package:logger/src/logger.dart
  static final _browserStackTraceRegex =
      RegExp(r'^(?:package:)?(dart:[^\s]+|[^\s]+)');

  static DateTime? _startTime;

  /// The index which to begin the stack trace at
  ///
  /// This can be useful if, for instance, Logger is wrapped in another class
  /// and you wish to remove these wrapped calls from stack trace
  final int stackTraceBeginIndex;
  final int errorMethodCount;
  final int lineLength;
  final bool colors;
  final bool printEmojis;
  final bool printTime;

  /// To prevent ascii 'boxing' of any log [LogLevel] include the log level in
  /// map for excludeBox, for example to prevent boxing of [LogLevel.info] use
  /// excludeBox:{LogLevel.info:true}
  final Map<LogLevel, bool> excludeBox;

  /// To make the default for every log level to prevent boxing entirely set
  /// [noBoxingByDefault] to true (boxing can still be turned on for some log
  /// levels by using something like excludeBox:{LogLevel.error:false})
  final bool noBoxingByDefault;

  late final Map<LogLevel, bool> includeBox;

  String _topBorder = '';
  String _middleBorder = '';
  String _bottomBorder = '';

  @override
  void onLog(LogRecord record) {
    var messageStr =
        '${record.loggerName} - ${_stringifyMessage(record.message)}';

    String? stackTraceStr;
    if (record.stackTrace != null && errorMethodCount > 0) {
      stackTraceStr = _formatStackTrace(record.stackTrace, errorMethodCount);
    }

    var errorStr = record.error?.toString();

    String? timeStr;
    if (printTime) {
      timeStr = _getTime();
    }

    final List<String> _logs = _formatLog(
      record.level,
      messageStr,
      timeStr,
      errorStr,
      stackTraceStr,
    );

    // Prints logs to the console.
    _logs.forEach(print);
  }

  String? _formatStackTrace(StackTrace? stackTrace, int methodCount) {
    var lines = stackTrace.toString().split('\n');
    if (stackTraceBeginIndex > 0 && stackTraceBeginIndex < lines.length - 1) {
      lines = lines.sublist(stackTraceBeginIndex);
    }

    var formatted = <String>[];
    var count = 0;
    for (final line in lines) {
      if (_discardDeviceStacktraceLine(line) ||
          _discardWebStacktraceLine(line) ||
          _discardBrowserStacktraceLine(line) ||
          line.isEmpty) {
        continue;
      }

      formatted.add('#$count   ${line.replaceFirst(RegExp(r'#\d+\s+'), '')}');
      if (++count == methodCount) {
        break;
      }
    }

    return formatted.isEmpty ? null : formatted.join('\n');
  }

  bool _discardDeviceStacktraceLine(String line) {
    var match = _deviceStackTraceRegex.matchAsPrefix(line);
    if (match == null) {
      return false;
    }

    return match.group(2)!.startsWith('package:logger');
  }

  bool _discardWebStacktraceLine(String line) {
    var match = _webStackTraceRegex.matchAsPrefix(line);
    if (match == null) {
      return false;
    }

    return match.group(1)!.startsWith('packages/logger') ||
        match.group(1)!.startsWith('dart-sdk/lib');
  }

  bool _discardBrowserStacktraceLine(String line) {
    var match = _browserStackTraceRegex.matchAsPrefix(line);
    if (match == null) {
      return false;
    }

    return match.group(1)!.startsWith('package:logger') ||
        match.group(1)!.startsWith('dart:');
  }

  String _getTime() {
    String _threeDigits(int n) {
      if (n >= 100) return '$n';
      if (n >= 10) return '0$n';

      return '00$n';
    }

    String _twoDigits(int n) => (n >= 10) ? '$n' : '0$n';

    var now = DateTime.now();
    var h = _twoDigits(now.hour);
    var min = _twoDigits(now.minute);
    var sec = _twoDigits(now.second);
    var ms = _threeDigits(now.millisecond);
    var timeSinceStart = now.difference(_startTime!).toString();

    return '$h:$min:$sec.$ms (+$timeSinceStart)';
  }

  // Handles any object that is causing JsonEncoder() problems
  Object _toEncodableFallback(dynamic object) => object.toString();

  String _stringifyMessage(dynamic message) {
    final finalMessage = message is Function ? message() : message;
    if (finalMessage is Map || finalMessage is Iterable) {
      var encoder = JsonEncoder.withIndent('  ', _toEncodableFallback);
      return encoder.convert(finalMessage);
    }

    return finalMessage.toString();
  }

  AnsiColor _getLevelColor(LogLevel level) {
    return colors ? _levelColors[level]! : AnsiColor();
  }

  AnsiColor _getErrorColor(LogLevel level) {
    return colors
        ? AnsiColor(
            backgroundColor: _levelColors[LogLevel.error]!.foregroundColor)
        : AnsiColor();
  }

  String _getEmoji(LogLevel level) => printEmojis ? _levelEmojis[level]! : '';

  List<String> _formatLog(
    LogLevel level,
    String message,
    String? time,
    String? error,
    String? stacktrace,
  ) {
    // This code is non trivial and a type annotation here helps understanding.
    // ignore: omit_local_variable_types
    List<String> buffer = [];
    var verticalLineAtLevel = (includeBox[level]!) ? ('$_verticalLine ') : '';
    var color = _getLevelColor(level);
    if (includeBox[level]!) buffer.add(color(_topBorder));

    if (error != null) {
      var errorColor = _getErrorColor(level);
      for (final line in error.split('\n')) {
        buffer.add(
          color(verticalLineAtLevel) +
              errorColor.resetForeground +
              errorColor(line) +
              errorColor.resetBackground,
        );
      }
      if (includeBox[level]!) buffer.add(color(_middleBorder));
    }

    if (stacktrace != null) {
      for (final line in stacktrace.split('\n')) {
        buffer.add(color('$verticalLineAtLevel$line'));
      }
      if (includeBox[level]!) buffer.add(color(_middleBorder));
    }

    if (time != null) {
      buffer.add(color('$verticalLineAtLevel$time'));
      if (includeBox[level]!) buffer.add(color(_middleBorder));
    }

    var emoji = _getEmoji(level);
    for (final line in message.split('\n')) {
      buffer.add(color('$verticalLineAtLevel$emoji$line'));
    }
    if (includeBox[level]!) buffer.add(color(_bottomBorder));

    return buffer;
  }
}
