// lib/data/repositories/auth_repository.dart
import 'package:front_openerp/data/models/models.dart';
import 'package:front_openerp/data/repositories/local_storage.dart';
import 'package:front_openerp/data/services/services.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  // ============================================================
  // 🔐 Login
  // ============================================================
  Future<UsuarioModel> login(String email, String password) async {
    try {
      final user = await _authService.login(email, password);

      // Salvar token localmente
      if (user.token != null) {
        await LocalStorage.setToken(user.token!);
      }

      return user;
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // 🚪 Logout
  // ============================================================
  Future<void> logout() async {
    await _authService.logout();
    await LocalStorage.clearToken();
    await LocalStorage.clearAll(); // Limpar todo o cache
  }

  // ============================================================
  // 🔍 Verificar autenticação
  // ============================================================
  bool get isAuthenticated {
    final token = LocalStorage.getToken();
    return token != null && token.isNotEmpty;
  }

  // ============================================================
  // 📥 Token
  // ============================================================
  String? getToken() {
    return LocalStorage.getToken();
  }

  // ============================================================
  // 💾 Restaurar sessão
  // ============================================================
  Future<bool> restoreSession() async {
    final token = LocalStorage.getToken();
    if (token != null && token.isNotEmpty) {
      // Tentar validar token com API
      // Por enquanto, apenas retornar true se tiver token
      return true;
    }
    return false;
  }
}
