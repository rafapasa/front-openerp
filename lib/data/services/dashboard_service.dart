import 'package:front_openerp/data/models/models.dart';

import 'services.dart';

class DashboardService {
  final ApiService _apiService;

  DashboardService(this._apiService);

  /// Busca dados do dashboard
  Future<DashboardModel> getDashboard() async {
    try {
      final response = await _apiService.get('/dashboard');

      // final data = response.data['data'] as Map<String, dynamic>;
      Map<String, dynamic> data = {for (var item in response.data) ...?item};

      return DashboardModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
}
