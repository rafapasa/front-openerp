// lib/data/repositories/produto_repository.dart
import 'package:front_openerp/data/models/models.dart';
import 'package:front_openerp/data/repositories/local_storage.dart';
import 'package:front_openerp/data/services/services.dart';

class ProdutoRepository {
  final ProdutoService _produtoService;

  ProdutoRepository(this._produtoService);

  // ============================================================
  // 📋 Listar Produtos (com cache)
  // ============================================================
  Future<PaginatedResponse<ProdutoModel>> getProdutos({
    int page = 1,
    int limit = 20,
    int? categoriaId,
    bool? disponivel,
    String? nome,
    bool forceRefresh = false,
  }) async {
    // Cache apenas para página 1 sem filtros
    if (!forceRefresh &&
        page == 1 &&
        categoriaId == null &&
        disponivel == null &&
        nome == null &&
        LocalStorage.isCacheValid(LocalStorage.produtosKey)) {
      final cached = LocalStorage.getData<List<dynamic>>(
        LocalStorage.produtosKey,
      );
      if (cached != null) {
        final data = cached
            .map((e) => ProdutoModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return PaginatedResponse<ProdutoModel>(
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
      final produtos = await _produtoService.getProdutos(
        page: page,
        limit: limit,
        categoriaId: categoriaId,
        disponivel: disponivel,
        nome: nome,
      );

      // Salvar no cache apenas para página 1
      if (page == 1 &&
          categoriaId == null &&
          disponivel == null &&
          nome == null) {
        await LocalStorage.saveData(
          LocalStorage.produtosKey,
          produtos.data.map((e) => e.toJson()).toList(),
        );
      }

      return produtos;
    } catch (e) {
      // Se falhou e tem cache, usar cache
      if (page == 1) {
        final cached = LocalStorage.getData<List<dynamic>>(
          LocalStorage.produtosKey,
        );
        if (cached != null) {
          final data = cached
              .map((e) => ProdutoModel.fromJson(e as Map<String, dynamic>))
              .toList();
          return PaginatedResponse<ProdutoModel>(
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
  // 🔍 Buscar Produto por ID
  // ============================================================
  Future<ProdutoModel> getProdutoById(int id) async {
    // Verificar se está no cache
    final cached = LocalStorage.getData<List<dynamic>>(
      LocalStorage.produtosKey,
    );
    if (cached != null) {
      try {
        final produto = cached.firstWhere(
          (e) => e['id'] == id,
          orElse: () => null,
        );
        if (produto != null) {
          return ProdutoModel.fromJson(produto as Map<String, dynamic>);
        }
      } catch (e) {
        // Não encontrado, buscar da API
      }
    }

    // Buscar da API
    try {
      return await _produtoService.getProdutoById(id);
    } catch (e) {
      // Se falhou e tem cache, usar mesmo assim
      final cached = LocalStorage.getData<List<dynamic>>(
        LocalStorage.produtosKey,
      );
      if (cached != null) {
        final produto = cached.firstWhere(
          (e) => e['id'] == id,
          orElse: () => null,
        );
        if (produto != null) {
          return ProdutoModel.fromJson(produto as Map<String, dynamic>);
        }
      }
      rethrow;
    }
  }

  // ============================================================
  // 🗑️ Limpar cache
  // ============================================================
  Future<void> clearCache() async {
    await LocalStorage.clearCache(LocalStorage.produtosKey);
  }
}
