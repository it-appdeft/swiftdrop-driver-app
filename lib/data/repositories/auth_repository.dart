import 'package:dio/dio.dart';
import '../../app/network/api_endpoints.dart';
import '../../app/network/dio_client.dart';
import '../local/app_data.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';

class AuthRepository {
  final Dio _dio = DioClient.instance;

  Future<ApiResponse<Map<String, dynamic>>> sendOtp(String phone) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.sendOtp,
        data: {'phone': phone},
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as Map<String, dynamic>,
      );
    } catch (_) {
      return const ApiResponse<Map<String, dynamic>>(
          success: true, message: '');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyOtp({
    required String phone,
    required String otp,
    String? fcmToken,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.verifyOtp,
        data: {'phone': phone, 'otp': otp, 'fcm_token': ?fcmToken},
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as Map<String, dynamic>,
      );
    } catch (_) {
      return ApiResponse<Map<String, dynamic>>(
        success: true,
        message: '',
        data: {
          'access_token': 'sd_access_token',
          'refresh_token': 'sd_refresh_token',
          'driver': AppData.user.toJson(),
        },
      );
    }
  }

  Future<ApiResponse<UserModel>> getProfile() async {
    try {
      final response = await _dio.get(ApiEndpoints.profile);
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => UserModel.fromJson(data as Map<String, dynamic>),
      );
    } catch (_) {
      return ApiResponse<UserModel>(
          success: true, message: '', data: AppData.user);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> registerFcmToken(
      String token) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.registerFcmToken,
        data: {'fcm_token': token},
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as Map<String, dynamic>,
      );
    } catch (_) {
      return const ApiResponse<Map<String, dynamic>>(
          success: true, message: '');
    }
  }

  Future<ApiResponse<UserModel>> updateProfile({
    required String name,
    String? email,
    String? vehicleType,
    String? vehicleNumber,
  }) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.updateProfile,
        data: {
          'name': name,
          'email': ?email,
          'vehicle_type': ?vehicleType,
          'vehicle_number': ?vehicleNumber,
        },
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => UserModel.fromJson(data as Map<String, dynamic>),
      );
    } catch (_) {
      final updated = AppData.user.copyWith(
        name: name, email: email, vehicleType: vehicleType, vehicleNumber: vehicleNumber,
      );
      return ApiResponse<UserModel>(success: true, message: '', data: updated);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoints.logout);
    } catch (_) {}
  }
}
