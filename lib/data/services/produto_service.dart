import 'package:front_openerp/data/models/models.dart';

import 'services.dart';

class ProdutoService {
  final ApiService _apiService;

  ProdutoService(this._apiService);

  /// Lista produtos com filtros
  Future<PaginatedResponse<ProdutoModel>> getProdutos({
    int page = 1,
    int limit = 20,
    int? categoriaId,
    bool? disponivel,
    String? nome,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        'categoria_id': ?categoriaId,
        'disponivel': ?disponivel,
        'nome': ?nome,
      };

      final response = await _apiService.get(
        '/produtos',
        queryParameters: queryParams,
      );

      final data = response.data['data'] as Map<String, dynamic>;

      return PaginatedResponse<ProdutoModel>.fromJson(
        data,
        (json) => ProdutoModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Busca produto por ID
  Future<ProdutoModel> getProdutoById(int id) async {
    try {
      final response = await _apiService.get('/produtos/$id');

      final data = response.data['data'] as Map<String, dynamic>;
      return ProdutoModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
}
