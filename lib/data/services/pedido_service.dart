import 'package:front_openerp/data/models/models.dart';

import 'services.dart';

class PedidoService {
  final ApiService _apiService;
  PedidoService(this._apiService);

  Future<PaginatedResponse<PedidoModel>> getPedidos({
    int page = 1,
    int limit = 20,
    String? status,
    int? clienteId,
    String? dataInicio,
    String? dataFim,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (status != null) 'status': status,
      if (clienteId != null) 'cliente_id': clienteId,
      if (dataInicio != null) 'data_inicio': dataInicio,
      if (dataFim != null) 'data_fim': dataFim,
    };
    final response = await _apiService.get('/pedidos', queryParameters: queryParams);
    return PaginatedResponse<PedidoModel>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => PedidoModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<PedidoModel> getPedidoById(int id) async {
    final response = await _apiService.get('/pedidos/$id');
    final map = response.data as Map<String, dynamic>;
    final data = map['data'] as Map<String, dynamic>;
    return PedidoModel.fromJson(data);
  }

  Future<PedidoModel> updateStatusPedido(int id, StatusPedido status, {String? motivo}) async {
    final body = <String, dynamic>{
      'status': status.toStringValue(),
      if (motivo != null && motivo.trim().isNotEmpty) 'motivo': motivo.trim(),
    };
    final response = await _apiService.patch('/pedidos/$id/status', data: body);
    final map = response.data as Map<String, dynamic>;
    final data = map['data'] as Map<String, dynamic>;
    return PedidoModel.fromJson(data);
  }

  /// Endpoint ainda não existe no back. Quando existir, ligar em issue #14.
  Future<PedidoModel> marcarPago(int id, {int? formaPagamentoId, double? valor, String? observacao}) async {
    try {
      final response = await _apiService.patch(
        '/pedidos/$id/pagamento',
        data: {
          'pago': true,
          if (formaPagamentoId != null) 'forma_pagamento_id': formaPagamentoId,
          if (valor != null) 'valor': valor,
          if (observacao != null) 'observacao': observacao,
        },
      );
      final map = response.data as Map<String, dynamic>;
      final data = map['data'] as Map<String, dynamic>;
      return PedidoModel.fromJson(data);
    } catch (_) {
      rethrow;
    }
  }

  Future<PaginatedResponse<PedidoModel>> getPedidosByCliente(int clienteId, {int page = 1, int limit = 20}) async {
    final response = await _apiService.get(
      '/clientes/$clienteId/pedidos',
      queryParameters: {'page': page, 'limit': limit},
    );
    return PaginatedResponse<PedidoModel>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => PedidoModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
