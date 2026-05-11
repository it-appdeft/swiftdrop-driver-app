class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;
  final Map<String, dynamic>? meta;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
    this.meta,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
      statusCode: json['status_code'] as int?,
      meta: json['meta'] as Map<String, dynamic>?,
    );
  }

  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse<T>(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }

  bool get hasData => data != null;
  int get totalCount => meta?['total'] as int? ?? 0;
  int get currentPage => meta?['page'] as int? ?? 1;
  bool get hasMore => meta?['has_more'] as bool? ?? false;

  @override
  String toString() =>
      'ApiResponse(success: $success, message: $message, data: $data)';
}
