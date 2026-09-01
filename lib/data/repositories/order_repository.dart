import 'package:dio/dio.dart';
import '../../app/constants/app_constants.dart';
import '../../app/network/api_endpoints.dart';
import '../../app/network/base_api_service.dart';
import '../models/api_response.dart';
import '../models/order_model.dart';

class OrderRepository extends BaseApiService {
  /// Fetch incoming delivery requests for driver (GET /api/driver/delivery-requests)
  Future<ApiResponse<List<OrderModel>>> getDeliveryRequests() async {
    try {
      final response = await getRequest(ApiEndpoints.deliveryRequests);
      final json = response.data as Map<String, dynamic>;
      final rawData = json['data'];
      List<OrderModel> list = [];
      if (rawData is List) {
        list = rawData
            .whereType<Map<String, dynamic>>()
            .map((e) => OrderModel.fromJson(e))
            .toList();
      }
      return ApiResponse<List<OrderModel>>(
        success: json['success'] as bool? ?? true,
        message: json['message'] as String? ?? '',
        data: list,
      );
    } catch (e) {
      return ApiResponse<List<OrderModel>>(
        success: false,
        message: e.toString(),
        data: [],
      );
    }
  }

  /// Respond to a delivery request (accept or reject)
  /// POST /api/driver/deliveries/{id}/respond?action=accept|reject
  Future<ApiResponse<Map<String, dynamic>>> respondDelivery(
    String deliveryId, {
    required String action, // 'accept' or 'reject'
    String? reason,
  }) async {
    try {
      final payload = <String, dynamic>{
        'action': action,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      };
      final response = await postRequest(
        ApiEndpoints.respondDelivery(deliveryId, action),
        data: payload,
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data is Map) ? data.cast<String, dynamic>() : {},
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>.error(e.toString());
    }
  }

  /// Accept a delivery request
  Future<ApiResponse<Map<String, dynamic>>> acceptOrder(String orderId) async {
    return await respondDelivery(orderId, action: 'accept');
  }

  /// Reject a delivery request
  Future<ApiResponse<Map<String, dynamic>>> rejectOrder(
    String orderId, {
    String? reason,
  }) async {
    return await respondDelivery(orderId, action: 'reject', reason: reason);
  }

