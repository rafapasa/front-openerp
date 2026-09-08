import 'package:front_openerp/data/models/models.dart';

import 'services.dart';

class ClienteService {
  final ApiService _apiService;

  ClienteService(this._apiService);

  /// Lista clientes com filtros
  Future<PaginatedResponse<ClienteModel>> getClientes({
    int page = 1,
    int limit = 20,
    String? nome,
    String? telefone,
  }) async {
    try {
      final queryParams = {'page': page, 'limit': limit, 'nome': ?nome, 'telefone': ?telefone};

      final response = await _apiService.get('/clientes', queryParameters: queryParams);

      Map<String, dynamic> data = {for (var item in response.data) ...?item};

      return PaginatedResponse<ClienteModel>.fromJson(
        data,
        (json) => ClienteModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Busca cliente por ID
  Future<ClienteModel> getClienteById(int id) async {
    try {
      final response = await _apiService.get('/clientes/$id');

      Map<String, dynamic> data = {for (var item in response.data) ...?item};
      return ClienteModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Busca endereços de um cliente
  Future<List<EnderecoModel>> getEnderecosByCliente(int clienteId) async {
    try {
      final response = await _apiService.get('/clientes/$clienteId/enderecos');

      final data = response.data['data'] as List;
      return data.map((e) => EnderecoModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
