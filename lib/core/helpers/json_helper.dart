class JsonHelper {
  static int toInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    if (value is num) return value.toInt();
    return fallback;
  }

  static double toDouble(dynamic value, {double fallback = 0.0}) {
    if (value == null) return fallback;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    if (value is num) return value.toDouble();
    return fallback;
  }

  static String toStr(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    return value.toString();
  }

  static bool toBool(dynamic value, {bool fallback = false}) {
    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return fallback;
  }

  static DateTime? toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static DateTime toDateTimeOrNow(dynamic value) {
    return toDateTime(value) ?? DateTime.now();
  }

  static List<T> toList<T>(dynamic value, T Function(dynamic) mapper) {
    if (value == null) return [];
    if (value is List) return value.map(mapper).toList();
    return [];
  }

  // Backend Go retorna às vezes [] direto, às vezes {data: []}
  static List<dynamic> extractList(dynamic responseData) {
    if (responseData is List) return responseData;
    if (responseData is Map) {
      if (responseData['data'] is List) return responseData['data'] as List;
      if (responseData['pedidos'] is List) return responseData['pedidos'] as List;
      if (responseData['clientes'] is List) return responseData['clientes'] as List;
      if (responseData['produtos'] is List) return responseData['produtos'] as List;
      if (responseData['users'] is List) return responseData['users'] as List;
    }
    return [];
  }

  // Extrai paginação tanto do formato Go atual quanto do futuro padronizado
  static Map<String, dynamic> extractPaginated(dynamic responseData) {
    if (responseData is List) {
      return {'data': responseData, 'total': responseData.length, 'page': 1, 'limit': responseData.length, 'pages': 1};
    }
    if (responseData is Map<String, dynamic>) {
      // Se já é paginado no padrão {data, total, page, limit, pages}
      if (responseData.containsKey('data') && responseData.containsKey('total')) {
        return responseData;
      }
      // Se é PedidoListResponseDTO {pedidos, total, page, limit, total_pages}
      if (responseData.containsKey('pedidos')) {
        return {
          'data': responseData['pedidos'],
          'total': responseData['total'] ?? 0,
          'page': responseData['page'] ?? 1,
          'limit': responseData['limit'] ?? 20,
          'pages': responseData['total_pages'] ?? 1,
        };
      }
    }
    return {'data': extractList(responseData), 'total': 0, 'page': 1, 'limit': 20, 'pages': 1};
  }
}
