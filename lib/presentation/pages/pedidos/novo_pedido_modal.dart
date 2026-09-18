import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front_openerp/data/models/models.dart';
import 'package:front_openerp/presentation/providers/providers.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../clientes/novo_cliente_dialog.dart';

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
  final FocusNode buscaFocus = FocusNode();
  final FocusNode qtdFocus = FocusNode();

  void dispose() {
    busca.dispose();
    qtd.dispose();
    buscaFocus.dispose();
    qtdFocus.dispose();
  }
}

class NovoPedidoModal extends StatefulWidget {
  const NovoPedidoModal({super.key});

  @override
  State<NovoPedidoModal> createState() => _NovoPedidoModalState();
}

class _NovoPedidoModalState extends State<NovoPedidoModal> {
  ClienteModel? _cliente;
  final _clienteBusca = TextEditingController();
  final _clienteFocus = FocusNode();
  final _obs = TextEditingController();
  final _addItemFocus = FocusNode();
  final _criarFocus = FocusNode();
  final _linhas = <_LinhaItem>[_LinhaItem()];

  Timer? _clienteDebounce;
  Timer? _produtoDebounce;
  List<ClienteModel> _clientesSugestao = [];
  List<ProdutoModel> _produtosSugestao = [];
  int _clienteHi = 0;
  int _produtoHi = 0;
  int? _linhaBuscandoProduto;
  bool _saving = false;
  bool _buscandoCliente = false;
  bool _buscandoProduto = false;
  String _tipoEntrega = 'entrega';
  List<EnderecoModel> _enderecos = [];
  EnderecoModel? _endereco;
  bool _carregandoEnderecos = false;

  @override
  void dispose() {
    _clienteDebounce?.cancel();
    _produtoDebounce?.cancel();
    _clienteBusca.dispose();
    _clienteFocus.dispose();
    _obs.dispose();
    _addItemFocus.dispose();
    _criarFocus.dispose();
    for (final l in _linhas) {
      l.dispose();
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
    if (_cliente != null && q != _cliente!.nome) _cliente = null;
    if (q.length < 3) {
      setState(() {
        _clientesSugestao = [];
        _clienteHi = 0;
      });
      return;
    }
    _clienteDebounce = Timer(const Duration(milliseconds: 280), () async {
      setState(() => _buscandoCliente = true);
      await context.read<ClienteProvider>().searchByNome(q);
      if (!mounted) return;
      setState(() {
        _buscandoCliente = false;
        _clientesSugestao = context.read<ClienteProvider>().clientes;
        _clienteHi = 0;
      });
    });
  }

  void _onProdutoChanged(int index, String raw) {
    _produtoDebounce?.cancel();
    final q = raw.trim();
    final linha = _linhas[index];
    if (linha.produto != null && q != linha.produto!.nome) linha.produto = null;
    if (q.length < 3) {
      setState(() {
        _produtosSugestao = [];
        _linhaBuscandoProduto = null;
        _produtoHi = 0;
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
        _produtoHi = 0;
      });
    });
  }

  Future<void> _carregarEnderecos(int clienteId) async {
    setState(() {
      _carregandoEnderecos = true;
      _enderecos = [];
      _endereco = null;
    });
    final list = await context.read<ClienteProvider>().listarEnderecos(clienteId);
    if (!mounted) return;
    setState(() {
      _enderecos = list;
      _endereco = list.where((e) => e.principal).cast<EnderecoModel?>().firstWhere((_) => true, orElse: () => list.isEmpty ? null : list.first);
      _carregandoEnderecos = false;
    });
  }

  void _pickCliente(ClienteModel c) {
    setState(() {
      _cliente = c;
      _clienteBusca.text = c.nome;
      _clientesSugestao = [];
    });
    _carregarEnderecos(c.id);
    if (_linhas.first.buscaFocus.canRequestFocus) {
      _linhas.first.buscaFocus.requestFocus();
    }
  }

  void _pickProduto(int index, ProdutoModel p) {
    final linha = _linhas[index];
    setState(() {
      linha.produto = p;
      linha.busca.text = p.nome;
      _produtosSugestao = [];
      _linhaBuscandoProduto = null;
    });
    linha.qtdFocus.requestFocus();
    linha.qtd.selection = TextSelection(baseOffset: 0, extentOffset: linha.qtd.text.length);
  }

