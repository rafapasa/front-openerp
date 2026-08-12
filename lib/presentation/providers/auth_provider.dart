// lib/presentation/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:front_openerp/data/models/models.dart';
import 'package:front_openerp/data/repositories/repositories.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  // ============================================================
  // 📊 Estado
  // ============================================================
  UsuarioModel? _usuario;
  bool _isLoading = false;
  String? _error;

  // ============================================================
  // 🔍 Getters
  // ============================================================
  UsuarioModel? get usuario => _usuario;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _authRepository.isAuthenticated;

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
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      _usuario = await _authRepository.login(email, password);
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
        // Buscar dados do usuário (se tiver endpoint)
        // Por enquanto, apenas marcar como autenticado
        _usuario = UsuarioModel(
          id: 0,
          email: 'usuario@email.com',
          nome: 'Usuário',
        );
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

  // ============================================================
  // 🗑️ Dispose
  // ============================================================
  @override
  void dispose() {
    super.dispose();
  }
}
