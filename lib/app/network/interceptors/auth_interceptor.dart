import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import '../../routes/app_routes.dart';
import '../../services/storage_service.dart';
import '../../utils/app_logger.dart';
import '../api_endpoints.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = StorageService.to.authToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _tryRefreshToken(err.requestOptions);
      if (refreshed != null) {
        handler.resolve(refreshed);
        return;
      }
      _forceLogout();
    }
    handler.next(err);
  }

  Future<Response?> _tryRefreshToken(RequestOptions original) async {
    final refreshToken = StorageService.to.refreshToken;
    if (refreshToken == null) return null;

    try {
      final dio = Dio(BaseOptions(
        baseUrl: original.baseUrl,
        connectTimeout: const Duration(seconds: 10),
      ));
      final response = await dio.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      final newToken = response.data['data']['access_token'] as String?;
      if (newToken == null) return null;

      StorageService.to.saveAuthToken(newToken);
      original.headers['Authorization'] = 'Bearer $newToken';

      return await dio.fetch(original);
    } catch (e) {
      AppLogger.e('Token refresh failed', e);
      return null;
    }
  }

  void _forceLogout() {
    StorageService.to.clearAuth();
    Get.offAllNamed(AppRoutes.login);
  }
}
