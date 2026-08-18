import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('--- API Request ---');
    debugPrint('URL: ${options.baseUrl}${options.path}');
    debugPrint('Method: ${options.method}');
    debugPrint('Headers: ${options.headers}');
    if (options.data != null) {
      if (options.data is FormData) {
        final formData = options.data as FormData;
        debugPrint('Body (FormData fields): ${formData.fields}');
        final files = formData.files
            .map((e) =>
                '${e.key}: ${e.value.filename} (${e.value.contentType}, ${e.value.length} bytes)')
            .toList();
        debugPrint('Body (FormData files): $files');
      } else {
        debugPrint('Body: ${jsonEncode(options.data)}');
      }
    }
    debugPrint('-------------------');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('--- API Response ---');
    debugPrint('URL: ${response.requestOptions.baseUrl}${response.requestOptions.path}');
    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response: ${jsonEncode(response.data)}');
    debugPrint('--------------------');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('--- API Error ---');
    debugPrint('URL: ${err.requestOptions.baseUrl}${err.requestOptions.path}');
    debugPrint('Method: ${err.requestOptions.method}');
    debugPrint('Status Code: ${err.response?.statusCode}');
    final reqData = err.requestOptions.data;
    if (reqData != null) {
      if (reqData is FormData) {
        debugPrint('Request Body (fields): ${reqData.fields}');
        final files = reqData.files
            .map((e) =>
                '${e.key}: ${e.value.filename} (${e.value.contentType}, ${e.value.length} bytes)')
            .toList();
        if (files.isNotEmpty) debugPrint('Request Body (files): $files');
      } else {
        debugPrint('Request Body: ${jsonEncode(reqData)}');
      }
    }
    debugPrint('Error Message: ${err.message}');
    if (err.response?.data != null) {
      debugPrint('Error Response: ${jsonEncode(err.response?.data)}');
    }
    debugPrint('-----------------');
    handler.next(err);
  }
}
