import 'package:flutter/material.dart';
import 'package:front_openerp/data/models/models.dart';
import 'package:front_openerp/presentation/pages/pedidos/pedido_detalhe_modal.dart';
import 'package:front_openerp/presentation/pages/pedidos/pagamento_pedido_dialog.dart';
import 'package:front_openerp/presentation/providers/pedido_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';

const _colunas = <StatusPedido>[
  StatusPedido.pendente,
  StatusPedido.confirmado,
  StatusPedido.emPreparo,
  StatusPedido.prontoRetirada,
  StatusPedido.saiuEntrega,
  StatusPedido.entregue,
  StatusPedido.cancelado,
];

const _transicoes = <StatusPedido, Set<StatusPedido>>{
  StatusPedido.pendente: {StatusPedido.confirmado, StatusPedido.cancelado},
  StatusPedido.confirmado: {StatusPedido.emPreparo, StatusPedido.cancelado},
  StatusPedido.emPreparo: {
    StatusPedido.saiuEntrega,
    StatusPedido.prontoRetirada,
    StatusPedido.cancelado,
  },
  StatusPedido.prontoRetirada: {StatusPedido.entregue, StatusPedido.cancelado},
  StatusPedido.saiuEntrega: {StatusPedido.entregue, StatusPedido.cancelado},
  StatusPedido.entregue: {},
  StatusPedido.cancelado: {},
};

bool _naColuna(PedidoModel p, StatusPedido col) => p.status == col;

bool _aceitaDrop(PedidoModel p, StatusPedido dest) {
  if (_naColuna(p, dest)) return false;
  if (dest == StatusPedido.saiuEntrega && !p.isEntrega) return false;
  if (dest == StatusPedido.prontoRetirada && p.isEntrega) return false;
  return _transicoes[p.status]?.contains(dest) ?? false;
}

class PedidosKanban extends StatelessWidget {
  const PedidosKanban({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PedidoProvider>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _colunas.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: _Coluna(
                status: _colunas[i],
                pedidos: provider.pedidos.where((p) => _naColuna(p, _colunas[i])).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Coluna extends StatelessWidget {
  final StatusPedido status;
  final List<PedidoModel> pedidos;
  const _Coluna({required this.status, required this.pedidos});

  Future<void> _receber(BuildContext context, PedidoModel pedido) async {
    if (!_aceitaDrop(pedido, status)) return;
    String? motivo;
    if (status == StatusPedido.cancelado) {
      final ctrl = TextEditingController();
      motivo = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Cancelar pedido'),
          content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Motivo'), autofocus: true),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Voltar')),
            FilledButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: const Text('Cancelar pedido')),
          ],
        ),
      );
      if (motivo == null) return;
    }
    final ok = await context.read<PedidoProvider>().updateStatus(pedido.id, status, motivo: motivo);
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<PedidoProvider>().error ?? 'Nao foi possivel mover o pedido')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<PedidoModel>(
      onWillAcceptWithDetails: (d) => _aceitaDrop(d.data, status),
      onAcceptWithDetails: (d) => _receber(context, d.data),
      builder: (context, candidate, rejected) {
        final overOk = candidate.isNotEmpty;
        final blocked = rejected.isNotEmpty && !overOk;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: blocked
                ? const Color(0xFFE8EAED)
                : overOk
                    ? AppColors.accent.withValues(alpha: 0.08)
                    : const Color(0xFFF4F6F8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: overOk ? AppColors.accent : AppColors.border,
              width: overOk ? 2 : 1,
            ),
          ),
          child: Opacity(
            opacity: blocked ? 0.45 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          status.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                      ),
                      Text('${pedidos.length}', style: const TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    itemCount: pedidos.isEmpty ? 1 : pedidos.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      if (pedidos.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text('Solte aqui', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                        );
                      }
                      return _CardKanban(pedido: pedidos[i]);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CardKanban extends StatelessWidget {
  final PedidoModel pedido;
  const _CardKanban({required this.pedido});

  Widget _corpo(BuildContext context, {required bool dragging}) {
    final money = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final next = pedido.proximoOperacional;
    final entrega = pedido.enderecoEntregaId != null || pedido.enderecoEntrega != null;
    return Material(
      elevation: dragging ? 8 : 0,
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: dragging ? null : () => showPedidoDetalheModal(context, pedido.id),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.drag_indicator, size: 16, color: AppColors.textGrey),
                  const SizedBox(width: 4),
                  Text('#${pedido.id}', style: const TextStyle(fontWeight: FontWeight.w800)),
                  const Spacer(),
                  Text(money.format(pedido.total), style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                (pedido.etiqueta != null && pedido.etiqueta!.trim().isNotEmpty) ? pedido.etiqueta! : pedido.clienteNome,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: (pedido.etiqueta != null && pedido.etiqueta!.trim().isNotEmpty) ? FontWeight.w800 : FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                children: [
                  _chip(entrega ? 'Entrega' : 'Retirada', AppColors.primary),
                  _chip(pedido.isPago ? 'Pago' : 'Em aberto', pedido.isPago ? Colors.green : const Color(0xFFF59E0B)),
                ],
              ),
              if (!dragging) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (!pedido.isPago && pedido.status != StatusPedido.cancelado)
                      TextButton(onPressed: () => showPagamentoPedidoDialog(context, pedido), child: const Text('Pago')),
                    const Spacer(),
                    if (next != null)
                      FilledButton(
                        onPressed: () => context.read<PedidoProvider>().updateStatus(pedido.id, next),
                        style: FilledButton.styleFrom(backgroundColor: AppColors.accent, visualDensity: VisualDensity.compact),
                        child: Text(pedido.proximoLabel),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Draggable<PedidoModel>(
      data: pedido,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: SizedBox(width: 220, child: _corpo(context, dragging: true)),
      childWhenDragging: Opacity(opacity: 0.35, child: _corpo(context, dragging: false)),
      child: _corpo(context, dragging: false),
    );
  }

  Widget _chip(String t, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(t, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c)),
    );
  }
}
