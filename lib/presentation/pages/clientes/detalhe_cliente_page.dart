// lib/presentation/pages/clientes/detalhe_cliente_page.dart
import 'package:flutter/material.dart';
import 'package:front_openerp/data/models/models.dart';
import 'package:front_openerp/presentation/providers/providers.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../data/services/services.dart';

class DetalheClientePage extends StatefulWidget {
  final int clienteId;

  const DetalheClientePage({super.key, required this.clienteId});

  @override
  State<DetalheClientePage> createState() => _DetalheClientePageState();
}

class _DetalheClientePageState extends State<DetalheClientePage> {
  ClienteModel? _cliente;
  List<EnderecoModel> _enderecos = [];
  bool _isLoading = true;
  bool _isLoadingEnderecos = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Buscar cliente
      final provider = context.read<ClienteProvider>();
      final cliente = await provider.getClienteById(widget.clienteId);

      setState(() {
        _cliente = cliente;
        _isLoading = false;
      });

      // Buscar endereços
      await _loadEnderecos();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadEnderecos() async {
    if (_enderecos.isNotEmpty) return;

    setState(() {
      _isLoadingEnderecos = true;
    });

    try {
      final clienteService = context.read<ClienteService>();
      final enderecos = await clienteService.getEnderecosByCliente(
        widget.clienteId,
      );

      setState(() {
        _enderecos = enderecos;
        _isLoadingEnderecos = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingEnderecos = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(_cliente?.nome ?? 'Detalhes do Cliente'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
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
                    'Erro ao carregar cliente',
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
                    onPressed: _loadData,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            )
          : _cliente == null
          ? const Center(child: Text('Cliente não encontrado'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card Principal do Cliente
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Avatar e Nome
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.blue.withValues(),
                                child: Text(
                                  _cliente!.nome.isNotEmpty
                                      ? _cliente!.nome[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _cliente!.nome,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _cliente!.status == 'ativo'
                                            ? Colors.green.withValues()
                                            : Colors.red.withValues(),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _cliente!.status == 'ativo'
                                            ? 'Ativo'
                                            : 'Inativo',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _cliente!.status == 'ativo'
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          const SizedBox(height: 8),

                          // Informações de Contato
                          _InfoRow(
                            icon: Icons.phone,
                            label: 'Telefone',
                            value: _cliente!.telefone,
                          ),
                          if (_cliente!.email != null)
                            _InfoRow(
                              icon: Icons.email,
                              label: 'Email',
                              value: _cliente!.email!,
                            ),
                          if (_cliente!.inscricaoFederal != null)
                            _InfoRow(
                              icon: Icons.badge,
                              label: 'CPF/CNPJ',
                              value: _cliente!.inscricaoFederal!,
                            ),
                          if (_cliente!.nomePerfil != null)
                            _InfoRow(
                              icon: Icons.person_outline,
                              label: 'Nome no Perfil',
                              value: _cliente!.nomePerfil!,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Último Pedido
                  if (_cliente!.ultimoPedidoAt != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '🛒 Último Pedido',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  dateFormat.format(_cliente!.ultimoPedidoAt!),
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Endereços
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '📍 Endereços',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${_enderecos.length} endereço(s)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_isLoadingEnderecos)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (_enderecos.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  'Nenhum endereço cadastrado',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            )
                          else
                            ..._enderecos.map(
                              (endereco) => _EnderecoCard(endereco: endereco),
                            ),
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
                              'Criado em: ${dateFormat.format(_cliente!.createdAt)}',
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
                              'Atualizado em: ${dateFormat.format(_cliente!.updatedAt)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// Widget auxiliar: Linha de Informação
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget auxiliar: Card de Endereço
class _EnderecoCard extends StatelessWidget {
  final EnderecoModel endereco;

  const _EnderecoCard({required this.endereco});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                endereco.principal ? Icons.star : Icons.home,
                size: 16,
                color: endereco.principal ? Colors.amber : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                endereco.tipo == 'residencial' ? 'Residencial' : 'Comercial',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              if (endereco.principal)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Principal',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.amber,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            endereco.enderecoCompleto,
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 4),
          Text(
            'CEP: ${endereco.cep}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          if (endereco.referencia != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Ref: ${endereco.referencia}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
