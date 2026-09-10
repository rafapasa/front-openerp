// lib/presentation/pages/pedidos/pedidos_page.dart
// Refatorado eTools - Responsivo
import 'package:flutter/material.dart';
import 'package:front_openerp/data/models/models.dart';
import 'package:front_openerp/presentation/pages/pedidos/pedido_detalhe_modal.dart';
import 'package:front_openerp/presentation/providers/providers.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class PedidosPage extends StatefulWidget {
  const PedidosPage({super.key});

  @override
  State<PedidosPage> createState() => _PedidosPageState();
}

class _PedidosPageState extends State<PedidosPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async => await context.read<PedidoProvider>().loadPedidos();

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      final provider = context.read<PedidoProvider>();
      if (!provider.isLoadingMore && provider.hasMore) provider.loadMore();
    }
  }

  Future<void> _refreshData() async => await context.read<PedidoProvider>().refreshPedidos();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PedidoProvider>();
    final isWeb = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: EdgeInsets.all(isWeb ? 24 : 0),
        child: Column(
          children: [
            // Toolbar
            Container(
              padding: EdgeInsets.all(isWeb ? 16 : 12),
              decoration: isWeb ? AppTheme.cardDecoration : const BoxDecoration(color: Colors.white),
              child: Row(
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 18, color: AppColors.textGrey),
                  const SizedBox(width: 8),
                  Text(
                    '${provider.pedidos.length} pedidos',
                    style: const TextStyle(color: AppColors.textGrey, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    icon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.filter_list, size: 16),
                          SizedBox(width: 6),
                          Text('Filtrar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    onSelected: (status) {
                      if (status == 'todos') {
                        provider.clearFilters();
                      } else {
                        provider.loadPedidos(status: status);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'todos', child: Text('Todos')),
                      const PopupMenuItem(value: 'pendente', child: Text('Pendentes')),
                      const PopupMenuItem(value: 'confirmado', child: Text('Confirmados')),
                      const PopupMenuItem(value: 'em_preparo', child: Text('Em preparo')),
                      const PopupMenuItem(value: 'pronto', child: Text('Prontos')),
                      const PopupMenuItem(value: 'saiu_entrega', child: Text('Saiu p/ entrega')),
                      const PopupMenuItem(value: 'entregue', child: Text('Entregues')),
                      const PopupMenuItem(value: 'cancelado', child: Text('Cancelados')),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : provider.error != null
                  ? _buildError(provider.error!, context)
                  : provider.pedidos.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _refreshData,
                      child: isWeb ? _buildWebTable(provider) : _buildMobileList(provider),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String error, BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 64, color: AppColors.error),
        const SizedBox(height: 16),
        Text('Erro ao carregar pedidos', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          error,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textGrey),
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: _loadData, child: const Text('Tentar novamente')),
      ],
    ),
  );

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text('Nenhum pedido encontrado', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
      ],
    ),
  );

  Widget _buildMobileList(PedidoProvider provider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: provider.pedidos.length + (provider.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.pedidos.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        return _PedidoCard(pedido: provider.pedidos[index]);
      },
    );
  }

  Widget _buildWebTable(PedidoProvider provider) {
    final numberFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFormat = DateFormat('dd/MM HH:mm');

    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    'PEDIDO',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textGrey),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'CLIENTE',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textGrey),
                  ),
                ),
                Expanded(
                  child: Text(
                    'DATA',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textGrey),
                  ),
                ),
                Expanded(
                  child: Text(
                    'ORIGEM',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textGrey),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    'STATUS',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textGrey),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    'TOTAL',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textGrey),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              itemCount: provider.pedidos.length,
              separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.borderLight),
              itemBuilder: (context, index) {
                final pedido = provider.pedidos[index];
                return InkWell(
                  onTap: () => showPedidoDetalheModal(context, pedido.id),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(
                            '#${pedido.id}',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            pedido.clienteNome,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            dateFormat.format(pedido.createdAt),
                            style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              pedido.origemLabel,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color(int.parse(pedido.statusColor.replaceFirst('#', '0xff')))
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              pedido.statusLabel,
                              style: TextStyle(
                                color: Color(int.parse(pedido.statusColor.replaceFirst('#', '0xff'))),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: Text(
                            numberFormat.format(pedido.total),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: AppColors.textDark,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PedidoCard extends StatelessWidget {
  final PedidoModel pedido;
  const _PedidoCard({required this.pedido});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final numberFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration,
      child: InkWell(
        onTap: () => showPedidoDetalheModal(context, pedido.id),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Color(int.parse(pedido.statusColor.replaceFirst('#', '0xff'))),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('#${pedido.id}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Color(int.parse(pedido.statusColor.replaceFirst('#', '0xff'))).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      pedido.statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(int.parse(pedido.statusColor.replaceFirst('#', '0xff'))),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    dateFormat.format(pedido.createdAt),
                    style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(pedido.clienteNome, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                '${pedido.itens.length} itens • ${pedido.origemLabel}',
                style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      pedido.origemLabel,
                      style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    numberFormat.format(pedido.total),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
