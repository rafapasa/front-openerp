// lib/data/services/tenant_service.dart
import 'package:front_openerp/data/models/tenant_model.dart';
import 'package:front_openerp/data/services/api_service.dart';

class TenantService {
  final ApiService _api;

  TenantService(this._api);

  Future<List<TenantModel>> listar() async {
    try {
      final response = await _api.get('/tenants');
      if (response.isSuccess) {
        List data;
        if (response.data is Map && response.data['data'] != null) {
          data = response.data['data'];
        } else if (response.data is List) {
          data = response.data;
        } else {
          throw Exception('Formato de resposta inesperado');
        }
        return data.map((json) => TenantModel.fromJson(json)).toList();
      }
      throw _extractErrorMessage(response);
    } catch (e) {
      throw Exception('Erro ao listar empresas: $e');
    }
  }

  Future<TenantModel> obter(int id) async {
    try {
      final response = await _api.get('/tenants/$id');
      if (response.isSuccess) {
        final data = response.data is Map && response.data['data'] != null
            ? response.data['data']
            : response.data;
        return TenantModel.fromJson(data);
      }
      throw _extractErrorMessage(response);
    } catch (e) {
      throw Exception('Erro ao obter empresa: $e');
    }
  }

  Future<TenantModel> criar(TenantModel tenant) async {
    try {
      final response = await _api.post('/tenants', data: tenant.toJson());
      if (response.isSuccess) {
        final data = response.data is Map && response.data['data'] != null
            ? response.data['data']
            : response.data;
        return TenantModel.fromJson(data);
      }
      throw _extractErrorMessage(response);
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
      if (response.isSuccess) {
        final data = response.data is Map && response.data['data'] != null
            ? response.data['data']
            : response.data;
        return TenantModel.fromJson(data);
      }
      throw _extractErrorMessage(response);
    } catch (e) {
      throw Exception('Erro ao atualizar empresa: $e');
    }
  }

  Future<void> excluir(int id) async {
    try {
      final response = await _api.delete('/tenants/$id');
      if (!response.isSuccess) {
        throw _extractErrorMessage(response);
      }
    } catch (e) {
      throw Exception('Erro ao excluir empresa: $e');
    }
  }

  String _extractErrorMessage(ApiResponse response) {
    try {
      final data = response.data;
      if (data is Map) {
        if (data['message'] != null) return data['message'];
        if (data['error'] != null) return data['error'];
        if (data['errors'] != null) {
          final errors = data['errors'] as Map;
          return errors.values.first.toString();
        }
      }
      return 'Erro ${response.statusCode}: ${response.data}';
    } catch (_) {
      return 'Erro ${response.statusCode} ao processar requisição';
    }
  }
}