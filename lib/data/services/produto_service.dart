import 'package:front_openerp/core/helpers/json_helper.dart';
import 'package:front_openerp/data/models/models.dart';

import 'services.dart';

class ProdutoService {
  final ApiService _apiService;
  ProdutoService(this._apiService);

  Future<PaginatedResponse<ProdutoModel>> getProdutos({
    int page = 1,
    int limit = 20,
    int? categoriaId,
    bool? disponivel,
    String? nome,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (categoriaId != null) 'categoria_id': categoriaId,
      if (disponivel != null) 'disponivel': disponivel,
      if (nome != null && nome.isNotEmpty) 'nome': nome,
    };

    final response = await _apiService.get('/produtos', queryParameters: queryParams);
    final paginated = JsonHelper.extractPaginated(response.data);
    return PaginatedResponse<ProdutoModel>.fromJson(
      paginated,
      (json) => ProdutoModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ProdutoModel> getProdutoById(int id) async {
    final response = await _apiService.get('/produtos/$id');
    final Map<String, dynamic> data = response.data is Map<String, dynamic>
        ? (response.data['data'] as Map<String, dynamic>? ?? response.data as Map<String, dynamic>)
        : {};
    return ProdutoModel.fromJson(data);
  }
}
