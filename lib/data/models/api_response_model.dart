<<<<<<< HEAD
import 'package:front_openerp/core/helpers/json_helper.dart';
=======

import '../core/helpers/json_helper.dart';
>>>>>>> 152b260bd98170cf9003af56ca90425af441ccff

class ApiResponse<T> {
  final T data;
  final String? message;
  ApiResponse({required this.data, this.message});
  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return ApiResponse<T>(data: fromJsonT(json['data']), message: json['message'] as String?);
  }
}

class PaginatedResponse<T> {
  final List<T> data;
  final int total;
  final int page;
  final int limit;
  final int pages;
<<<<<<< HEAD
  PaginatedResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });
=======
  PaginatedResponse({required this.data, required this.total, required this.page, required this.limit, required this.pages});
>>>>>>> 152b260bd98170cf9003af56ca90425af441ccff
  factory PaginatedResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    final list = json['data'] is List ? json['data'] as List : [];
    return PaginatedResponse<T>(
      data: list.map((e) => fromJsonT(e)).toList(),
      total: JsonHelper.toInt(json['total'], fallback: list.length),
      page: JsonHelper.toInt(json['page'], fallback: 1),
      limit: JsonHelper.toInt(json['limit'], fallback: 20),
      pages: JsonHelper.toInt(json['total_pages'] ?? json['pages'], fallback: 1),
    );
  }
}
