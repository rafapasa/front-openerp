import 'package:front_openerp/core/helpers/json_helper.dart';
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
    final paginated = JsonHelper.extractPaginated(response.data);
    return PaginatedResponse<PedidoModel>.fromJson(
      paginated,
      (json) => PedidoModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<PedidoModel> getPedidoById(int id) async {
    final response = await _apiService.get('/pedidos/$id');
    final data = response.data is Map<String, dynamic>
        ? (response.data['data'] as Map<String, dynamic>? ?? response.data as Map<String, dynamic>)
        : {};
    return PedidoModel.fromJson(data as Map<String, dynamic>);
  }

  Future<PedidoModel> updateStatusPedido(int id, StatusPedido status) async {
    final response = await _apiService.patch('/pedidos/$id/status', data: {'status': status.toStringValue()});
    final data = response.data is Map<String, dynamic>
        ? (response.data['data'] as Map<String, dynamic>? ?? response.data as Map<String, dynamic>)
        : response.data;
    // Backend atual retorna {status: "updated"} então busca de novo
    if (data is Map && data.containsKey('status') && data.length == 1) {
      return await getPedidoById(id);
    }
    return PedidoModel.fromJson(data as Map<String, dynamic>);
  }

  Future<PaginatedResponse<PedidoModel>> getPedidosByCliente(int clienteId, {int page = 1, int limit = 20}) async {
    final response = await _apiService.get(
      '/clientes/$clienteId/pedidos',
      queryParameters: {'page': page, 'limit': limit},
    );
    // Este endpoint já retorna {pedidos, total, page, limit, total_pages}
    final paginated = JsonHelper.extractPaginated(response.data);
    return PaginatedResponse<PedidoModel>.fromJson(
      paginated,
      (json) => PedidoModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
