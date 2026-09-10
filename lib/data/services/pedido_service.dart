
import 'package:front_openerp/data/models/models.dart';
import '../core/helpers/json_helper.dart';
import 'services.dart';

class PedidoService {
  final ApiService _apiService;
  PedidoService(this._apiService);

  Future<PaginatedResponse<PedidoModel>> getPedidos({int page = 1, int limit = 20, String? status, int? clienteId, String? dataInicio, String? dataFim}) async {
    final queryParams = <String, dynamic>{
      'page': page, 'limit': limit,
      if (status != null) 'status': status,
      if (clienteId != null) 'cliente_id': clienteId,
      if (dataInicio != null) 'data_inicio': dataInicio,
      if (dataFim != null) 'data_fim': dataFim,
    };
    final response = await _apiService.get('/pedidos', queryParameters: queryParams);
    // Novo padrão: response.data = {data: [], total, page, limit, total_pages}
    return PaginatedResponse<PedidoModel>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => PedidoModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<PedidoModel> getPedidoById(int id) async {
    final response = await _apiService.get('/pedidos/$id');
    // Novo padrão: {data: {pedido}}
    final map = response.data as Map<String, dynamic>;
    final data = map['data'] as Map<String, dynamic>;
    return PedidoModel.fromJson(data);
  }

  Future<PedidoModel> updateStatusPedido(int id, StatusPedido status) async {
    final response = await _apiService.patch('/pedidos/$id/status', data: {'status': status.toStringValue()});
    final map = response.data as Map<String, dynamic>;
    final data = map['data'] as Map<String, dynamic>;
    return PedidoModel.fromJson(data);
  }

  Future<PaginatedResponse<PedidoModel>> getPedidosByCliente(int clienteId, {int page = 1, int limit = 20}) async {
    final response = await _apiService.get('/clientes/$clienteId/pedidos', queryParameters: {'page': page, 'limit': limit});
    return PaginatedResponse<PedidoModel>.fromJson(
      response.data as Map<String, dynamic>,
      (json) => PedidoModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
