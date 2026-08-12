class PaginatedResponse<T> {
  final List<T> data;
  final int total;
  final int page;
  final int limit;
  final int pages;

  PaginatedResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    final dataList = json['data'] as List? ?? [];
    return PaginatedResponse<T>(
      data: dataList.map((e) => fromJsonT(e)).toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      pages: json['pages'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'data': data,
    'total': total,
    'page': page,
    'limit': limit,
    'pages': pages,
  };
}
