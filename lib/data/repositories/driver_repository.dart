import '../../app/network/api_endpoints.dart';
import '../../app/network/base_api_service.dart';
import '../models/api_response.dart';
import '../models/driver_dashboard_model.dart';
import '../models/user_model.dart';
import '../models/vehicle_type_model.dart';

class DriverRepository extends BaseApiService {
  /// Fetch driver dashboard data
  Future<ApiResponse<DriverDashboardModel>> getDashboard() async {
    final response = await getRequest(ApiEndpoints.driverDashboard);
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => DriverDashboardModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Toggle online / offline status
  /// availability: "online" | "offline"
  Future<ApiResponse<dynamic>> toggleAvailability(String availability) async {
    final response = await postRequest(
      ApiEndpoints.driverAvailability,
      data: {
        'availability': availability,
      },
      forceMultipart: true,
    );
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data,
    );
  }

  /// Update driver location
  Future<ApiResponse<Map<String, dynamic>>> updateLocation({
    required double lat,
    required double lng,
  }) async {
    final response = await postRequest(
      ApiEndpoints.updateLocation,
      data: {
        'lat': lat.toString(),
        'lng': lng.toString(),
      },
      forceMultipart: true,
    );
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => (data is Map) ? data.cast<String, dynamic>() : {},
    );
  }

  /// Fetch vehicle types from GET /api/vehicle-types
  Future<ApiResponse<List<VehicleTypeModel>>> getVehicleTypes() async {
    final response = await getRequest(ApiEndpoints.vehicleTypes);
    final json = response.data as Map<String, dynamic>;
    final list = (json['data'] as List<dynamic>?) ?? [];
    return ApiResponse<List<VehicleTypeModel>>(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? '',
      data: list
          .map((e) => VehicleTypeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Fetch driver profile from GET /api/driver/profile
  Future<ApiResponse<UserModel>> getProfile() async {
    final response = await getRequest(ApiEndpoints.profile);
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => UserModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Complete or update driver profile setup
  Future<ApiResponse<Map<String, dynamic>>> completeProfileSetup(
      Map<String, dynamic> data) async {
    final response = await postRequest(
      ApiEndpoints.completeSetup,
      data: data,
      forceMultipart: true,
    );
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (d) => (d as Map?)?.cast<String, dynamic>() ?? {},
    );
  }
}
