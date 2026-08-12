// lib/data/repositories/cliente_repository.dart
import 'package:front_openerp/data/models/models.dart';
import 'package:front_openerp/data/repositories/local_storage.dart';
import 'package:front_openerp/data/services/services.dart';

class ClienteRepository {
  final ClienteService _clienteService;

  ClienteRepository(this._clienteService);

  // ============================================================
  // 📋 Listar Clientes (com cache)
  // ============================================================
  Future<PaginatedResponse<ClienteModel>> getClientes({
    int page = 1,
    int limit = 20,
    String? nome,
    String? telefone,
    bool forceRefresh = false,
  }) async {
    // Cache apenas para página 1 sem filtros
    if (!forceRefresh &&
        page == 1 &&
        nome == null &&
        telefone == null &&
        LocalStorage.isCacheValid(LocalStorage.clientesKey)) {
      final cached = LocalStorage.getData<List<dynamic>>(
        LocalStorage.clientesKey,
      );
      if (cached != null) {
        final data = cached
            .map((e) => ClienteModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return PaginatedResponse<ClienteModel>(
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
      final clientes = await _clienteService.getClientes(
        page: page,
        limit: limit,
        nome: nome,
        telefone: telefone,
      );

      // Salvar no cache apenas para página 1
      if (page == 1 && nome == null && telefone == null) {
        await LocalStorage.saveData(
          LocalStorage.clientesKey,
          clientes.data.map((e) => e.toJson()).toList(),
        );
      }

      return clientes;
    } catch (e) {
      // Se falhou e tem cache, usar cache
      if (page == 1) {
        final cached = LocalStorage.getData<List<dynamic>>(
          LocalStorage.clientesKey,
        );
        if (cached != null) {
          final data = cached
              .map((e) => ClienteModel.fromJson(e as Map<String, dynamic>))
              .toList();
          return PaginatedResponse<ClienteModel>(
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
  // 🔍 Buscar Cliente por ID
  // ============================================================
  Future<ClienteModel> getClienteById(int id) async {
    // Verificar se está no cache
    final cached = LocalStorage.getData<List<dynamic>>(
      LocalStorage.clientesKey,
    );
    if (cached != null) {
      try {
        final cliente = cached.firstWhere(
          (e) => e['id'] == id,
          orElse: () => null,
        );
        if (cliente != null) {
          return ClienteModel.fromJson(cliente as Map<String, dynamic>);
        }
      } catch (e) {
        // Não encontrado, buscar da API
      }
    }

    // Buscar da API
    try {
      return await _clienteService.getClienteById(id);
    } catch (e) {
      // Se falhou e tem cache, usar mesmo assim
      final cached = LocalStorage.getData<List<dynamic>>(
        LocalStorage.clientesKey,
      );
      if (cached != null) {
        final cliente = cached.firstWhere(
          (e) => e['id'] == id,
          orElse: () => null,
        );
        if (cliente != null) {
          return ClienteModel.fromJson(cliente as Map<String, dynamic>);
        }
      }
      rethrow;
    }
  }

  // ============================================================
  // 🗑️ Limpar cache
  // ============================================================
  Future<void> clearCache() async {
    await LocalStorage.clearCache(LocalStorage.clientesKey);
  }
}
