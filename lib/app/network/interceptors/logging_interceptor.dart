import 'package:dio/dio.dart';
import '../../utils/app_logger.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.api(
      options.method,
      options.path,
      body: options.data,
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.api(
      '${response.requestOptions.method} ← ${response.statusCode}',
      response.requestOptions.path,
      response: response.data,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.e(
      '[${err.requestOptions.method}] ${err.requestOptions.path} '
      '→ ${err.response?.statusCode ?? err.type.name}',
      err.message,
    );
    handler.next(err);
  }
}
