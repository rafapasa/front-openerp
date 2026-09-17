import 'package:flutter/material.dart';
import 'package:front_openerp/data/models/models.dart';
import 'package:front_openerp/presentation/providers/providers.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';

Future<void> showNovoPedidoModal(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const NovoPedidoModal(),
  );
}

class NovoPedidoModal extends StatefulWidget {
  const NovoPedidoModal({super.key});

  @override
  State<NovoPedidoModal> createState() => _NovoPedidoModalState();
}

class _LinhaItem {
  ProdutoModel? produto;
  int quantidade = 1;
}

class _NovoPedidoModalState extends State<NovoPedidoModal> {
  ClienteModel? _cliente;
  final _obs = TextEditingController();
  final _linhas = <_LinhaItem>[_LinhaItem()];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClienteProvider>().loadClientes();
      context.read<ProdutoProvider>().loadProdutos(disponivel: true);
    });
  }

  @override
  void dispose() {
    _obs.dispose();
    super.dispose();
  }

  double get _total {
    var t = 0.0;
    for (final l in _linhas) {
      if (l.produto != null) t += l.produto!.preco * l.quantidade;
    }
    return t;
  }

  Future<void> _criar() async {
    if (_cliente == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione um cliente')));
      return;
    }
    final itens = <Map<String, dynamic>>[];
    for (final l in _linhas) {
      final p = l.produto;
      if (p == null || l.quantidade < 1) continue;
      itens.add({
        'produto_id': p.id,
        'nome': p.nome,
        'quantidade': l.quantidade,
        'preco': p.preco,
      });
    }
    if (itens.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Adicione ao menos um produto')));
      return;
    }
    setState(() => _saving = true);
    final criado = await context.read<PedidoProvider>().createPedido(
          clienteId: _cliente!.id,
          clienteNome: _cliente!.nome,
          clienteTelefone: _cliente!.telefone,
          itens: itens,
          observacoes: _obs.text,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (criado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<PedidoProvider>().error ?? 'Falha ao criar pedido')),
      );
      return;
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pedido #${criado.id} criado'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
    context.read<DashboardProvider>().refreshDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final clientes = context.watch<ClienteProvider>().clientes;
    final produtos = context.watch<ProdutoProvider>().produtos.where((p) => p.disponivel).toList();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(child: Text('Novo pedido', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
                  IconButton(onPressed: _saving ? null : () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ClienteModel>(
                value: _cliente,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Cliente'),
                items: clientes
                    .map((c) => DropdownMenuItem(value: c, child: Text('${c.nome}  ${c.telefone}')))
                    .toList(),
                onChanged: _saving ? null : (v) => setState(() => _cliente = v),
              ),
              const SizedBox(height: 16),
              const Text('Itens', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _linhas.length,
                  itemBuilder: (_, i) {
                    final linha = _linhas[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: DropdownButtonFormField<ProdutoModel>(
                              value: linha.produto,
                              isExpanded: true,
                              decoration: const InputDecoration(labelText: 'Produto'),
                              items: produtos
                                  .map((p) => DropdownMenuItem(value: p, child: Text('${p.nome}  ${p.precoFormatado}')))
                                  .toList(),
                              onChanged: _saving
                                  ? null
                                  : (v) => setState(() => linha.produto = v),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 72,
                            child: TextFormField(
                              initialValue: '${linha.quantidade}',
                              decoration: const InputDecoration(labelText: 'Qtd'),
                              keyboardType: TextInputType.number,
                              enabled: !_saving,
                              onChanged: (v) => setState(() => linha.quantidade = int.tryParse(v) ?? 1),
                            ),
                          ),
                          IconButton(
                            onPressed: _saving || _linhas.length == 1
                                ? null
                                : () => setState(() => _linhas.removeAt(i)),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _saving ? null : () => setState(() => _linhas.add(_LinhaItem())),
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar item'),
                ),
              ),
              TextField(
                controller: _obs,
                enabled: !_saving,
                decoration: const InputDecoration(labelText: 'Observações'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Total  R\$ ${_total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const Spacer(),
                  FilledButton(
                    onPressed: _saving ? null : _criar,
                    style: FilledButton.styleFrom(backgroundColor: AppColors.accent),
                    child: _saving
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Criar'),
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
