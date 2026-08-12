class ApiResponse<T> {
  final bool success;
  final String? message;
  final String? error;
  final T? data;

  ApiResponse({required this.success, this.message, this.error, this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'],
      error: json['error'],
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'error': error,
    'data': data,
  };
}
