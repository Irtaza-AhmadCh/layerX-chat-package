import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';

class CustomPrinter extends LogPrinter {
  final PrettyPrinter _prettyPrinter;

  CustomPrinter()
      : _prettyPrinter = PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    excludeBox: const {},
    noBoxingByDefault: false,
    excludePaths: const [],
    levelColors: {
      Level.trace: AnsiColor.fg(93),     // Electric Purple 💜
      Level.debug: AnsiColor.fg(200),     // Neon Cyan 🌀
      Level.info: AnsiColor.fg(200),      // Bright Cyan 🩵 (replaced green)
      Level.warning: AnsiColor.fg(214),  // Vivid Orange ⚠️
      Level.error: AnsiColor.fg(197),    // Bright Crimson ⛔
      Level.wtf: AnsiColor.fg(200),      // Hot Pink 🔥
    },
    levelEmojis: {
      Level.trace: '💜 ',
      Level.debug: '🌀 ',
      Level.info: '🩵 ',                // Updated emoji to match
      Level.warning: '⚡ ',
      Level.error: '⛔ ',
      Level.wtf: '🔥 ',
    },
  );

  @override
  List<String> log(LogEvent event) {
    var output = _prettyPrinter.log(event);
    var dateTime = DateTime.now();
    var formattedTime = DateFormat('dd-MM-yyyy hh:mm:ss a').format(dateTime);
    var levelName = event.level.name.toUpperCase();
    return output.map((line) => '[📅 $formattedTime] [$levelName] $line').toList();
  }
}
class LoggerService {
  LoggerService._();

  static final Logger _logger = Logger(
    filter: ProductionFilter(),
    printer: CustomPrinter(),
    level: Level.trace, // Change to Level.warning in production
  );

  static Logger get instance => _logger;

  static void d(dynamic message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void i(dynamic message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void w(dynamic message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void e(dynamic message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void v(dynamic message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.v(message, error: error, stackTrace: stackTrace);
  }

  static void wtf(dynamic message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.wtf(message, error: error, stackTrace: stackTrace);
  }
}
