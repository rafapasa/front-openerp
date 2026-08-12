// lib/data/repositories/dashboard_repository.dart
import 'package:front_openerp/data/models/models.dart';
import 'package:front_openerp/data/repositories/local_storage.dart';
import 'package:front_openerp/data/services/services.dart';

class DashboardRepository {
  final DashboardService _dashboardService;

  DashboardRepository(this._dashboardService);

  // ============================================================
  // 📊 Buscar Dashboard (com cache)
  // ============================================================
  Future<DashboardModel> getDashboard({bool forceRefresh = false}) async {
    // Verificar se tem cache válido
    if (!forceRefresh && LocalStorage.isCacheValid(LocalStorage.dashboardKey)) {
      final cached = LocalStorage.getData<Map<String, dynamic>>(
        LocalStorage.dashboardKey,
      );
      if (cached != null) {
        return DashboardModel.fromJson(cached);
      }
    }

    // Buscar da API
    try {
      final dashboard = await _dashboardService.getDashboard();

      // Salvar no cache
      await LocalStorage.saveData(
        LocalStorage.dashboardKey,
        dashboard.toJson(),
      );

      return dashboard;
    } catch (e) {
      // Se falhou e tem cache antigo, usar mesmo assim
      final cached = LocalStorage.getData<Map<String, dynamic>>(
        LocalStorage.dashboardKey,
      );
      if (cached != null) {
        return DashboardModel.fromJson(cached);
      }
      rethrow;
    }
  }

  // ============================================================
  // 🔄 Forçar atualização
  // ============================================================
  Future<DashboardModel> refreshDashboard() async {
    return getDashboard(forceRefresh: true);
  }

  // ============================================================
  // 🗑️ Limpar cache
  // ============================================================
  Future<void> clearCache() async {
    await LocalStorage.clearCache(LocalStorage.dashboardKey);
  }
}
