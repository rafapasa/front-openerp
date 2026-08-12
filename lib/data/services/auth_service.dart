import 'package:dio/dio.dart';
import 'package:front_openerp/data/models/models.dart';

import 'services.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  /// Faz login do usuário
  Future<UsuarioModel> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data['data'];

      // Extrair token e usuário
      final token = data['token'] as String;
      final userData = data['user'] as Map<String, dynamic>;

      // Salvar token no ApiService
      await _apiService.setToken(token);

      // Retornar usuário com token
      return UsuarioModel(
        id: userData['id'],
        email: userData['email'],
        token: token,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Credenciais inválidas');
      }
      rethrow;
    }
  }

  /// Faz logout
  Future<void> logout() async {
    await _apiService.logout();
  }

  /// Verifica se está autenticado
  bool get isAuthenticated => _apiService.isAuthenticated;
}