  void _addLinha() {
    final nova = _LinhaItem();
    setState(() => _linhas.add(nova));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) nova.buscaFocus.requestFocus();
    });
  }

  KeyEventResult _onClienteKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    if (_clientesSugestao.isEmpty) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() => _clienteHi = (_clienteHi + 1) % _clientesSugestao.length);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() => _clienteHi = (_clienteHi - 1 + _clientesSugestao.length) % _clientesSugestao.length);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      _pickCliente(_clientesSugestao[_clienteHi]);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _onProdutoKey(int index, FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    if (_linhaBuscandoProduto == index && _produtosSugestao.isNotEmpty) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() => _produtoHi = (_produtoHi + 1) % _produtosSugestao.length);
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() => _produtoHi = (_produtoHi - 1 + _produtosSugestao.length) % _produtosSugestao.length);
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        _pickProduto(index, _produtosSugestao[_produtoHi]);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  Future<void> _criarCliente() async {
    final criado = await showNovoClienteDialog(context, nomeInicial: _clienteBusca.text.trim());
    if (!mounted || criado == null) return;
    _pickCliente(criado);
  }

  Future<void> _criar() async {
    if (_cliente == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione ou crie um cliente')));
      _clienteFocus.requestFocus();
      return;
    }
    if (_tipoEntrega == 'entrega' && _endereco == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Confirme o endereço de entrega')));
      return;
    }
    final itens = <Map<String, dynamic>>[];
    for (final l in _linhas) {
      final p = l.produto;
      if (p == null || l.quantidade < 1) continue;
      itens.add({'produto_id': p.id, 'nome': p.nome, 'quantidade': l.quantidade, 'preco': p.preco});
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
          enderecoEntregaId: _tipoEntrega == 'entrega' ? _endereco?.id : null,
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
      SnackBar(content: Text('Pedido #${criado.id} criado'), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Focus(
                      onKeyEvent: _onClienteKey,
                      child: TextField(
                        controller: _clienteBusca,
                        focusNode: _clienteFocus,
                        enabled: !_saving,
                        textInputAction: TextInputAction.next,
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
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _saving ? null : _criarCliente,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    ),
                    icon: const Icon(Icons.person_add_alt_1, size: 18),
                    label: const Text('Novo cliente'),
                  ),
                ],
              ),
              if (_cliente != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('${_cliente!.nome}  •  ${_cliente!.telefone}', style: const TextStyle(fontSize: 13)),
                ),
              if (_clientesSugestao.isNotEmpty)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 160),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _clientesSugestao.length,
                    itemBuilder: (_, i) {
                      final c = _clientesSugestao[i];
                      final on = i == _clienteHi;
                      return ListTile(
                        dense: true,
                        selected: on,
                        selectedTileColor: AppColors.accent.withValues(alpha: 0.12),
                        title: Text(c.nome),
                        subtitle: Text(c.telefone),
                        onTap: () => _pickCliente(c),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 12),
              const Text('Tipo de entrega', style: headerStyle),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Entrega'),
                    selected: _tipoEntrega == 'entrega',
                    onSelected: _saving ? null : (_) => setState(() => _tipoEntrega = 'entrega'),
                  ),
                  ChoiceChip(
                    label: const Text('Retirada no local'),
                    selected: _tipoEntrega == 'retirada',
                    onSelected: _saving ? null : (_) => setState(() => _tipoEntrega = 'retirada'),
                  ),
                ],
              ),
              if (_tipoEntrega == 'entrega') ...[
                const SizedBox(height: 8),
                if (_cliente == null)
                  const Text('Selecione o cliente para confirmar o endereço.', style: TextStyle(fontSize: 13, color: AppColors.textGrey))
                else if (_carregandoEnderecos)
                  const LinearProgressIndicator(minHeight: 2)
                else if (_enderecos.isEmpty)
                  const Text('Este cliente não tem endereço cadastrado.', style: TextStyle(fontSize: 13, color: AppColors.error))
                else
                  DropdownButtonFormField<EnderecoModel>(
                    value: _endereco,
                    isExpanded: true,
                    decoration: const InputDecoration(hintText: 'Confirmar endereço de entrega'),
                    items: _enderecos
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              '${e.logradouro}, ${e.numero} — ${e.bairro}, ${e.cidade}'
                              '${e.principal ? ' (principal)' : ''}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: _saving ? null : (v) => setState(() => _endereco = v),
                  ),
              ],
              const SizedBox(height: 12),
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
                                child: Focus(
                                  onKeyEvent: (n, e) => _onProdutoKey(i, n, e),
                                  child: TextField(
                                    controller: linha.busca,
                                    focusNode: linha.buscaFocus,
                                    enabled: !_saving,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(hintText: 'Buscar produto (3+ letras)'),
                                    onChanged: (v) => _onProdutoChanged(i, v),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 72,
                                child: TextField(
                                  controller: linha.qtd,
                                  focusNode: linha.qtdFocus,
                                  enabled: !_saving,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  onChanged: (v) => setState(() => linha.quantidade = int.tryParse(v) ?? 1),
                                  onSubmitted: (_) => _addItemFocus.requestFocus(),
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
                                          linha.dispose();
                                          _linhas.removeAt(i);
                                        }),
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                            ],
                          ),
                          if (_linhaBuscandoProduto == i && _produtosSugestao.isNotEmpty)
                            ...List.generate(_produtosSugestao.take(8).length, (pi) {
                              final p = _produtosSugestao[pi];
                              final on = pi == _produtoHi;
                              return ListTile(
                                dense: true,
                                selected: on,
                                selectedTileColor: AppColors.accent.withValues(alpha: 0.12),
                                title: Text(p.nome),
                                trailing: Text(p.precoFormatado),
                                onTap: () => _pickProduto(i, p),
                              );
                            }),
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
                child: FilledButton.icon(
                  focusNode: _addItemFocus,
                  onPressed: _saving ? null : _addLinha,
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar item'),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _obs,
                enabled: !_saving,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(hintText: 'Observações'),
                maxLines: 2,
                onSubmitted: (_) => _criarFocus.requestFocus(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Total  R\$ ${_total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const Spacer(),
                  FilledButton(
                    focusNode: _criarFocus,
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
