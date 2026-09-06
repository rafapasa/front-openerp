// lib/data/repositories/tenant_repository.dart
import 'package:front_openerp/data/models/models.dart';
import 'package:front_openerp/data/models/tenant_model.dart';
import 'package:front_openerp/data/repositories/local_storage.dart';
import 'package:front_openerp/data/services/tenant_service.dart';

class TenantRepository {
  final TenantService _tenantService;

  TenantRepository(this._tenantService);

  // ============================================================
  // 📋 Listar Tenants (com cache)
  // ============================================================
  Future<PaginatedResponse<TenantModel>> getTenants({
    int page = 1,
    int limit = 20,
    String? nome,
    String? status,
    String? cnpj,
    bool forceRefresh = false,
  }) async {
    // Cache apenas para página 1 sem filtros
    if (!forceRefresh &&
        page == 1 &&
        nome == null &&
        status == null &&
        cnpj == null &&
        LocalStorage.isCacheValid('tenants')) {
      final cached = LocalStorage.getData<List<dynamic>>('tenants');
      if (cached != null) {
        final data = cached
            .map((e) => TenantModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return PaginatedResponse<TenantModel>(
          data: data,
          total: data.length,
          page: 1,
          limit: data.length,
          pages: 1,
        );
      }
    }

    // Buscar da API
    try {
      final tenants = await _tenantService.getTenants(
        page: page,
        limit: limit,
        nome: nome,
        ativo: status == 'ativo'
            ? true
            : status == 'inativo'
            ? false
            : null,
        cnpj: cnpj,
      );

      // Salvar no cache apenas para página 1
      if (page == 1 && nome == null && status == null && cnpj == null) {
        await LocalStorage.saveData(
          'tenants',
          tenants.data.map((e) => e.toJson()).toList(),
        );
      }

      return tenants;
    } catch (e) {
      // Se falhou e tem cache, usar cache
      if (page == 1) {
        final cached = LocalStorage.getData<List<dynamic>>('tenants');
        if (cached != null) {
          final data = cached
              .map((e) => TenantModel.fromJson(e as Map<String, dynamic>))
              .toList();
          return PaginatedResponse<TenantModel>(
            data: data,
            total: data.length,
            page: 1,
            limit: data.length,
            pages: 1,
          );
        }
      }
      rethrow;
    }
  }

  // ============================================================
  // 🔍 Buscar Tenant por ID
  // ============================================================
  Future<TenantModel> getTenantById(int id) async {
    // Verificar se está no cache
    final cached = LocalStorage.getData<List<dynamic>>('tenants');
    if (cached != null) {
      try {
        final tenant = cached.firstWhere(
          (e) => e['id'] == id,
          orElse: () => null,
        );
        if (tenant != null) {
          return TenantModel.fromJson(tenant as Map<String, dynamic>);
        }
      } catch (e) {
        // Não encontrado, buscar da API
      }
    }

    // Buscar da API
    try {
      return await _tenantService.getTenantById(id);
    } catch (e) {
      // Se falhou e tem cache, usar mesmo assim
      final cached = LocalStorage.getData<List<dynamic>>('tenants');
      if (cached != null) {
        final tenant = cached.firstWhere(
          (e) => e['id'] == id,
          orElse: () => null,
        );
        if (tenant != null) {
          return TenantModel.fromJson(tenant as Map<String, dynamic>);
        }
      }
      rethrow;
    }
  }

  // ============================================================
  // ➕ Criar Tenant
  // ============================================================
  Future<TenantModel> createTenant(Map<String, dynamic> data) async {
    try {
      final tenant = await _tenantService.createTenant(
        CreateTenantDTO.fromJson(data),
      );

      // Atualizar cache
      final cached = LocalStorage.getData<List<dynamic>>('tenants');
      if (cached != null) {
        final updatedCache = [tenant.toJson(), ...cached];
        await LocalStorage.saveData('tenants', updatedCache);
      }

      return tenant;
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // ✏️ Atualizar Tenant
  // ============================================================
  Future<TenantModel> updateTenant(int id, Map<String, dynamic> data) async {
    try {
      final tenant = await _tenantService.updateTenant(
        id,
        UpdateTenantDTO.fromJson(data),
      );

      // Atualizar cache
      final cached = LocalStorage.getData<List<dynamic>>('tenants');
      if (cached != null) {
        final updatedCache = cached.map((e) {
          if (e['id'] == id) {
            return tenant.toJson();
          }
          return e;
        }).toList();
        await LocalStorage.saveData('tenants', updatedCache);
      }

      return tenant;
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // 🗑️ Deletar Tenant
  // ============================================================
  Future<bool> deleteTenant(int id) async {
    try {
      await _tenantService.deleteTenant(id);

      // Remover do cache
      final cached = LocalStorage.getData<List<dynamic>>('tenants');
      if (cached != null) {
        final updatedCache = cached.where((e) => e['id'] != id).toList();
        await LocalStorage.saveData('tenants', updatedCache);
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // 🔄 Alterar Status
  // ============================================================
  Future<TenantModel> updateStatus(int id, TenantStatus status) async {
    try {
      final tenant = await _tenantService.toggleStatus(id);

      // Atualizar cache
      final cached = LocalStorage.getData<List<dynamic>>('tenants');
      if (cached != null) {
        final updatedCache = cached.map((e) {
          if (e['id'] == id) {
            return tenant.toJson();
          }
          return e;
        }).toList();
        await LocalStorage.saveData('tenants', updatedCache);
      }

      return tenant;
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // 🗑️ Limpar Cache
  // ============================================================
  Future<void> clearCache() async {
    await LocalStorage.clearCache('tenants');
  }
}
