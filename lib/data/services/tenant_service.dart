// lib/data/services/tenant_service.dart
import 'package:front_openerp/data/models/models.dart';
import 'package:front_openerp/data/models/tenant_model.dart';
import 'package:front_openerp/data/services/api_service.dart';

class TenantService {
  final ApiService _apiService;

  TenantService(this._apiService);

  // ============================================================
  // 📋 Listar Tenants
  // ============================================================
  Future<PaginatedResponse<TenantModel>> getTenants({
    int page = 1,
    int limit = 20,
    String? nome,
    bool? ativo,
    String? cnpj,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        'nome': ?nome,
        'ativo': ?ativo,
        'cnpj': ?cnpj,
      };

      final response = await _apiService.get(
        '/tenants',
        queryParameters: queryParams,
      );

      final data = response.data['data'] as Map<String, dynamic>;

      return PaginatedResponse<TenantModel>.fromJson(
        data,
        (json) => TenantModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // 🔍 Buscar Tenant por ID
  // ============================================================
  Future<TenantModel> getTenantById(int id) async {
    try {
      final response = await _apiService.get('/tenants/$id');

      final data = response.data['data'] as Map<String, dynamic>;
      return TenantModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // ➕ Criar Tenant (usando DTO)
  // ============================================================
  Future<TenantModel> createTenant(CreateTenantDTO dto) async {
    try {
      final response = await _apiService.post('/tenants', data: dto.toJson());

      final data = response.data['data'] as Map<String, dynamic>;
      return TenantModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // ✏️ Atualizar Tenant (usando DTO)
  // ============================================================
  Future<TenantModel> updateTenant(int id, UpdateTenantDTO dto) async {
    try {
      final response = await _apiService.put(
        '/tenants/$id',
        data: dto.toJson(),
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return TenantModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // 🗑️ Deletar Tenant
  // ============================================================
  Future<bool> deleteTenant(int id) async {
    try {
      await _apiService.delete('/tenants/$id');
      return true;
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // 🔄 Ativar/Desativar
  // ============================================================
  Future<TenantModel> toggleStatus(int id) async {
    try {
      final response = await _apiService.patch('/tenants/$id/toggle');

      final data = response.data['data'] as Map<String, dynamic>;
      return TenantModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // 💬 Conectar WhatsApp
  // ============================================================
  Future<TenantModel> connectWhatsapp(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post(
        '/tenants/$id/whatsapp/connect',
        data: data,
      );

      final responseData = response.data['data'] as Map<String, dynamic>;
      return TenantModel.fromJson(responseData);
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // 💬 Desconectar WhatsApp
  // ============================================================
  Future<TenantModel> disconnectWhatsapp(int id) async {
    try {
      final response = await _apiService.post(
        '/tenants/$id/whatsapp/disconnect',
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return TenantModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // 🔍 Buscar CNPJ/CPF na Receita (Frontend apenas)
  // ============================================================
  Future<Map<String, dynamic>> buscarDadosReceita(String documento) async {
    try {
      final response = await _apiService.get(
        '/consulta/receita',
        queryParameters: {'documento': documento},
      );
      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}
