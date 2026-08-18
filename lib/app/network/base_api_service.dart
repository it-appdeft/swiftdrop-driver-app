import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'dio_client.dart';

abstract class BaseApiService {
  final Dio dio = DioClient.instance;

  Future<Response> getRequest(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> postRequest(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool isRawData = false,
    bool forceMultipart = false,
  }) async {
    return _handleBodyRequest(
      dio.post,
      path,
      data,
      queryParameters,
      options,
      isRawData,
      forceMultipart,
    );
  }

  Future<Response> putRequest(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool isRawData = false,
    bool forceMultipart = false,
  }) async {
    return _handleBodyRequest(
      dio.put,
      path,
      data,
      queryParameters,
      options,
      isRawData,
      forceMultipart,
    );
  }

  Future<Response> deleteRequest(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> _handleBodyRequest(
    Function method,
    String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool isRawData,
    bool forceMultipart,
  ) async {
    dynamic payload = data;
    Options? requestOptions = options ?? Options();

    if (isRawData) {
      // Send as JSON (Raw Data)
      requestOptions.contentType = Headers.jsonContentType;
      payload = data;
    } else if (data is Map<String, dynamic>) {
      // Send as Form Data (Multipart or Url-encoded)
      final map = Map<String, dynamic>.from(data);
      bool containsFile = false;

      // Automatically convert File objects to MultipartFile
      for (var key in map.keys) {
        final value = map[key];
        if (value is File) {
          containsFile = true;
          map[key] = await _fileToMultipart(value);
        } else if (value is List<File>) {
          containsFile = true;
          map[key] = await Future.wait(value.map(_fileToMultipart));
        } else if (value is MultipartFile || value is List<MultipartFile>) {
          containsFile = true;
        }
      }

      if (containsFile || forceMultipart) {
        payload = FormData.fromMap(map);
        requestOptions.contentType = Headers.multipartFormDataContentType;
      } else {
        // For simple maps without files, use formUrlEncoded
        requestOptions.contentType = Headers.formUrlEncodedContentType;
        payload = data;
      }
    }

    return await method(
      path,
      data: payload,
      queryParameters: queryParameters,
      options: requestOptions,
    );
  }

  Future<MultipartFile> _fileToMultipart(File file) async {
    final mime = lookupMimeType(file.path) ?? 'application/octet-stream';
    return MultipartFile.fromFile(
      file.path,
      filename: file.path.split('/').last,
      contentType: MediaType.parse(mime),
    );
  }
}
