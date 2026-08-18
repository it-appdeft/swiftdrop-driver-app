import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../services/connectivity_service.dart';
import '../utils/app_logger.dart';
import '../utils/app_utils.dart';

abstract class BaseController extends GetxController {
  // ─── State ─────────────────────────────────────────────────────────────────

  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;

  // ─── Connectivity ──────────────────────────────────────────────────────────

  ConnectivityService get connectivity => ConnectivityService.to;
  bool get isConnected => connectivity.isConnected.value;

  // ─── Loading helpers ───────────────────────────────────────────────────────

  void showLoading() {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
  }

  void hideLoading() => isLoading.value = false;

  void showLoadingMore() => isLoadingMore.value = true;
  void hideLoadingMore() => isLoadingMore.value = false;

  void setError(String message) {
    errorMessage.value = message;
    hasError.value = true;
    isLoading.value = false;
  }

  void clearError() {
    errorMessage.value = '';
    hasError.value = false;
  }

  // ─── Network guard ─────────────────────────────────────────────────────────

  bool checkConnectivity({bool showMessage = true}) {
    if (!isConnected) {
      if (showMessage) {
        AppUtils.showWarning('No internet connection. Please check your network.');
      }
      return false;
    }
    return true;
  }

  // ─── Async operation wrapper ───────────────────────────────────────────────

  Future<T?> runAsync<T>(
    Future<T> Function() operation, {
    bool showLoadingIndicator = true,
    bool handleErrors = true,
    String? errorPrefix,
  }) async {
    if (showLoadingIndicator) showLoading();
    try {
      final result = await operation();
      return result;
    } on DioException catch (e) {
      if (handleErrors) {
        final message = _parseDioError(e);
        AppLogger.e('DioException in $runtimeType', e);
        if (showLoadingIndicator) setError(message);
        AppUtils.showError(message);
      }
      return null;
    } catch (e, s) {
      if (handleErrors) {
        AppLogger.e('Error in $runtimeType', e, s);
        const message = 'Something went wrong. Please try again.';
        if (showLoadingIndicator) setError(message);
        AppUtils.showError(message);
      }
      return null;
    } finally {
      if (showLoadingIndicator && !isClosed) hideLoading();
    }
  }

  // ─── Error parsing ─────────────────────────────────────────────────────────

  String _parseDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Connection timed out. Please try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      case DioExceptionType.badResponse:
        return _parseHttpError(e.response?.statusCode, e.response?.data);
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  String _parseHttpError(int? statusCode, dynamic data) {
    final serverMessage = data is Map ? data['message'] as String? : null;
    if (serverMessage != null) return serverMessage;

    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Session expired. Please login again.';
      case 403:
        return 'Access denied.';
      case 404:
        return 'Resource not found.';
      case 422:
        return 'Validation failed. Please check your input.';
      case 429:
        return 'Too many requests. Please wait a moment.';
      case 500:
      case 502:
      case 503:
        return 'Server error. Please try again later.';
      default:
        return 'Something went wrong (${statusCode ?? 'unknown'}).';
    }
  }

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    AppLogger.d('$runtimeType initialized');
  }

  @override
  void onClose() {
    AppLogger.d('$runtimeType closed');
    super.onClose();
  }
}
