import 'package:dio/dio.dart';
import '../../utils/app_logger.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;

  RetryInterceptor({required this.dio, this.maxRetries = 3});

  static const _retryKey = '_retry_count';

  static const _retryableTypes = {
    DioExceptionType.connectionTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.connectionError,
  };

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (!_retryableTypes.contains(err.type)) {
      handler.next(err);
      return;
    }

    final retryCount = (err.requestOptions.extra[_retryKey] as int?) ?? 0;

    if (retryCount >= maxRetries) {
      AppLogger.w('Max retries ($maxRetries) reached for ${err.requestOptions.path}');
      handler.next(err);
      return;
    }

    err.requestOptions.extra[_retryKey] = retryCount + 1;

    final delay = Duration(seconds: retryCount + 1);
    AppLogger.w('Retry ${retryCount + 1}/$maxRetries for ${err.requestOptions.path} in ${delay.inSeconds}s');

    await Future.delayed(delay);

    try {
      final response = await dio.fetch(err.requestOptions);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
