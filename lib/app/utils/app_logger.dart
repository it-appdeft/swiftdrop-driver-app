import 'package:logger/logger.dart';
import '../config/app_config.dart';

class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
    filter: _AppLogFilter(),
  );

  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.d(message, error: error, stackTrace: stackTrace);

  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.i(message, error: error, stackTrace: stackTrace);

  static void w(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.w(message, error: error, stackTrace: stackTrace);

  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);

  static void api(String method, String url, {dynamic body, dynamic response}) {
    if (!AppConfig.isDebug) return;
    _logger.i('[$method] $url\nBody: $body\nResponse: $response');
  }
}

class _AppLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) => AppConfig.isDebug;
}
