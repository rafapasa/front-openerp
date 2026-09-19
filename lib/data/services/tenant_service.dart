import 'package:dio/dio.dart';
import 'package:front_openerp/core/helpers/json_helper.dart';
import 'package:front_openerp/data/models/tenant_model.dart';
import 'package:front_openerp/data/services/api_service.dart';

class TenantService {
  final ApiService _api;

  TenantService(this._api);

  Map<String, dynamic> _asMap(dynamic raw) {
    final data = JsonHelper.extractData(raw);
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw Exception('Resposta inesperada: esperava um objeto de empresa');
  }

  Future<List<TenantModel>> listar() async {
    try {
      final response = await _api.get('/tenants');
      final lista = JsonHelper.extractList(response.data);
      return lista
          .whereType<Map>()
          .map((json) => TenantModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar empresas: $e');
    }
  }

  Future<TenantModel> obter(int id) async {
    try {
      final response = await _api.get('/tenants/$id');
      return TenantModel.fromJson(_asMap(response.data));
    } catch (e) {
      throw Exception('Erro ao obter empresa: $e');
    }
  }

  Future<TenantModel> criar(TenantModel tenant) async {
    try {
      final response = await _api.post('/tenants', data: tenant.toJson());
      return TenantModel.fromJson(_asMap(response.data));
    } catch (e) {
      throw Exception('Erro ao criar empresa: $e');
    }
  }

  Future<TenantModel> atualizar(TenantModel tenant) async {
    if (tenant.id == null) {
      throw Exception('ID da empresa não fornecido para atualização');
    }
    try {
      final response = await _api.put('/tenants/${tenant.id}', data: tenant.toJson());
      return TenantModel.fromJson(_asMap(response.data));
    } catch (e) {
      throw Exception('Erro ao atualizar empresa: $e');
    }
  }

  Future<void> excluir(int id) async {
    try {
      final response = await _api.delete('/tenants/$id');
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw _extractErrorMessage(response);
      }
    } catch (e) {
      throw Exception('Erro ao excluir empresa: $e');
    }
  }

  String _extractErrorMessage(Response response) {
    try {
      final data = response.data;
      if (data is Map) {
        if (data['message'] != null) return data['message'].toString();
        if (data['error'] != null) return data['error'].toString();
      }
      return 'Erro ${response.statusCode}: ${response.data}';
    } catch (_) {
      return 'Erro ${response.statusCode} ao processar requisição';
    }
  }
}
