// lib/presentation/providers/produto_provider.dart
import 'package:flutter/material.dart';
import 'package:front_openerp/data/models/models.dart';
import 'package:front_openerp/data/repositories/repositories.dart';

class ProdutoProvider extends ChangeNotifier {
  final ProdutoRepository _produtoRepository;

  // ============================================================
  // 📊 Estado
  // ============================================================
  List<ProdutoModel> _produtos = [];
  PaginatedResponse<ProdutoModel>? _paginatedResponse;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  // Filtros
  int? _categoriaFilter;
  bool? _disponivelFilter;
  String? _nomeFilter;

  // ============================================================
  // 🔍 Getters
  // ============================================================
  List<ProdutoModel> get produtos => _produtos;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;
  int get total => _paginatedResponse?.total ?? 0;
  int get currentPage => _currentPage;
  int get totalPages => _paginatedResponse?.pages ?? 0;

  int? get categoriaFilter => _categoriaFilter;
  bool? get disponivelFilter => _disponivelFilter;
  String? get nomeFilter => _nomeFilter;

  // ============================================================
  // 📊 Produtos Disponíveis
  // ============================================================
  List<ProdutoModel> get produtosDisponiveis =>
      _produtos.where((p) => p.disponivel).toList();

  List<ProdutoModel> get produtosIndisponiveis =>
      _produtos.where((p) => !p.disponivel).toList();

  // ============================================================
  // 🏗️ Construtor
  // ============================================================
  ProdutoProvider(this._produtoRepository);

  // ============================================================
  // 📋 Carregar Produtos
  // ============================================================
  Future<void> loadProdutos({
    bool forceRefresh = false,
    int? categoriaId,
    bool? disponivel,
    String? nome,
  }) async {
    // Atualizar filtros
    _categoriaFilter = categoriaId;
    _disponivelFilter = disponivel;
    _nomeFilter = nome;

    // Resetar paginação
    _currentPage = 1;
    _produtos = [];
    _hasMore = true;

    _setLoading(true);

    try {
      final response = await _produtoRepository.getProdutos(
        page: _currentPage,
        limit: 20,
        categoriaId: _categoriaFilter,
        disponivel: _disponivelFilter,
        nome: _nomeFilter,
        forceRefresh: forceRefresh,
      );

      _paginatedResponse = response;
      _produtos = response.data;
      _hasMore = response.page < response.pages;
      _clearError();
    } catch (e) {
      _error = e.toString();
    }

    _setLoading(false);
  }

  // ============================================================
  // 📥 Carregar Mais (Pagination)
  // ============================================================
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final response = await _produtoRepository.getProdutos(
        page: nextPage,
        limit: 20,
        categoriaId: _categoriaFilter,
        disponivel: _disponivelFilter,
        nome: _nomeFilter,
      );

      _paginatedResponse = response;
      _produtos.addAll(response.data);
      _currentPage = nextPage;
      _hasMore = response.page < response.pages;
      _clearError();
    } catch (e) {
      _error = e.toString();
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  // ============================================================
  // 🔍 Buscar Produto por ID
  // ============================================================
  Future<ProdutoModel?> getProdutoById(int id) async {
    try {
      // Tentar encontrar no cache primeiro
      try {
        final cached = _produtos.firstWhere((p) => p.id == id);
        return cached;
      } catch (e) {
        // Não encontrado, buscar da API
        final produto = await _produtoRepository.getProdutoById(id);
        // Adicionar à lista se não existir
        if (!_produtos.any((p) => p.id == id)) {
          _produtos.insert(0, produto);
          notifyListeners();
        }
        return produto;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // ============================================================
  // 🔄 Refresh
  // ============================================================
  Future<void> refreshProdutos() async {
    await loadProdutos(
      forceRefresh: true,
      categoriaId: _categoriaFilter,
      disponivel: _disponivelFilter,
      nome: _nomeFilter,
    );
  }

  // ============================================================
  // 🔍 Buscar por Nome
  // ============================================================
  Future<void> searchByNome(String nome) async {
    await loadProdutos(forceRefresh: true, nome: nome);
  }

  // ============================================================
  // 🔍 Buscar por Categoria
  // ============================================================
  Future<void> filterByCategoria(int categoriaId) async {
    await loadProdutos(forceRefresh: true, categoriaId: categoriaId);
  }

  // ============================================================
  // 🔍 Filtrar Disponíveis
  // ============================================================
  Future<void> filterByDisponibilidade(bool disponivel) async {
    await loadProdutos(forceRefresh: true, disponivel: disponivel);
  }

  // ============================================================
  // 🗑️ Limpar Filtros
  // ============================================================
  void clearFilters() {
    _categoriaFilter = null;
    _disponivelFilter = null;
    _nomeFilter = null;
    notifyListeners();
  }

  // ============================================================
  // 🗑️ Limpar Cache
  // ============================================================
  Future<void> clearCache() async {
    await _produtoRepository.clearCache();
    _produtos = [];
    _paginatedResponse = null;
    notifyListeners();
  }

  // ============================================================
  // 🛠️ Métodos Privados
  // ============================================================
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // ============================================================
  // 🗑️ Dispose
  // ============================================================
  @override
  void dispose() {
    super.dispose();
  }
}
