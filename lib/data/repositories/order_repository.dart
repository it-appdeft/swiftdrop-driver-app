import 'package:dio/dio.dart';
import '../../app/constants/app_constants.dart';
import '../../app/network/api_endpoints.dart';
import '../../app/network/dio_client.dart';
import '../local/app_data.dart';
import '../models/api_response.dart';
import '../models/order_model.dart';

class OrderRepository {
  final Dio _dio = DioClient.instance;

  Future<ApiResponse<List<OrderModel>>> getDeliveryRequests() async {
    try {
      final response = await _dio.get(ApiEndpoints.deliveryRequests);
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data as List<dynamic>)
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (_) {
      return ApiResponse<List<OrderModel>>(
          success: true, message: '', data: AppData.activeOrders);
    }
  }

  Future<ApiResponse<List<OrderModel>>> getActiveOrders() async {
    try {
      final response = await _dio.get(ApiEndpoints.activeOrders);
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data as List<dynamic>)
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (_) {
      return ApiResponse<List<OrderModel>>(
          success: true, message: '', data: AppData.activeOrders);
    }
  }

  Future<ApiResponse<List<OrderModel>>> getOrderHistory({
    int page = 1,
    int limit = AppConstants.paginationLimit,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.orderHistory,
        queryParameters: {'page': page, 'limit': limit},
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data as List<dynamic>)
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (_) {
      return ApiResponse<List<OrderModel>>(
          success: true, message: '', data: AppData.orderHistory);
    }
  }

  Future<ApiResponse<OrderModel>> getOrderDetail(String id) async {
    try {
      final response = await _dio.get(ApiEndpoints.orderDetail(id));
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => OrderModel.fromJson(data as Map<String, dynamic>),
      );
    } catch (_) {
      final all = [...AppData.activeOrders, ...AppData.orderHistory];
      final order = all.firstWhere(
        (o) => o.id == id,
        orElse: () => AppData.activeOrders.first,
      );
      return ApiResponse<OrderModel>(success: true, message: '', data: order);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> acceptOrder(String orderId) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.acceptOrder,
        data: {'order_id': orderId},
      );
      return ApiResponse.fromJson(
          response.data as Map<String, dynamic>, (data) => data as Map<String, dynamic>);
    } catch (_) {
      return const ApiResponse<Map<String, dynamic>>(success: true, message: '');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> rejectOrder(
    String orderId, {
    String? reason,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.rejectOrder,
        data: {'order_id': orderId, 'reason': reason},
      );
      return ApiResponse.fromJson(
          response.data as Map<String, dynamic>, (data) => data as Map<String, dynamic>);
    } catch (_) {
      return const ApiResponse<Map<String, dynamic>>(success: true, message: '');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> confirmPickup(String orderId) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.confirmPickup,
        data: {'order_id': orderId},
      );
      return ApiResponse.fromJson(
          response.data as Map<String, dynamic>, (data) => data as Map<String, dynamic>);
    } catch (_) {
      return const ApiResponse<Map<String, dynamic>>(success: true, message: '');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> confirmDelivery({
    required String orderId,
    String? proofImageUrl,
    String? signature,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.confirmDelivery,
        data: {'order_id': orderId, 'proof_image': proofImageUrl, 'signature': signature},
      );
      return ApiResponse.fromJson(
          response.data as Map<String, dynamic>, (data) => data as Map<String, dynamic>);
    } catch (_) {
      return const ApiResponse<Map<String, dynamic>>(success: true, message: '');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> updateOrderStatus({
    required String orderId,
    required String status,
    double? lat,
    double? lng,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.updateOrderStatus,
        data: {'order_id': orderId, 'status': status, 'lat': lat, 'lng': lng},
      );
      return ApiResponse.fromJson(
          response.data as Map<String, dynamic>, (data) => data as Map<String, dynamic>);
    } catch (_) {
      return const ApiResponse<Map<String, dynamic>>(success: true, message: '');
    }
  }
}
