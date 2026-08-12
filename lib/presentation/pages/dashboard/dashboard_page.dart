// lib/presentation/pages/dashboard/dashboard_page.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:front_openerp/data/models/models.dart';
import 'package:front_openerp/presentation/providers/providers.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<DashboardProvider>();
    await provider.loadDashboard();
  }

  Future<void> _refreshData() async {
    final provider = context.read<DashboardProvider>();
    await provider.refreshDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: provider.isRefreshing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            onPressed: provider.isRefreshing ? null : _refreshData,
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar dados',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cards de métricas
                    _buildMetricCards(provider),
                    const SizedBox(height: 24),

                    // Gráfico de Status
                    _buildStatusChart(provider),
                    const SizedBox(height: 24),

                    // Gráfico de Faturamento (placeholder)
                    _buildRevenueCard(provider),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMetricCards(DashboardProvider provider) {
    final numberFormat = NumberFormat.decimalPattern('pt_BR');

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _MetricCard(
          title: 'Pedidos Hoje',
          value: provider.totalPedidosHoje.toString(),
          icon: Icons.shopping_cart,
          color: Colors.blue,
        ),
        _MetricCard(
          title: 'Faturamento Hoje',
          value: 'R\$ ${numberFormat.format(provider.faturamentoHoje)}',
          icon: Icons.attach_money,
          color: Colors.green,
        ),
        _MetricCard(
          title: 'Clientes',
          value: provider.totalClientes.toString(),
          icon: Icons.people,
          color: Colors.purple,
        ),
        _MetricCard(
          title: 'Pendentes',
          value: provider.pedidosPendentes.toString(),
          icon: Icons.pending,
          color: Colors.orange,
        ),
        _MetricCard(
          title: 'Faturamento Mês',
          value: 'R\$ ${numberFormat.format(provider.faturamentoMes)}',
          icon: Icons.trending_up,
          color: Colors.teal,
        ),
        _MetricCard(
          title: 'Taxa Conversão',
          value: '${provider.taxaConversao.toStringAsFixed(1)}%',
          icon: Icons.percent,
          color: Colors.indigo,
        ),
      ],
    );
  }

  Widget _buildStatusChart(DashboardProvider provider) {
    final statusData = provider.pedidosPorStatus;

    if (statusData.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'Sem dados de pedidos por status',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    // Mapear cores por status
    final colors = {
      'pendente': Colors.orange,
      'confirmado': Colors.blue,
      'preparando': Colors.purple,
      'entregue': Colors.green,
      'cancelado': Colors.red,
    };

    final entries = statusData.entries.toList();
    final total = entries.fold(0, (sum, e) => sum + e.value);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Pedidos por Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: $total pedidos',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            // Gráfico de pizza
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: entries.map((entry) {
                    final status = StatusPedido.fromString(entry.key);
                    return PieChartSectionData(
                      value: entry.value.toDouble(),
                      title: '${status.label}\n${entry.value}',
                      color: colors[entry.key] ?? Colors.grey,
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 30,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Legenda
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: entries.map((entry) {
                final status = StatusPedido.fromString(entry.key);
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (colors[entry.key] ?? Colors.grey).withValues(),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors[entry.key] ?? Colors.grey,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${status.label}: ${entry.value}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors[entry.key] ?? Colors.grey,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueCard(DashboardProvider provider) {
    final numberFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💰 Faturamento',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _RevenueItem(
                    label: 'Hoje',
                    value: numberFormat.format(provider.faturamentoHoje),
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _RevenueItem(
                    label: 'Mês',
                    value: numberFormat.format(provider.faturamentoMes),
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Barra de progresso do mês
            LinearProgressIndicator(
              value: provider.faturamentoMes > 0
                  ? (provider.faturamentoHoje / provider.faturamentoMes).clamp(
                      0,
                      1,
                    )
                  : 0,
              backgroundColor: Colors.grey[200],
              color: Colors.green,
              minHeight: 8,
            ),
            const SizedBox(height: 4),
            Text(
              '${((provider.faturamentoHoje / provider.faturamentoMes) * 100).toStringAsFixed(1)}% do faturamento mensal',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

// Widgets auxiliares
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenueItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _RevenueItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }
}
