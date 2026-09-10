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
  // O backend responde com um LoginResponseList: cada `users[i]` é uma conta
  // do e-mail em um tenant (com token próprio). Retornamos o resultado para o
  // provider decidir se entra direto ou exibe a seleção de empresa.
  Future<LoginResultado> login(String email, String password) async {
    try {
      return await _authService.login(email, password);
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // ▶️ Ativar conta selecionada (token + persistência local)
  // ============================================================
  // Não chama o backend: cada conta do /login já traz o próprio token JWT.
  // Ativar a conta = trocar o token ativo e persistir a sessão localmente.
  Future<UsuarioModel> ativarConta(LoginConta conta) async {
    // Token usado nas próximas chamadas HTTP (ApiService)
    await _authService.ativarConta(conta);
    await LocalStorage.setToken(conta.token);
    await LocalStorage.setTokenExpires(conta.expiresAt);

    // Salvar ID do tenant ativo (usado no header X-Tenant-ID)
    await LocalStorage.saveData('tenant_ativo_id', conta.tenantId);

    // Salvar usuário completo no cache
    final usuario = UsuarioModel.fromLoginConta(conta);
    await LocalStorage.saveData('usuario', usuario.toJson());

    return usuario;
  }

  // ============================================================
  // 💾 Contas disponíveis (login com múltiplas empresas)
  // ============================================================
  Future<void> salvarContas(List<LoginConta> contas) async {
    await LocalStorage.saveData(
      LocalStorage.contasLoginKey,
      contas.map((c) => c.toJson()).toList(),
    );
  }

  Future<List<LoginConta>?> getContas() async {
    final cached =
        LocalStorage.getData<List<dynamic>>(LocalStorage.contasLoginKey);
    if (cached == null) return null;
    try {
      return cached
          .whereType<Map<String, dynamic>>()
          .map(LoginConta.fromJson)
          .toList();
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // 🔄 Selecionar Empresa/Conta
  // ============================================================
  Future<UsuarioModel> selectTenant(int tenantId) async {
    try {
      final contas = await getContas() ?? const <LoginConta>[];
      LoginConta? conta;
      for (final c in contas) {
        if (c.tenantId == tenantId) {
          conta = c;
          break;
        }
      }
      if (conta == null) {
        throw Exception('Conta não encontrada para o tenant $tenantId');
      }
      return await ativarConta(conta);
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // 🔍 Buscar usuário atual
  // ============================================================
  Future<UsuarioModel?> getCurrentUser() async {
    final cached = LocalStorage.getData<Map<String, dynamic>>('usuario');
    if (cached != null) {
      return UsuarioModel.fromJson(cached);
    }
    return null;
  }

  // ============================================================
  // 🚪 Logout
  // ============================================================
  Future<void> logout() async {
    await _authService.logout();
    await LocalStorage.clearToken();
    await LocalStorage.clearCache('usuario');
    await LocalStorage.clearCache('tenant_ativo_id');
    await LocalStorage.clearAll();
  }

  // ============================================================
  // 🔍 Verificar autenticação
  // ============================================================
  bool get isAuthenticated => LocalStorage.hasValidToken();

  bool isTokenExpired() => LocalStorage.isTokenExpired();

  // ============================================================
  // 💾 Restaurar sessão
  // ============================================================
  Future<bool> restoreSession() async {
    final token = LocalStorage.getToken();
    if (token != null && token.isNotEmpty) {
      // Verificar se temos usuário em cache
      final user = await getCurrentUser();
      return user != null;
    }
    return false;
  }
}
