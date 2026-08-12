// lib/presentation/providers/cliente_provider.dart
import 'package:flutter/material.dart';
import 'package:front_openerp/data/models/models.dart';
import 'package:front_openerp/data/repositories/repositories.dart';

class ClienteProvider extends ChangeNotifier {
  final ClienteRepository _clienteRepository;

  // ============================================================
  // 📊 Estado
  // ============================================================
  List<ClienteModel> _clientes = [];
  PaginatedResponse<ClienteModel>? _paginatedResponse;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  // Filtros
  String? _nomeFilter;
  String? _telefoneFilter;

  // ============================================================
  // 🔍 Getters
  // ============================================================
  List<ClienteModel> get clientes => _clientes;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;
  int get total => _paginatedResponse?.total ?? 0;
  int get currentPage => _currentPage;
  int get totalPages => _paginatedResponse?.pages ?? 0;

  String? get nomeFilter => _nomeFilter;
  String? get telefoneFilter => _telefoneFilter;

  // ============================================================
  // 🏗️ Construtor
  // ============================================================
  ClienteProvider(this._clienteRepository);

  // ============================================================
  // 📋 Carregar Clientes
  // ============================================================
  Future<void> loadClientes({
    bool forceRefresh = false,
    String? nome,
    String? telefone,
  }) async {
    // Atualizar filtros
    _nomeFilter = nome;
    _telefoneFilter = telefone;

    // Resetar paginação
    _currentPage = 1;
    _clientes = [];
    _hasMore = true;

    _setLoading(true);

    try {
      final response = await _clienteRepository.getClientes(
        page: _currentPage,
        limit: 20,
        nome: _nomeFilter,
        telefone: _telefoneFilter,
        forceRefresh: forceRefresh,
      );

      _paginatedResponse = response;
      _clientes = response.data;
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
      final response = await _clienteRepository.getClientes(
        page: nextPage,
        limit: 20,
        nome: _nomeFilter,
        telefone: _telefoneFilter,
      );

      _paginatedResponse = response;
      _clientes.addAll(response.data);
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
  // 🔍 Buscar Cliente por ID
  // ============================================================
  Future<ClienteModel?> getClienteById(int id) async {
    try {
      // Tentar encontrar no cache primeiro
      try {
        final cached = _clientes.firstWhere((c) => c.id == id);
        return cached;
      } catch (e) {
        // Não encontrado, buscar da API
        final cliente = await _clienteRepository.getClienteById(id);
        // Adicionar à lista se não existir
        if (!_clientes.any((c) => c.id == id)) {
          _clientes.insert(0, cliente);
          notifyListeners();
        }
        return cliente;
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
  Future<void> refreshClientes() async {
    await loadClientes(
      forceRefresh: true,
      nome: _nomeFilter,
      telefone: _telefoneFilter,
    );
  }

  // ============================================================
  // 🔍 Buscar por Nome
  // ============================================================
  Future<void> searchByNome(String nome) async {
    await loadClientes(forceRefresh: true, nome: nome);
  }

  // ============================================================
  // 🔍 Buscar por Telefone
  // ============================================================
  Future<void> searchByTelefone(String telefone) async {
    await loadClientes(forceRefresh: true, telefone: telefone);
  }

  // ============================================================
  // 🗑️ Limpar Filtros
  // ============================================================
  void clearFilters() {
    _nomeFilter = null;
    _telefoneFilter = null;
    notifyListeners();
  }

  // ============================================================
  // 🗑️ Limpar Cache
  // ============================================================
  Future<void> clearCache() async {
    await _clienteRepository.clearCache();
    _clientes = [];
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
