import 'package:front_openerp/core/helpers/json_helper.dart';
import 'package:front_openerp/data/models/models.dart';

import 'services.dart';

class DashboardService {
  final ApiService _apiService;

  DashboardService(this._apiService);

  String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<DashboardModel> getDashboard({DateTime? dataInicio, DateTime? dataFim}) async {
    final query = <String, dynamic>{
      if (dataInicio != null) 'data_inicio': _ymd(dataInicio),
      if (dataFim != null) 'data_fim': _ymd(dataFim),
    };

    final response = await _apiService.get('/dashboard', queryParameters: query.isEmpty ? null : query);
    final extracted = JsonHelper.extractData(response.data);
    final map = extracted is Map<String, dynamic>
        ? extracted
        : (response.data is Map<String, dynamic> ? response.data as Map<String, dynamic> : <String, dynamic>{});

    var dashboard = DashboardModel.fromJson(map);

    try {
      final pedidosRes = await _apiService.get('/pedidos', queryParameters: {
        'page': 1,
        'limit': 100,
        ...query,
      });
      final lista = JsonHelper.extractList(pedidosRes.data);
      if (lista.isNotEmpty) {
        final status = <String, int>{};
        var faturamento = 0.0;
        for (final raw in lista) {
          if (raw is! Map) continue;
          final item = Map<String, dynamic>.from(raw);
          final st = '${item['status'] ?? 'pendente'}';
          status[st] = (status[st] ?? 0) + 1;
          final total = item['total'];
          if (total is num) faturamento += total.toDouble();
        }
        dashboard = dashboard.copyWith(
          totalPedidosHoje: lista.length,
          faturamentoHoje: faturamento,
          pedidosPendentes: status['pendente'] ?? 0,
          pedidosPorStatus: status.isEmpty ? dashboard.pedidosPorStatus : status,
        );
      }
    } catch (_) {}

    return dashboard;
  }
}
