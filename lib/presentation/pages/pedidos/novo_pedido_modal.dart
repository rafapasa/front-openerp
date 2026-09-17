import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _LinhaItem {
  ProdutoModel? produto;
  int quantidade = 1;
  final TextEditingController busca = TextEditingController();
  final TextEditingController qtd = TextEditingController(text: '1');
}

class NovoPedidoModal extends StatefulWidget {
  const NovoPedidoModal({super.key});

  @override
  State<NovoPedidoModal> createState() => _NovoPedidoModalState();
}

class _NovoPedidoModalState extends State<NovoPedidoModal> {
  ClienteModel? _cliente;
  final _clienteBusca = TextEditingController();
  final _obs = TextEditingController();
  final _linhas = <_LinhaItem>[_LinhaItem()];
  Timer? _clienteDebounce;
  Timer? _produtoDebounce;
  List<ClienteModel> _clientesSugestao = [];
  List<ProdutoModel> _produtosSugestao = [];
  int? _linhaBuscandoProduto;
  bool _saving = false;
  bool _buscandoCliente = false;
  bool _buscandoProduto = false;

  @override
  void dispose() {
    _clienteDebounce?.cancel();
    _produtoDebounce?.cancel();
    _clienteBusca.dispose();
    _obs.dispose();
    for (final l in _linhas) {
      l.busca.dispose();
      l.qtd.dispose();
    }
    super.dispose();
  }

  double get _total {
    var t = 0.0;
    for (final l in _linhas) {
      if (l.produto != null) t += l.produto!.preco * l.quantidade;
    }
    return t;
  }

  void _onClienteChanged(String raw) {
    _clienteDebounce?.cancel();
    final q = raw.trim();
    if (_cliente != null && q != _cliente!.nome) {
      _cliente = null;
    }
    if (q.length < 3) {
      setState(() => _clientesSugestao = []);
      return;
    }
    _clienteDebounce = Timer(const Duration(milliseconds: 280), () async {
      setState(() => _buscandoCliente = true);
      await context.read<ClienteProvider>().searchByNome(q);
      if (!mounted) return;
      setState(() {
        _buscandoCliente = false;
        _clientesSugestao = context.read<ClienteProvider>().clientes;
      });
    });
  }

  void _onProdutoChanged(int index, String raw) {
    _produtoDebounce?.cancel();
    final q = raw.trim();
    final linha = _linhas[index];
    if (linha.produto != null && q != linha.produto!.nome) {
      linha.produto = null;
    }
    if (q.length < 3) {
      setState(() {
        _produtosSugestao = [];
        _linhaBuscandoProduto = null;
      });
      return;
    }
    _linhaBuscandoProduto = index;
    _produtoDebounce = Timer(const Duration(milliseconds: 280), () async {
      setState(() => _buscandoProduto = true);
      await context.read<ProdutoProvider>().searchByNome(q);
      if (!mounted) return;
      setState(() {
        _buscandoProduto = false;
        _produtosSugestao = context.read<ProdutoProvider>().produtos;
      });
    });
  }

  Future<void> _criarCliente() async {
    final nomeCtrl = TextEditingController(text: _clienteBusca.text.trim());
    final telCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Novo cliente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nomeCtrl, decoration: const InputDecoration(labelText: 'Nome')),
            TextField(
              controller: telCtrl,
              decoration: const InputDecoration(labelText: 'Telefone'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Criar')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final criado = await context.read<ClienteProvider>().createCliente(
          nome: nomeCtrl.text.trim(),
          telefone: telCtrl.text.trim(),
        );
    if (!mounted) return;
    if (criado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<ClienteProvider>().error ?? 'Não foi possível criar o cliente')),
      );
      return;
    }
    setState(() {
      _cliente = criado;
      _clienteBusca.text = criado.nome;
      _clientesSugestao = [];
    });
  }

  Future<void> _criar() async {
    if (_cliente == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione ou crie um cliente')));
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
    const headerStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textGrey);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 760),
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
              const Text('Cliente', style: headerStyle),
              const SizedBox(height: 6),
              TextField(
                controller: _clienteBusca,
                enabled: !_saving,
                decoration: InputDecoration(
                  hintText: 'Digite ao menos 3 letras',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  suffixIcon: _buscandoCliente
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : null,
                ),
                onChanged: _onClienteChanged,
              ),
              if (_cliente != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('${_cliente!.nome}  •  ${_cliente!.telefone}', style: const TextStyle(fontSize: 13)),
                ),
              if (_clienteBusca.text.trim().length >= 3 && _clientesSugestao.isNotEmpty)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 140),
                  child: ListView(
                    shrinkWrap: true,
                    children: _clientesSugestao
                        .map(
                          (c) => ListTile(
                            dense: true,
                            title: Text(c.nome),
                            subtitle: Text(c.telefone),
                            onTap: () => setState(() {
                              _cliente = c;
                              _clienteBusca.text = c.nome;
                              _clientesSugestao = [];
                            }),
                          ),
                        )
                        .toList(),
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _saving ? null : _criarCliente,
                  icon: const Icon(Icons.person_add_alt),
                  label: const Text('Criar novo cliente'),
                ),
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Expanded(flex: 5, child: Text('Produto', style: headerStyle)),
                  SizedBox(width: 8),
                  SizedBox(width: 72, child: Text('Qtd', style: headerStyle)),
                  SizedBox(width: 8),
                  SizedBox(width: 88, child: Text('Unitário', style: headerStyle)),
                  SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 6),
              Expanded(
                child: ListView.builder(
                  itemCount: _linhas.length,
                  itemBuilder: (_, i) {
                    final linha = _linhas[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: TextField(
                                  controller: linha.busca,
                                  enabled: !_saving,
                                  decoration: const InputDecoration(hintText: 'Buscar produto (3+ letras)'),
                                  onChanged: (v) => _onProdutoChanged(i, v),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 72,
                                child: TextField(
                                  controller: linha.qtd,
                                  enabled: !_saving,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  onChanged: (v) => setState(() => linha.quantidade = int.tryParse(v) ?? 1),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 88,
                                height: 48,
                                child: InputDecorator(
                                  decoration: const InputDecoration(),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      linha.produto == null ? '—' : linha.produto!.preco.toStringAsFixed(2),
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: _saving || _linhas.length == 1
                                    ? null
                                    : () => setState(() {
                                          linha.busca.dispose();
                                          linha.qtd.dispose();
                                          _linhas.removeAt(i);
                                        }),
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                            ],
                          ),
                          if (_linhaBuscandoProduto == i && _produtosSugestao.isNotEmpty)
                            ..._produtosSugestao.take(6).map(
                                  (p) => ListTile(
                                    dense: true,
                                    title: Text(p.nome),
                                    trailing: Text(p.precoFormatado),
                                    onTap: () => setState(() {
                                      linha.produto = p;
                                      linha.busca.text = p.nome;
                                      _produtosSugestao = [];
                                      _linhaBuscandoProduto = null;
                                    }),
                                  ),
                                ),
                          if (_buscandoProduto && _linhaBuscandoProduto == i)
                            const LinearProgressIndicator(minHeight: 2),
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
                decoration: const InputDecoration(hintText: 'Observações'),
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
