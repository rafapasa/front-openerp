// lib/presentation/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:front_openerp/data/models/models.dart';
import 'package:front_openerp/data/models/tenant_model.dart';
import 'package:front_openerp/data/repositories/repositories.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  // ============================================================
  // 📊 Estado
  // ============================================================
  UsuarioModel? _usuario;
  List<LoginConta> _contas = []; // Contas retornadas no /login (por tenant)
  bool _isLoading = false;
  String? _error;
  bool _tenantSelecionado = false;

  // ============================================================
  // 🔍 Getters
  // ============================================================
  UsuarioModel? get usuario => _usuario;
  List<LoginConta> get contas => _contas;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _authRepository.isAuthenticated;

  // Getters específicos para a seleção de empresa (multi-tenant)
  bool get hasMultipleTenants =>
      _contas.length > 1 || (_usuario?.tenants?.length ?? 0) > 1;
  bool get precisaSelecionarConta => hasMultipleTenants && !_tenantSelecionado;
  bool get tenantSelecionado => _tenantSelecionado;
  List<TenantModel>? get tenants => _usuario?.tenants;
  TenantModel? get tenantAtivo => _usuario?.tenantAtivo;

  // ============================================================
  // 🏗️ Construtor
  // ============================================================
  AuthProvider(this._authRepository) {
    _init();
  }

  // ============================================================
  // 🚀 Inicialização
  // ============================================================
  Future<void> _init() async {
    await restoreSession();
  }

  // ============================================================
  // 🔐 Login
  // ============================================================
  // O backend responde com um LoginResponseList. Se houver apenas uma conta,
  // ativa direto; se houver várias (mesmo e-mail em várias empresas), mantém
  // as contas/tokens e aguarda o usuário escolher na tela "Selecionar Empresa".
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    _tenantSelecionado = false;
    _contas = [];

    try {
      final resultado = await _authRepository.login(email, password);
      _contas = resultado.contas;

      if (resultado.contas.length == 1) {
        // Uma única conta: ativa e entra direto.
        _usuario = await _authRepository.ativarConta(resultado.contas.first);
        _tenantSelecionado = true;
      } else {
        // Várias contas: persiste e aguarda a seleção de empresa.
        await _authRepository.salvarContas(resultado.contas);
        _usuario = null;
        _tenantSelecionado = false;
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
  // 🔄 Selecionar Empresa/Conta
  // ============================================================
  Future<bool> selectTenant(int tenantId) async {
    _setLoading(true);
    _clearError();

    try {
      _usuario = await _authRepository.selectTenant(tenantId);
      _tenantSelecionado = true;
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
  // 🚪 Logout
  // ============================================================
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authRepository.logout();
      _usuario = null;
      _contas = [];
      _tenantSelecionado = false;
      _clearError();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
    }
  }

  // ============================================================
  // 💾 Restaurar Sessão
  // ============================================================
  Future<bool> restoreSession() async {
    _setLoading(true);
    try {
      final restored = await _authRepository.restoreSession();
      if (restored) {
        // Buscar usuário ativo (com a conta selecionada)
        final user = await _authRepository.getCurrentUser();
        _usuario = user;

        // Contas disponíveis (caso ainda haja múltiplas empresas em aberto)
        final contas = await _authRepository.getContas();
        _contas = contas ?? const [];

        _tenantSelecionado = user?.tenantAtivoId != null;
      }
      _setLoading(false);
      notifyListeners();
      return restored;
    } catch (e) {
      _setLoading(false);
      notifyListeners();
      return false;
    }
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
}

