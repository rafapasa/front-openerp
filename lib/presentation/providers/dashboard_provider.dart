// lib/presentation/providers/dashboard_provider.dart
import 'package:flutter/material.dart';
import 'package:front_openerp/data/models/models.dart';
import 'package:front_openerp/data/repositories/repositories.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardRepository _dashboardRepository;

  // ============================================================
  // 📊 Estado
  // ============================================================
  DashboardModel? _dashboard;
  bool _isLoading = false;
  String? _error;
  bool _isRefreshing = false;

  // ============================================================
  // 🔍 Getters
  // ============================================================
  DashboardModel? get dashboard => _dashboard;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;

  // ============================================================
  // 📈 Métricas Auxiliares
  // ============================================================
  int get totalPedidosHoje => _dashboard?.totalPedidosHoje ?? 0;
  int get totalPedidosSemana => _dashboard?.totalPedidosSemana ?? 0;
  int get totalClientes => _dashboard?.totalClientes ?? 0;
  int get pedidosPendentes => _dashboard?.pedidosPendentes ?? 0;
  double get faturamentoHoje => _dashboard?.faturamentoHoje ?? 0;
  double get faturamentoMes => _dashboard?.faturamentoMes ?? 0;

  Map<String, int> get pedidosPorStatus => _dashboard?.pedidosPorStatus ?? {};

  double get taxaConversao {
    if (totalPedidosHoje == 0) return 0;
    final total = pedidosPorStatus.values.fold(0, (sum, value) => sum + value);
    if (total == 0) return 0;
    final entregues =
        pedidosPorStatus[StatusPedido.entregue.toStringValue()] ?? 0;
    return (entregues / total) * 100;
  }

  // ============================================================
  // 🏗️ Construtor
  // ============================================================
  DashboardProvider(this._dashboardRepository);

  // ============================================================
  // 📊 Carregar Dashboard
  // ============================================================
  Future<void> loadDashboard({bool forceRefresh = false}) async {
    if (!forceRefresh && _dashboard != null) {
      return; // Já tem dados
    }

    _setLoading(true);

    try {
      _dashboard = await _dashboardRepository.getDashboard(
        forceRefresh: forceRefresh,
      );
      _clearError();
    } catch (e) {
      _error = e.toString();
    }

    _setLoading(false);
  }

  // ============================================================
  // 🔄 Refresh
  // ============================================================
  Future<void> refreshDashboard() async {
    if (_isRefreshing) return;

    _isRefreshing = true;
    notifyListeners();

    try {
      _dashboard = await _dashboardRepository.refreshDashboard();
      _clearError();
    } catch (e) {
      _error = e.toString();
    }

    _isRefreshing = false;
    notifyListeners();
  }

  // ============================================================
  // 🗑️ Limpar Cache
  // ============================================================
  Future<void> clearCache() async {
    await _dashboardRepository.clearCache();
    _dashboard = null;
    notifyListeners();
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
