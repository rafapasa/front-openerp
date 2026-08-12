import 'package:front_openerp/data/models/models.dart';

import 'services.dart';

class PedidoService {
  final ApiService _apiService;

  PedidoService(this._apiService);

  /// Lista pedidos com filtros
  Future<PaginatedResponse<PedidoModel>> getPedidos({
    int page = 1,
    int limit = 20,
    String? status,
    int? clienteId,
    String? dataInicio,
    String? dataFim,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        'status': ?status,
        'cliente_id': ?clienteId,
        'data_inicio': ?dataInicio,
        'data_fim': ?dataFim,
      };

      final response = await _apiService.get(
        '/pedidos',
        queryParameters: queryParams,
      );

      final data = response.data['data'] as Map<String, dynamic>;

      return PaginatedResponse<PedidoModel>.fromJson(
        data,
        (json) => PedidoModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Busca pedido por ID
  Future<PedidoModel> getPedidoById(int id) async {
    try {
      final response = await _apiService.get('/pedidos/$id');

      final data = response.data['data'] as Map<String, dynamic>;
      return PedidoModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Atualiza status do pedido
  Future<PedidoModel> updateStatusPedido(int id, StatusPedido status) async {
    try {
      final response = await _apiService.patch(
        '/pedidos/$id/status',
        data: {'status': status.toStringValue()},
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return PedidoModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Busca pedidos de um cliente
  Future<PaginatedResponse<PedidoModel>> getPedidosByCliente(
    int clienteId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/clientes/$clienteId/pedidos',
        queryParameters: {'page': page, 'limit': limit},
      );

      final data = response.data['data'] as Map<String, dynamic>;

      return PaginatedResponse<PedidoModel>.fromJson(
        data,
        (json) => PedidoModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }
}
