// lib/presentation/pages/produtos/detalhe_produto_page.dart
// Refatorado eTools - Responsivo
import 'package:flutter/material.dart';
import 'package:front_openerp/data/models/models.dart';
import 'package:front_openerp/presentation/providers/providers.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class DetalheProdutoPage extends StatefulWidget {
  final int produtoId;
  const DetalheProdutoPage({super.key, required this.produtoId});

  @override
  State<DetalheProdutoPage> createState() => _DetalheProdutoPageState();
}

class _DetalheProdutoPageState extends State<DetalheProdutoPage> {
  ProdutoModel? _produto;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final provider = context.read<ProdutoProvider>();
      final produto = await provider.getProdutoById(widget.produtoId);
      if (!mounted) return;
      setState(() { _produto = produto; _isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final isWeb = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: Colors.white, title: Text(_produto?.nome ?? 'Detalhes do Produto', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)), actions: [IconButton(icon: const Icon(Icons.refresh_outlined), onPressed: _loadData)]),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.error_outline, size: 64, color: AppColors.error), const SizedBox(height: 16), Text('Erro ao carregar produto', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 8), Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textGrey)), const SizedBox(height: 16), FilledButton(onPressed: _loadData, child: const Text('Tentar novamente'))]))
              : _produto == null
                  ? const Center(child: Text('Produto não encontrado'))
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                          decoration: BoxDecoration(color: _produto!.disponivel ? AppColors.successBg : const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(20)),
                                          child: Text(_produto!.disponivel ? 'Disponível' : 'Indisponível', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _produto!.disponivel ? AppColors.success : AppColors.error)),
                                        ),
                                        const SizedBox(width: 8),
                                        if (_produto!.categoriaNome != null)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
                                            child: Text(_produto!.categoriaNome!, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(width: 64, height: 64, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 32)),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(_produto!.nome, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                                              const SizedBox(height: 8),
                                              Text(numberFormat.format(_produto!.preco), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.accent)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (_produto!.descricao != null) ...[
                                      const SizedBox(height: 20),
                                      const Divider(),
                                      const SizedBox(height: 16),
                                      Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.description_outlined, size: 18, color: AppColors.warning)), const SizedBox(width: 10), const Text('Descrição', style: TextStyle(fontWeight: FontWeight.w700))]),
                                      const SizedBox(height: 12),
                                      Text(_produto!.descricao!, style: const TextStyle(fontSize: 14, color: AppColors.textDark, height: 1.5)),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
                                child: Column(
                                  children: [
                                    Row(children: [const Icon(Icons.access_time, size: 14, color: AppColors.textGrey), const SizedBox(width: 8), Text('Criado em: ${dateFormat.format(_produto!.createdAt)}', style: const TextStyle(fontSize: 11, color: AppColors.textGrey))]),
                                    const SizedBox(height: 6),
                                    Row(children: [const Icon(Icons.update, size: 14, color: AppColors.textGrey), const SizedBox(width: 8), Text('Atualizado em: ${dateFormat.format(_produto!.updatedAt)}', style: const TextStyle(fontSize: 11, color: AppColors.textGrey))]),
                                    if (_produto!.tenantId != null) ...[const SizedBox(height: 6), Row(children: [const Icon(Icons.business_outlined, size: 14, color: AppColors.textGrey), const SizedBox(width: 8), Text('Tenant ID: ${_produto!.tenantId}', style: const TextStyle(fontSize: 11, color: AppColors.textGrey))])],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
                                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.verified, size: 14, color: AppColors.accent), SizedBox(width: 6), Text('Produto gerenciado por eTools Tecnologia • ERPCloud OpenERP', style: TextStyle(fontSize: 11, color: AppColors.textGrey))]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
    );
  }
}
