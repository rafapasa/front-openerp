// lib/presentation/pages/pedidos/detalhe_pedido_page.dart
import 'package:flutter/material.dart';
import 'package:front_openerp/data/models/models.dart';
import 'package:front_openerp/presentation/providers/providers.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DetalhePedidoPage extends StatefulWidget {
  final int pedidoId;

  const DetalhePedidoPage({super.key, required this.pedidoId});

  @override
  State<DetalhePedidoPage> createState() => _DetalhePedidoPageState();
}

class _DetalhePedidoPageState extends State<DetalhePedidoPage> {
  PedidoModel? _pedido;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPedido();
  }

  Future<void> _loadPedido() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider = context.read<PedidoProvider>();
      final pedido = await provider.getPedidoById(widget.pedidoId);
      setState(() {
        _pedido = pedido;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(StatusPedido novoStatus) async {
    final provider = context.read<PedidoProvider>();
    final success = await provider.updateStatus(widget.pedidoId, novoStatus);

    if (success && mounted) {
      await _loadPedido();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status atualizado para ${novoStatus.label}'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Erro ao atualizar status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido #${widget.pedidoId}'),
        actions: [
          if (_pedido != null && _pedido!.podeCancelar)
            IconButton(
              icon: const Icon(Icons.cancel_outlined),
              onPressed: () => _updateStatus(StatusPedido.cancelado),
              tooltip: 'Cancelar pedido',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar pedido',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadPedido,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            )
          : _pedido == null
          ? const Center(child: Text('Pedido não encontrado'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(
                                int.parse(
                                  _pedido!.statusColor.replaceFirst(
                                    '#',
                                    '0xff',
                                  ),
                                ),
                              ).withValues(),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getStatusIcon(_pedido!.status),
                              color: Color(
                                int.parse(
                                  _pedido!.statusColor.replaceFirst(
                                    '#',
                                    '0xff',
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _pedido!.statusLabel,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Status atual do pedido',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          // Dropdown para atualizar status
                          if (_pedido!.isAtivo)
                            DropdownButton<StatusPedido>(
                              value: _pedido!.status,
                              items: StatusPedido.values.map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(status.label),
                                );
                              }).toList(),
                              onChanged: (newStatus) {
                                if (newStatus != null) {
                                  _updateStatus(newStatus);
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Informações do Cliente
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '👤 Cliente',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _pedido!.clienteNome,
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            _pedido!.clienteTelefone,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          if (_pedido!.enderecoEntrega != null) ...[
                            const SizedBox(height: 8),
                            const Divider(),
                            const SizedBox(height: 8),
                            const Text(
                              '📍 Endereço de Entrega',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _pedido!.enderecoEntrega!.enderecoCompleto,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Itens do Pedido
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '📦 Itens',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._pedido!.itens.map(
                            (item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(flex: 3, child: Text(item.nome)),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '${item.quantidade}x',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      numberFormat.format(item.subtotal),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                numberFormat.format(_pedido!.total),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Observações
                  if (_pedido!.observacoes != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '📝 Observações',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(_pedido!.observacoes!),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Metadados
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Criado em: ${dateFormat.format(_pedido!.createdAt)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.update, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Atualizado em: ${dateFormat.format(_pedido!.updatedAt)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.source, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Origem: ${_pedido!.origemLabel}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        if (_pedido!.tempoEstimado != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.timer, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Tempo estimado: ${_pedido!.tempoEstimado} min',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  IconData _getStatusIcon(StatusPedido status) {
    switch (status) {
      case StatusPedido.pendente:
        return Icons.pending;
      case StatusPedido.confirmado:
        return Icons.check_circle;
      case StatusPedido.preparando:
        return Icons.build;
      case StatusPedido.entregue:
        return Icons.delivery_dining;
      case StatusPedido.cancelado:
        return Icons.cancel;
    }
  }
}
