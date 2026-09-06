// lib/data/services/auth_service.dart
import 'package:dio/dio.dart';
import 'package:front_openerp/data/models/models.dart';
import 'package:front_openerp/data/services/api_service.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  // ============================================================
  // 🔐 Login
  // ============================================================
  // O backend responde com um LoginResponseList:
  // {
  //   "count": N,
  //   "users": [
  //     { "token": "...", "user": {...}, "expires_at": "..." },
  //     ...
  //   ]
  // }
  // Cada item representa uma conta do e-mail em um tenant, com token próprio.
  Future<LoginResultado> login(String email, String password) async {
    try {
      final response = await _apiService.post('/login', data: {'email': email, 'password': password});

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Resposta de login inválida');
      }

      final resultado = LoginResultado.fromJson(data);
      if (resultado.contas.isEmpty) {
        throw Exception('Credenciais inválidas');
      }
      return resultado;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Credenciais inválidas');
      }
      rethrow;
    }
  }

  // ============================================================
  // ▶️ Ativar conta selecionada (define token/expiração no ApiService)
  // ============================================================
  // Não faz requisição ao backend: cada conta do /login já possui o seu
  // próprio token JWT. Ativar a conta = passar a usar esse token.
  Future<void> ativarConta(LoginConta conta) async {
    await _apiService.setToken(conta.token);
    await _apiService.setTokenExpires(conta.expiresAt);
  }

  // ============================================================
  // 🚪 Logout
  // ============================================================
  Future<void> logout() async {
    await _apiService.logout();
  }

  // ============================================================
  // 🔍 Verificar autenticação
  // ============================================================
  bool get isAuthenticated => _apiService.isAuthenticated;
}
