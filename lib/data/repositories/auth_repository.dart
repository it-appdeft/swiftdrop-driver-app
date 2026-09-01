import 'dart:io';

import '../../app/constants/api_params.dart';
import '../../app/constants/auth_enums.dart';
import '../../app/network/api_endpoints.dart';
import '../../app/network/base_api_service.dart';
import '../models/api_response.dart';
import '../models/deletion_reason_model.dart';
import '../models/legal_content_model.dart';
import '../models/otp_response_model.dart';
import '../models/register_response_model.dart';
import '../models/user_model.dart';
import '../models/vehicle_type_model.dart';
import '../models/verify_otp_response_model.dart';

class AuthRepository extends BaseApiService {
  
  // ─── Send OTP ─────────────────────────────────────────────────────────────
  Future<ApiResponse<OtpResponseModel>> sendOtp({
    String? phone,
    String? countryCode,
    String? countryIso,
    String? email,
    required AuthOtpType type,
    required AuthChannel channel,
    UserType userType = UserType.driver,
  }) async {
    final Map<String, dynamic> data = {
      ApiParams.phoneNumber: phone ?? '',
      ApiParams.countryCode: countryCode ?? '',
      if (countryIso != null) ApiParams.countryIso: countryIso,
      ApiParams.email: email ?? '',
      ApiParams.type: type.value,
      ApiParams.channel: channel.value,
      ApiParams.userType: userType.value,
    };

    final response = await postRequest(
      ApiEndpoints.sendOtp,
      data: data,
    );
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => OtpResponseModel.fromJson(data as Map<String, dynamic>),
    );
  }

  // ─── Verify OTP ───────────────────────────────────────────────────────────
  Future<ApiResponse<VerifyOtpResponseModel>> verifyOtp({
    String? phone,
    String? countryCode,
    String? countryIso,
    String? email,
    required String otp,
    required AuthOtpType type,
    required AuthChannel channel,
    UserType userType = UserType.driver,
    String? fcmToken,
  }) async {
    final Map<String, dynamic> data = {
      ApiParams.phoneNumber: phone ?? '',
      ApiParams.countryCode: countryCode ?? '',
      if (countryIso != null) ApiParams.countryIso: countryIso,
      ApiParams.email: email ?? '',
      ApiParams.code: otp,
      ApiParams.type: type.value,
      ApiParams.channel: channel.value,
      ApiParams.userType: userType.value,
    };

    if (fcmToken != null) data[ApiParams.fcmToken] = fcmToken;

    final response = await postRequest(
      ApiEndpoints.verifyOtp,
      data: data,
    );
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => VerifyOtpResponseModel.fromJson(data as Map<String, dynamic>),
    );
  }

  // ─── Vehicle Types ────────────────────────────────────────────────────────
  Future<ApiResponse<List<VehicleTypeModel>>> getVehicleTypes() async {
    final response = await getRequest(ApiEndpoints.vehicleTypes);
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => (data as List)
          .map((e) => VehicleTypeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // ─── Register Driver ──────────────────────────────────────────────────────
  Future<ApiResponse<RegisterResponseModel>> registerDriver({
    required String name,
    required String email,
    required String phone,
    required String countryCode,
    required String countryIso,
    File? profileImage,
  }) async {
    final response = await postRequest(
      ApiEndpoints.registerDriver,
      data: {
        ApiParams.name: name,
        ApiParams.email: email,
        ApiParams.phoneNumber: phone,
        ApiParams.countryCode: countryCode,
        ApiParams.countryIso: countryIso,
        if (profileImage != null) ApiParams.profileImage: profileImage,
      },
    );
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => RegisterResponseModel.fromJson(data as Map<String, dynamic>),
    );
  }

  // ─── Profile Setup (Multi-step) ───────────────────────────────────────────
  // Same endpoint for all three register screens; `step` selects which one.
  //
  // Step 1 — BankDetailsStep:
  //   account_holder_name, account_number, sort_code, bank_name
  //
  // Step 2 — VehicleDetailsStep:
  //   vehicle_type, registration_number, make, model, color,
  //   year_of_manufacture, insurance_type, insurance_expiry, mot_expiry
  //
  // Step 3 — DocumentUploadStep (multipart — File values):
  //   driving_licence_front, driving_licence_back, id_proof, insurance_certificate
  Future<ApiResponse<Map<String, dynamic>>> setupProfile({
    required int step,
    required Map<String, dynamic> data,
  }) async {
    final response = await postRequest(
      ApiEndpoints.profileSetup,
      data: {
        ApiParams.step: step,
        ...data,
      },
      forceMultipart: true,
    );
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (d) => (d as Map).cast<String, dynamic>(),
    );
  }

  // ─── Get Profile ──────────────────────────────────────────────────────────
  Future<ApiResponse<UserModel>> getProfile() async {
    final response = await getRequest(ApiEndpoints.profile);
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => UserModel.fromJson(data as Map<String, dynamic>),
    );
  }

  // ─── Register FCM Token ───────────────────────────────────────────────────
  Future<ApiResponse<Map<String, dynamic>>> registerFcmToken(
      String token) async {
    final response = await postRequest(
      ApiEndpoints.registerFcmToken,
      data: {ApiParams.fcmToken: token},
    );
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data as Map<String, dynamic>,
    );
  }

  // ─── Update Profile ───────────────────────────────────────────────────────
  Future<ApiResponse<Map<String, dynamic>>> updateProfile({
    required String name,
    File? profilePhoto,
  }) async {
    final response = await postRequest(
      ApiEndpoints.updateProfile,
      data: {
        ApiParams.method: 'PUT',
        ApiParams.name: name,
        if (profilePhoto != null) ApiParams.profileImage: profilePhoto,
      },
    );
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (d) => (d as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  // ─── Delete Account — Step 1: trigger OTP ────────────────────────────────
  Future<ApiResponse<Map<String, dynamic>>> deleteAccountInitiate() async {
    final response = await postRequest(ApiEndpoints.deleteAccountInitiate);
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (d) => (d as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  // ─── Delete Account — Step 2: confirm with OTP ───────────────────────────
  Future<ApiResponse<Map<String, dynamic>>> deleteAccount(String code) async {
    final response = await postRequest(
      ApiEndpoints.profile,
      data: {
        ApiParams.method: 'DELETE',
        ApiParams.code: code,
      },
    );
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (d) => (d as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  // ─── Legal Content ────────────────────────────────────────────────────────
  Future<ApiResponse<LegalContentModel>> getTermsAndConditions() async {
    final response = await getRequest(ApiEndpoints.termsAndConditions);
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => LegalContentModel.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<LegalContentModel>> getPrivacyPolicy() async {
    final response = await getRequest(ApiEndpoints.privacyPolicy);
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => LegalContentModel.fromJson(data as Map<String, dynamic>),
    );
  }

  // ─── Deletion Reasons ─────────────────────────────────────────────────────
  Future<ApiResponse<List<DeletionReasonModel>>> getDeletionReasons() async {
    final response = await getRequest(ApiEndpoints.deletionReasons);
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => (data as List<dynamic>)
          .map((e) => DeletionReasonModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // ─── Support Ticket ───────────────────────────────────────────────────────
  Future<ApiResponse<Map<String, dynamic>>> createSupportTicket({
    required String subject,
    required String description,
    String? orderReference,
  }) async {
    final response = await postRequest(
      ApiEndpoints.createTicket,
      data: {
        'subject': subject,
        'description': description,
        if (orderReference != null && orderReference.isNotEmpty)
          'order_reference': orderReference,
      },
      forceMultipart: true,
    );
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (d) => (d as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  // ─── Update FCM Token ─────────────────────────────────────────────────────
  Future<ApiResponse<void>> updateFcmToken(String fcmToken) async {
    try {
      final response = await postRequest(
        ApiEndpoints.updateFcmToken,
        data: {'fcm_token': fcmToken},
        forceMultipart: true,
      );
      final json = response.data as Map<String, dynamic>;
      return ApiResponse<void>(
        success: json['success'] as bool? ?? true,
        message: json['message'] as String? ?? 'FCM token updated successfully.',
      );
    } catch (e) {
      return ApiResponse<void>(success: false, message: e.toString());
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await postRequest(ApiEndpoints.logout);
    } catch (_) {}
  }
}
