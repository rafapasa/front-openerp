import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8081/api/v1';

  late final Dio _dio;
  String? _token;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptor para log (útil para debug)
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
        ),
      );
    }

    // Interceptor para adicionar token automaticamente
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Carregar token do SharedPreferences
          if (_token == null) {
            final prefs = await SharedPreferences.getInstance();
            _token = prefs.getString('auth_token');
          }

          // Adicionar token no header se existir
          if (_token != null && !options.path.contains('/login')) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Se token expirou (401), tentar renovar
          if (error.response?.statusCode == 401) {
            // TODO: Implementar refresh token
            // Por enquanto, apenas limpar token
            await _clearToken();
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Getters
  Dio get dio => _dio;

  // Gerenciar token
  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<void> logout() async {
    await _clearToken();
  }

  // Métodos genéricos para requisições
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Tratamento de erros
  Exception _handleError(DioException error) {
    String message = 'Ocorreu um erro inesperado';

    if (error.response != null) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      switch (statusCode) {
        case 400:
          message = data?['error'] ?? 'Dados inválidos';
          break;
        case 401:
          message = 'Sessão expirada. Faça login novamente.';
          break;
        case 403:
          message = 'Você não tem permissão para acessar este recurso';
          break;
        case 404:
          message = 'Recurso não encontrado';
          break;
        case 500:
          message = 'Erro no servidor. Tente novamente mais tarde.';
          break;
        default:
          message = data?['error'] ?? data?['message'] ?? message;
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      message = 'Tempo de conexão esgotado. Verifique sua internet.';
    } else if (error.type == DioExceptionType.connectionError) {
      message = 'Erro de conexão. Verifique sua internet.';
    }

    return Exception(message);
  }

  // Verificar se está autenticado
  bool get isAuthenticated => _token != null;
}
