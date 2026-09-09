// lib/presentation/pages/clientes/detalhe_cliente_page.dart
// Refatorado eTools - Responsivo
import 'package:flutter/material.dart';
import 'package:front_openerp/data/models/models.dart';
import 'package:front_openerp/presentation/providers/providers.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/services/services.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

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
    setState(() { _isLoading = true; _error = null; });
    try {
      final provider = context.read<ClienteProvider>();
      final cliente = await provider.getClienteById(widget.clienteId);
      if (!mounted) return;
      setState(() { _cliente = cliente; _isLoading = false; });
      await _loadEnderecos();
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _loadEnderecos() async {
    if (_enderecos.isNotEmpty) return;
    setState(() => _isLoadingEnderecos = true);
    try {
      final clienteService = context.read<ClienteService>();
      final enderecos = await clienteService.getEnderecosByCliente(widget.clienteId);
      if (!mounted) return;
      setState(() { _enderecos = enderecos; _isLoadingEnderecos = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingEnderecos = false);
    }
  }

  Color _getAvatarColor(String name) {
    final colors = [AppColors.primary, const Color(0xFF0EA5E9), AppColors.accent, const Color(0xFFF59E0B)];
    return colors[name.hashCode % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final isWeb = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(_cliente?.nome ?? 'Detalhes do Cliente', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        actions: [IconButton(icon: const Icon(Icons.refresh_outlined), onPressed: _loadData)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.error_outline, size: 64, color: AppColors.error), const SizedBox(height: 16), Text('Erro ao carregar cliente', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 8), Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textGrey)), const SizedBox(height: 16), FilledButton(onPressed: _loadData, child: const Text('Tentar novamente'))]))
              : _cliente == null
                  ? const Center(child: Text('Cliente não encontrado'))
                  : Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: isWeb ? 900 : double.infinity),
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(isWeb ? 24 : 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: AppTheme.cardDecorationElevated,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 72,
                                      height: 72,
                                      decoration: BoxDecoration(color: _getAvatarColor(_cliente!.nome).withValues(alpha: 0.12), shape: BoxShape.circle),
                                      child: Center(child: Text(_cliente!.nome.isNotEmpty ? _cliente!.nome[0].toUpperCase() : '?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _getAvatarColor(_cliente!.nome)))),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(_cliente!.nome, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(color: _cliente!.status == 'ativo' ? AppColors.successBg : const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(20)),
                                            child: Text(_cliente!.status == 'ativo' ? 'Ativo' : 'Inativo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _cliente!.status == 'ativo' ? AppColors.success : AppColors.error)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              LayoutBuilder(builder: (context, c) {
                                final wide = c.maxWidth > 700;
                                final infoSection = Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: AppTheme.cardDecoration,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.person_outline, size: 18, color: AppColors.primary)), const SizedBox(width: 10), const Text('Informações', style: TextStyle(fontWeight: FontWeight.w700))]),
                                      const SizedBox(height: 16),
                                      _InfoRow(icon: Icons.phone_outlined, label: 'Telefone', value: _cliente!.telefone),
                                      _InfoRow(icon: Icons.email_outlined, label: 'Email', value: 'cliente@exemplo.com'),
                                      _InfoRow(icon: Icons.shopping_bag_outlined, label: 'Último pedido', value: _cliente!.ultimoPedidoAt != null ? dateFormat.format(_cliente!.ultimoPedidoAt!) : 'Nenhum'),
                                    ],
                                  ),
                                );
                                final enderecoSection = Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: AppTheme.cardDecoration,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.location_on_outlined, size: 18, color: AppColors.accent)), const SizedBox(width: 10), const Text('Endereços', style: TextStyle(fontWeight: FontWeight.w700))]),
                                      const SizedBox(height: 16),
                                      if (_isLoadingEnderecos) const Center(child: CircularProgressIndicator(color: AppColors.primary)) else if (_enderecos.isEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Center(child: Text('Nenhum endereço cadastrado', style: TextStyle(color: Colors.grey[600])))) else ..._enderecos.map((e) => _EnderecoCard(endereco: e)),
                                    ],
                                  ),
                                );

                                if (wide) {
                                  return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: infoSection), const SizedBox(width: 16), Expanded(child: enderecoSection)]);
                                } else {
                                  return Column(children: [infoSection, const SizedBox(height: 16), enderecoSection]);
                                }
                              }),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
                                child: Column(
                                  children: [
                                    Row(children: [const Icon(Icons.access_time, size: 14, color: AppColors.textGrey), const SizedBox(width: 8), Text('Criado em: ${dateFormat.format(_cliente!.createdAt)}', style: const TextStyle(fontSize: 11, color: AppColors.textGrey))]),
                                    const SizedBox(height: 6),
                                    Row(children: [const Icon(Icons.update, size: 14, color: AppColors.textGrey), const SizedBox(width: 8), Text('Atualizado em: ${dateFormat.format(_cliente!.updatedAt)}', style: const TextStyle(fontSize: 11, color: AppColors.textGrey))]),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textGrey),
          const SizedBox(width: 10),
          SizedBox(width: 110, child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

class _EnderecoCard extends StatelessWidget {
  final EnderecoModel endereco;
  const _EnderecoCard({required this.endereco});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(endereco.principal ? Icons.star : Icons.home_outlined, size: 16, color: endereco.principal ? AppColors.warning : AppColors.textGrey),
              const SizedBox(width: 8),
              Text(endereco.tipo == 'residencial' ? 'Residencial' : 'Comercial', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const Spacer(),
              if (endereco.principal) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(20)), child: const Text('Principal', style: TextStyle(fontSize: 10, color: AppColors.warning, fontWeight: FontWeight.w700))),
            ],
          ),
          const SizedBox(height: 6),
          Text(endereco.enderecoCompleto, style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text('CEP: ${endereco.cep}', style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
          if (endereco.referencia != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text('Ref: ${endereco.referencia}', style: const TextStyle(fontSize: 11, color: AppColors.textGrey, fontStyle: FontStyle.italic))),
        ],
      ),
    );
  }
}
