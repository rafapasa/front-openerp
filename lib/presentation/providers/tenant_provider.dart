// lib/presentation/providers/tenant_provider.dart
import 'package:flutter/material.dart';
import 'package:front_openerp/data/models/models.dart';
import 'package:front_openerp/data/models/tenant_model.dart';
import 'package:front_openerp/data/repositories/tenant_repository.dart';

class TenantProvider extends ChangeNotifier {
  final TenantRepository _tenantRepository;

  // ============================================================
  // 📊 Estado
  // ============================================================
  List<TenantModel> _tenants = [];
  PaginatedResponse<TenantModel>? _paginatedResponse;
  TenantModel? _currentTenant;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  // Filtros
  String? _nomeFilter;
  String? _statusFilter;
  String? _cnpjFilter;

  // ============================================================
  // 🔍 Getters
  // ============================================================
  List<TenantModel> get tenants => _tenants;
  TenantModel? get currentTenant => _currentTenant;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;
  int get total => _paginatedResponse?.total ?? 0;
  int get currentPage => _currentPage;
  int get totalPages => _paginatedResponse?.pages ?? 0;

  String? get nomeFilter => _nomeFilter;
  String? get statusFilter => _statusFilter;
  String? get cnpjFilter => _cnpjFilter;

  // ============================================================
  // 📊 Tenants Ativos
  // ============================================================
  List<TenantModel> get tenantsAtivos =>
      _tenants.where((t) => t.ativo == true).toList();

  // ============================================================
  // 🏗️ Construtor
  // ============================================================
  TenantProvider(this._tenantRepository);

  // ============================================================
  // 📋 Carregar Tenants
  // ============================================================
  Future<void> loadTenants({
    bool forceRefresh = false,
    String? nome,
    String? status,
    String? cnpj,
    bool? ativo,
  }) async {
    // Atualizar filtros
    _nomeFilter = nome;
    _statusFilter = status;
    _cnpjFilter = cnpj;

    // Resetar paginação
    _currentPage = 1;
    _tenants = [];
    _hasMore = true;

    _setLoading(true);

    try {
      final response = await _tenantRepository.getTenants(
        page: _currentPage,
        limit: 20,
        nome: _nomeFilter,
        status: _statusFilter,
        cnpj: _cnpjFilter,
        forceRefresh: forceRefresh,
      );

      _paginatedResponse = response;
      _tenants = response.data;
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
      final response = await _tenantRepository.getTenants(
        page: nextPage,
        limit: 20,
        nome: _nomeFilter,
        status: _statusFilter,
        cnpj: _cnpjFilter,
      );

      _paginatedResponse = response;
      _tenants.addAll(response.data);
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
  // 🔍 Buscar Tenant por ID
  // ============================================================
  Future<TenantModel?> getTenantById(int id) async {
    try {
      // Tentar encontrar no cache primeiro
      try {
        final cached = _tenants.firstWhere((t) => t.id == id);
        _currentTenant = cached;
        notifyListeners();
        return cached;
      } catch (e) {
        // Não encontrado, buscar da API
        final tenant = await _tenantRepository.getTenantById(id);
        _currentTenant = tenant;
        // Adicionar à lista se não existir
        if (!_tenants.any((t) => t.id == id)) {
          _tenants.insert(0, tenant);
          notifyListeners();
        }
        return tenant;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // ============================================================
  // ➕ Criar Tenant
  // ============================================================
  Future<bool> createTenant(Map<String, dynamic> data) async {
    _setLoading(true);
    _clearError();

    try {
      final tenant = await _tenantRepository.createTenant(data);
      _tenants.insert(0, tenant);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // ============================================================
  // ✏️ Atualizar Tenant
  // ============================================================
  Future<bool> updateTenant(int id, Map<String, dynamic> data) async {
    _setLoading(true);
    _clearError();

    try {
      final tenant = await _tenantRepository.updateTenant(id, data);

      // Atualizar na lista
      final index = _tenants.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tenants[index] = tenant;
      }

      if (_currentTenant?.id == id) {
        _currentTenant = tenant;
      }

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // ============================================================
  // 🗑️ Deletar Tenant
  // ============================================================
  Future<bool> deleteTenant(int id) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _tenantRepository.deleteTenant(id);
      if (success) {
        _tenants.removeWhere((t) => t.id == id);
        if (_currentTenant?.id == id) {
          _currentTenant = null;
        }
      }
      _setLoading(false);
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // ============================================================
  // 🔄 Alterar Status
  // ============================================================
  Future<bool> updateStatus(int id, TenantStatus status) async {
    try {
      final tenant = await _tenantRepository.updateStatus(id, status);

      // Atualizar na lista
      final index = _tenants.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tenants[index] = tenant;
      }

      if (_currentTenant?.id == id) {
        _currentTenant = tenant;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ============================================================
  // 🔄 Refresh
  // ============================================================
  Future<void> refreshTenants() async {
    await loadTenants(
      forceRefresh: true,
      nome: _nomeFilter,
      status: _statusFilter,
      cnpj: _cnpjFilter,
    );
  }

  // ============================================================
  // 🗑️ Limpar Filtros
  // ============================================================
  void clearFilters() {
    _nomeFilter = null;
    _statusFilter = null;
    _cnpjFilter = null;
    notifyListeners();
  }

  // ============================================================
  // 🗑️ Limpar Cache
  // ============================================================
  Future<void> clearCache() async {
    await _tenantRepository.clearCache();
    _tenants = [];
    _paginatedResponse = null;
    _currentTenant = null;
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
}
