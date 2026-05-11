import 'package:dio/dio.dart';
import '../../app/network/api_endpoints.dart';
import '../../app/network/dio_client.dart';
import '../local/app_data.dart';
import '../models/api_response.dart';
import '../models/transaction_model.dart';

class EarningsRepository {
  final Dio _dio = DioClient.instance;

  Future<ApiResponse<Map<String, dynamic>>> getEarningsSummary() async {
    try {
      final response = await _dio.get(ApiEndpoints.earningsSummary);
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as Map<String, dynamic>,
      );
    } catch (_) {
      return ApiResponse<Map<String, dynamic>>(
          success: true, message: '', data: AppData.earningsSummary);
    }
  }

  Future<ApiResponse<List<TransactionModel>>> getTransactions({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.transactionHistory,
        queryParameters: {'page': page, 'limit': limit},
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data as List<dynamic>)
            .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (_) {
      return ApiResponse<List<TransactionModel>>(
          success: true, message: '', data: AppData.transactions);
    }
  }
}
