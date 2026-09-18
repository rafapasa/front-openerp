import 'package:flutter/material.dart';
import 'package:front_openerp/core/helpers/launch_url.dart';
import 'package:front_openerp/core/helpers/snack_helper.dart';
import 'package:front_openerp/data/models/models.dart';
import 'package:front_openerp/presentation/providers/providers.dart';
import 'package:front_openerp/presentation/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:front_openerp/presentation/pages/pedidos/pagamento_pedido_dialog.dart';

Future<void> showPedidoDetalheModal(BuildContext context, int pedidoId) {
  final isWide = MediaQuery.of(context).size.width >= 720;
  if (isWide) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640, maxHeight: 760),
          child: PedidoDetalheModal(pedidoId: pedidoId),
        ),
      ),
    );
  }
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => SizedBox(
      height: MediaQuery.of(context).size.height * 0.92,
      child: PedidoDetalheModal(pedidoId: pedidoId),
    ),
  );
}

class PedidoDetalheModal extends StatefulWidget {
  final int pedidoId;
  const PedidoDetalheModal({super.key, required this.pedidoId});

  @override
  State<PedidoDetalheModal> createState() => _PedidoDetalheModalState();
}

class _PedidoDetalheModalState extends State<PedidoDetalheModal> {
  PedidoModel? _pedido;
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final provider = context.read<PedidoProvider>();
    final local = provider.pedidos.where((p) => p.id == widget.pedidoId);
    if (local.isNotEmpty) {
      setState(() {
        _pedido = local.first;
        _loading = false;
      });
    }
    final fetched = await provider.getPedidoById(widget.pedidoId);
    if (!mounted) return;
    setState(() {
      _pedido = fetched ?? _pedido;
      _loading = false;
      if (_pedido == null) _error = provider.error ?? 'Pedido não encontrado';
    });
  }

  Future<void> _changeStatus(StatusPedido status, {String? motivo}) async {
    if (_busy || _pedido == null) return;
    setState(() => _busy = true);
    final ok = await context.read<PedidoProvider>().updateStatus(_pedido!.id, status);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      final updated = context.read<PedidoProvider>().pedidos.where((p) => p.id == _pedido!.id);
      setState(() {
        _pedido = (updated.isNotEmpty ? updated.first : _pedido!).copyWith(
          status: status,
          motivoCancelamento: motivo ?? _pedido!.motivoCancelamento,
          updatedAt: DateTime.now(),
        );
      });
      showSavedSnack(context, message: 'Status atualizado');
    } else {
      showSavedSnack(context, message: 'Não foi possível atualizar');
    }
  }

  Future<void> _recusar() async {
    final controller = TextEditingController();
    final motivo = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Recusar pedido'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Motivo (obrigatório)', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              Navigator.pop(ctx, controller.text.trim());
            },
            child: const Text('Recusar'),
          ),
        ],
      ),
    );
    if (motivo == null || motivo.isEmpty) return;
    await _changeStatus(StatusPedido.cancelado, motivo: motivo);
  }

  Future<void> _marcarPago() async {
    if (_pedido == null || _busy) return;
    setState(() => _busy = true);
    final ok = await showPagamentoPedidoDialog(context, _pedido!);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      final atual = context.read<PedidoProvider>().pedidos.where((x) => x.id == _pedido!.id);
      if (atual.isNotEmpty) setState(() => _pedido = atual.first);
    }
  }

  void _ligar() {
    final tel = _digits(_pedido?.clienteTelefone ?? '');
    if (tel.isEmpty) return;
    openExternalUrl('tel:+$tel');
  }

  void _whatsapp() {
    final tel = _digits(_pedido?.clienteTelefone ?? '');
    if (tel.isEmpty) return;
    openExternalUrl('https://wa.me/$tel');
  }

  void _maps() {
    final end = _pedido?.enderecoEntrega?.enderecoCompleto;
    if (end == null || end.isEmpty) return;
    openExternalUrl('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(end)}');
  }

  void _printCupom() {
    final p = _pedido;
    if (p == null) return;
    final money = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final itens = p.itens.map((i) => '<div>${i.quantidade}x ${i.nome} ${money.format(i.subtotal)}</div>').join();
    printHtml('''
<!doctype html><html><head><meta charset="utf-8">
<title>Cupom #${p.id}</title>
<style>
@page { size: 80mm auto; margin: 4mm; }
body { font-family: monospace; font-size: 12px; width: 72mm; }
h1 { font-size: 14px; text-align: center; }
hr { border: none; border-top: 1px dashed #000; }
</style></head><body>
<h1>Pedido #${p.id}</h1>
<div>${p.clienteNome}</div>
<div>${p.clienteTelefone}</div>
<div>${p.enderecoEntrega?.enderecoCompleto ?? ''}</div>
<hr>$itens<hr>
<div><b>TOTAL ${money.format(p.total)}</b></div>
<div>${p.formaPagamentoResumo} · ${p.isPago ? 'PAGO' : 'PENDENTE'}</div>
<div>${p.origemLabel} · ${p.statusLabel}</div>
</body></html>
''');
  }

  String _digits(String raw) => raw.replaceAll(RegExp(r'[^0-9]'), '');

  Color _statusColor(PedidoModel p) => Color(int.parse(p.statusColor.replaceFirst('#', '0xff')));

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          _header(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _error != null
                ? Center(child: Text(_error!))
                : _body(),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    final p = _pedido;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pedido #${widget.pedidoId}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                if (p != null)
                  Text(
                    '${p.totalFormatado} · ${p.origemLabel}',
                    style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                  ),
              ],
            ),
          ),
          if (p != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(p).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                p.statusLabel,
                style: TextStyle(color: _statusColor(p), fontWeight: FontWeight.w700, fontSize: 11),
              ),
            ),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
        ],
      ),
    );
  }

  Widget _body() {
    final p = _pedido!;
    final money = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final date = DateFormat('dd/MM HH:mm');
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionTitle('Cliente'),
        Text(p.clienteNome, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        Text(p.clienteTelefone, style: const TextStyle(color: AppColors.textGrey)),
        if (p.enderecoEntrega != null) ...[
          const SizedBox(height: 4),
          Text(p.enderecoEntrega!.enderecoCompleto, style: const TextStyle(fontSize: 13)),
        ],
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _chipAction(Icons.call, 'Ligar', _ligar),
            _chipAction(Icons.chat, 'WhatsApp', _whatsapp),
            _chipAction(Icons.map_outlined, 'Maps', _maps),
          ],
        ),
        const SizedBox(height: 16),
        _sectionTitle('Itens'),
        ...p.itens.map(
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${i.quantidade}× ${i.nome}${i.observacao != null && i.observacao!.isNotEmpty ? ' (${i.observacao})' : ''}',
                  ),
                ),
                Text(money.format(i.subtotal), style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        if (p.observacoes != null && p.observacoes!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Obs.: ${p.observacoes}', style: const TextStyle(color: AppColors.textGrey)),
        ],
        const SizedBox(height: 16),
        _sectionTitle('Pagamento'),
        Text('${p.formaPagamentoResumo} · ${p.isPago ? 'Pago' : 'Pendente'}'),
        if (!p.isPago)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _busy ? null : _marcarPago,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Marcar como pago'),
            ),
          ),
        const SizedBox(height: 8),
        _sectionTitle('Ações de status'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (p.proximoOperacional != null)
              _actionBtn(p.proximoLabel, () => _changeStatus(p.proximoOperacional!)),
            if (p.isAtivo) _actionBtn('Cancelar', _recusar),
            if (p.podeCancelar)
              OutlinedButton(
                onPressed: _busy ? null : _recusar,
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Recusar'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _sectionTitle('Timeline'),
        if (p.historico.isEmpty) ...[
          Text('Criado ${date.format(p.createdAt)}', style: const TextStyle(fontSize: 13)),
          Text('Atualizado ${date.format(p.updatedAt)} · ${p.statusLabel}', style: const TextStyle(fontSize: 13)),
          if (p.motivoCancelamento != null)
            Text('Motivo: ${p.motivoCancelamento}', style: const TextStyle(fontSize: 13)),
        ] else
          ...p.historico.map(
            (h) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '• ${date.format(h.createdAt)}  ${h.statusNovo}${h.usuarioNome != null ? ' (${h.usuarioNome})' : ''}${h.motivo != null ? ' — ${h.motivo}' : ''}',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _printCupom,
          icon: const Icon(Icons.print_outlined),
          label: const Text('Imprimir cupom 80mm'),
        ),
        if (_busy) const Padding(padding: EdgeInsets.only(top: 12), child: LinearProgressIndicator()),
      ],
    );
  }

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      t.toUpperCase(),
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textGrey, letterSpacing: 0.6),
    ),
  );

  Widget _chipAction(IconData icon, String label, VoidCallback onTap) => ActionChip(
    avatar: Icon(icon, size: 16, color: AppColors.primary),
    label: Text(label),
    onPressed: onTap,
    backgroundColor: AppColors.primaryLight,
  );

  Widget _actionBtn(String label, VoidCallback onTap) =>
      FilledButton(onPressed: _busy ? null : onTap, child: Text(label));
}
