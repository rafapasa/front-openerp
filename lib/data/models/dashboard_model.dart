class DashboardModel {
  final int totalPedidosHoje;
  final int totalPedidosSemana;
  final int totalClientes;
  final int pedidosPendentes;
  final Map<String, int> pedidosPorStatus;
  final double faturamentoHoje;
  final double faturamentoMes;

  DashboardModel({
    required this.totalPedidosHoje,
    required this.totalPedidosSemana,
    required this.totalClientes,
    required this.pedidosPendentes,
    required this.pedidosPorStatus,
    required this.faturamentoHoje,
    required this.faturamentoMes,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalPedidosHoje: json['total_pedidos_hoje'] ?? 0,
      totalPedidosSemana: json['total_pedidos_semana'] ?? 0,
      totalClientes: json['total_clientes'] ?? 0,
      pedidosPendentes: json['pedidos_pendentes'] ?? 0,
      pedidosPorStatus: Map<String, int>.from(json['pedidos_por_status'] ?? {}),
      faturamentoHoje: (json['faturamento_hoje'] ?? 0).toDouble(),
      faturamentoMes: (json['faturamento_mes'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'total_pedidos_hoje': totalPedidosHoje,
    'total_pedidos_semana': totalPedidosSemana,
    'total_clientes': totalClientes,
    'pedidos_pendentes': pedidosPendentes,
    'pedidos_por_status': pedidosPorStatus,
    'faturamento_hoje': faturamentoHoje,
    'faturamento_mes': faturamentoMes,
  };
}