  /// Fetch active orders assigned to the driver
  Future<ApiResponse<List<OrderModel>>> getActiveOrders() async {
    try {
      final response = await getRequest(ApiEndpoints.activeOrders);
      final json = response.data as Map<String, dynamic>;
      final rawData = json['data'];
      List<OrderModel> list = [];
      if (rawData is List) {
        list = rawData
            .whereType<Map<String, dynamic>>()
            .map((e) => OrderModel.fromJson(e))
            .toList();
      } else if (rawData is Map<String, dynamic> && rawData['orders'] is List) {
        list = (rawData['orders'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => OrderModel.fromJson(e))
            .toList();
      }
      return ApiResponse<List<OrderModel>>(
        success: json['success'] as bool? ?? true,
        message: json['message'] as String? ?? '',
        data: list,
      );
    } catch (e) {
      return ApiResponse<List<OrderModel>>(
        success: false,
        message: e.toString(),
        data: [],
      );
    }
  }

  /// Fetch order history
  Future<ApiResponse<List<OrderModel>>> getOrderHistory({
    int page = 1,
    int limit = AppConstants.paginationLimit,
  }) async {
    try {
      final response = await getRequest(
        ApiEndpoints.orderHistory,
        queryParameters: {'page': page, 'limit': limit},
      );
      final json = response.data as Map<String, dynamic>;
      final rawData = json['data'];
      List<OrderModel> list = [];
      if (rawData is List) {
        list = rawData
            .whereType<Map<String, dynamic>>()
            .map((e) => OrderModel.fromJson(e))
            .toList();
      } else if (rawData is Map<String, dynamic> && rawData['orders'] is List) {
        list = (rawData['orders'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => OrderModel.fromJson(e))
            .toList();
      }
      return ApiResponse<List<OrderModel>>(
        success: json['success'] as bool? ?? true,
        message: json['message'] as String? ?? '',
        data: list,
      );
    } catch (e) {
      return ApiResponse<List<OrderModel>>(
        success: false,
        message: e.toString(),
        data: [],
      );
    }
  }

  /// Get live delivery tracking & status
  /// GET /api/driver/deliveries/{id}/tracking
  Future<ApiResponse<OrderModel>> getDeliveryTracking(String deliveryId) async {
    try {
      final response = await getRequest(
        ApiEndpoints.deliveryTracking(deliveryId),
      );
      final json = response.data as Map<String, dynamic>;
      final rawData = json['data'];
      Map<String, dynamic> trackingMap = {};
      if (rawData is Map<String, dynamic>) {
        trackingMap = rawData;
      }
      return ApiResponse<OrderModel>(
        success: json['success'] as bool? ?? true,
        message: json['message'] as String? ?? '',
        data: OrderModel.fromJson(trackingMap),
      );
    } catch (e) {
      return ApiResponse<OrderModel>.error(e.toString());
    }
  }

  /// Get current active delivery
  /// GET /api/driver/deliveries/current-active
  Future<ApiResponse<OrderModel?>> getCurrentActiveDelivery() async {
    try {
      final response = await getRequest(ApiEndpoints.currentActiveDelivery);
      final json = response.data as Map<String, dynamic>;
      final rawData = json['data'];
      if (rawData is Map<String, dynamic> && rawData.isNotEmpty) {
        return ApiResponse<OrderModel?>(
          success: json['success'] as bool? ?? true,
          message: json['message'] as String? ?? '',
          data: OrderModel.fromJson(rawData),
        );
      }
      return ApiResponse<OrderModel?>(
        success: json['success'] as bool? ?? true,
        message: json['message'] as String? ?? '',
        data: null,
      );
    } catch (e) {
      return ApiResponse<OrderModel?>.error(e.toString());
    }
  }

  /// Update delivery status (reached_restaurant / picked_up / delivered)
  /// POST /api/driver/deliveries/{id}/status
  Future<ApiResponse<Map<String, dynamic>>> updateDeliveryStatus({
    required String deliveryId,
    required String status,
    String? otp,
  }) async {
    try {
      final mapData = <String, dynamic>{
        'status': status,
        if (otp != null && otp.isNotEmpty) 'otp': otp,
      };
      final response = await postRequest(
        ApiEndpoints.updateDeliveryStatus(deliveryId),
        data: FormData.fromMap(mapData),
      );
      final json = response.data as Map<String, dynamic>;
      return ApiResponse<Map<String, dynamic>>(
        success: json['success'] as bool? ?? true,
        message: json['message'] as String? ?? '',
        data: json['data'] is Map<String, dynamic>
            ? json['data'] as Map<String, dynamic>
            : {},
      );
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        try {
          final errData = e.response!.data;
          if (errData is Map<String, dynamic>) {
            final msg = errData['message']?.toString() ??
                (errData['errors'] is Map ? (errData['errors'] as Map).values.first?.toString() : null) ??
                'Invalid request';
            return ApiResponse<Map<String, dynamic>>.error(msg);
          }
        } catch (_) {}
      }
      return ApiResponse<Map<String, dynamic>>.error(e.toString());
    }
  }

  /// Fetch order detail or tracking
  Future<ApiResponse<OrderModel>> getOrderDetail(String id) async {
    try {
      // 1. Try delivery tracking endpoint (/driver/deliveries/$id/tracking)
      try {
        final trackingRes = await getDeliveryTracking(id);
        if (trackingRes.success && trackingRes.data != null) {
          return trackingRes;
        }
      } catch (_) {}

      // 2. Try deliveryDetail endpoint (/driver/deliveries/$id)
      try {
        final response = await getRequest(ApiEndpoints.deliveryDetail(id));
        final json = response.data as Map<String, dynamic>;
        final rawData = json['data'];
        Map<String, dynamic> orderMap = {};
        if (rawData is Map<String, dynamic>) {
          orderMap = rawData.containsKey('delivery') && rawData['delivery'] is Map<String, dynamic>
              ? rawData['delivery'] as Map<String, dynamic>
              : (rawData.containsKey('order') && rawData['order'] is Map<String, dynamic>
                  ? rawData['order'] as Map<String, dynamic>
                  : rawData);
        }
        if (orderMap.isNotEmpty) {
          return ApiResponse<OrderModel>(
            success: json['success'] as bool? ?? true,
            message: json['message'] as String? ?? '',
            data: OrderModel.fromJson(orderMap),
          );
        }
      } catch (_) {}

      // 3. Try /driver/orders/$id
      try {
        final response = await getRequest(ApiEndpoints.orderDetail(id));
        final json = response.data as Map<String, dynamic>;
        final rawData = json['data'];
        Map<String, dynamic> orderMap = {};
        if (rawData is Map<String, dynamic>) {
          orderMap = rawData.containsKey('order') && rawData['order'] is Map<String, dynamic>
              ? rawData['order'] as Map<String, dynamic>
              : rawData;
        }
        if (orderMap.isNotEmpty) {
          return ApiResponse<OrderModel>(
            success: json['success'] as bool? ?? true,
            message: json['message'] as String? ?? '',
            data: OrderModel.fromJson(orderMap),
          );
        }
      } catch (_) {}

      // 4. Try current-active delivery fallback
      final activeRes = await getCurrentActiveDelivery();
      if (activeRes.success && activeRes.data != null) {
        return ApiResponse<OrderModel>(
          success: true,
          message: activeRes.message,
          data: activeRes.data!,
        );
      }

      return ApiResponse<OrderModel>.error('Delivery/Order not found');
    } catch (e) {
      return ApiResponse<OrderModel>.error(e.toString());
    }
  }

  /// Confirm order pickup
  Future<ApiResponse<Map<String, dynamic>>> confirmPickup(String orderId) async {
    try {
      final response = await postRequest(
        ApiEndpoints.confirmPickup,
        data: {'order_id': orderId, 'delivery_id': orderId},
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data is Map) ? data.cast<String, dynamic>() : {},
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>.error(e.toString());
    }
  }

  /// Confirm delivery completion
  Future<ApiResponse<Map<String, dynamic>>> confirmDelivery({
    required String orderId,
    String? proofImageUrl,
    String? signature,
  }) async {
    try {
      final response = await postRequest(
        ApiEndpoints.confirmDelivery,
        data: {
          'order_id': orderId,
          'delivery_id': orderId,
          if (proofImageUrl != null) 'proof_image': proofImageUrl,
          if (signature != null) 'signature': signature,
        },
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data is Map) ? data.cast<String, dynamic>() : {},
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>.error(e.toString());
    }
  }

  /// Update order status
  Future<ApiResponse<Map<String, dynamic>>> updateOrderStatus({
    required String orderId,
    required String status,
    double? lat,
    double? lng,
  }) async {
    try {
      final response = await postRequest(
        ApiEndpoints.updateOrderStatus,
        data: {
          'order_id': orderId,
          'delivery_id': orderId,
          'status': status,
          if (lat != null) 'lat': lat,
          if (lng != null) 'lng': lng,
        },
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data is Map) ? data.cast<String, dynamic>() : {},
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>.error(e.toString());
    }
  }
}
