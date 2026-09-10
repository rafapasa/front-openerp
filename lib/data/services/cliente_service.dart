import 'package:front_openerp/core/helpers/json_helper.dart';
import 'package:front_openerp/data/models/models.dart';

import 'services.dart';

class ClienteService {
  final ApiService _apiService;
  ClienteService(this._apiService);

  Future<PaginatedResponse<ClienteModel>> getClientes({
    int page = 1,
    int limit = 20,
    String? nome,
    String? telefone,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (nome != null && nome.isNotEmpty) 'nome': nome,
      if (telefone != null && telefone.isNotEmpty) 'telefone': telefone,
    };

    final response = await _apiService.get('/clientes', queryParameters: queryParams);
    final paginated = JsonHelper.extractPaginated(response.data);
    return PaginatedResponse<ClienteModel>.fromJson(
      paginated,
      (json) => ClienteModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ClienteModel> getClienteById(int id) async {
    final response = await _apiService.get('/clientes/$id');
    final Map<String, dynamic> data = response.data is Map<String, dynamic>
        ? (response.data['data'] as Map<String, dynamic>? ?? response.data as Map<String, dynamic>)
        : {};
    return ClienteModel.fromJson(data);
  }

  Future<List<EnderecoModel>> getEnderecosByCliente(int clienteId) async {
    final response = await _apiService.get('/clientes/$clienteId/enderecos');
    final list = JsonHelper.extractList(response.data);
    return list.map((e) => EnderecoModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
