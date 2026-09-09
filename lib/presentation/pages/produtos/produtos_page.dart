// lib/presentation/pages/produtos/produtos_page.dart
// Refatorado eTools - Responsivo
import 'package:flutter/material.dart';
import 'package:front_openerp/presentation/pages/produtos/detalhe_produto_page.dart';
import 'package:front_openerp/presentation/providers/providers.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class ProdutosPage extends StatefulWidget {
  const ProdutosPage({super.key});

  @override
  State<ProdutosPage> createState() => _ProdutosPageState();
}

class _ProdutosPageState extends State<ProdutosPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async => await context.read<ProdutoProvider>().loadProdutos();
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      final provider = context.read<ProdutoProvider>();
      if (!provider.isLoadingMore && provider.hasMore) provider.loadMore();
    }
  }

  Future<void> _refreshData() async => await context.read<ProdutoProvider>().refreshProdutos();
  void _search(String query) {
    final provider = context.read<ProdutoProvider>();
    if (query.isEmpty) provider.loadProdutos();
    else provider.searchByNome(query);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProdutoProvider>();
    final isWeb = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: EdgeInsets.all(isWeb ? 24 : 0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(isWeb ? 20 : 16),
              decoration: isWeb ? AppTheme.cardDecoration : const BoxDecoration(color: Colors.white),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _search,
                      decoration: InputDecoration(
                        hintText: 'Buscar produto por nome...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { _searchController.clear(); _search(''); }) : null,
                      ),
                    ),
                  ),
                  if (isWeb) ...[
                    const SizedBox(width: 12),
                    FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add, size: 18), label: const Text('Novo Produto'), style: FilledButton.styleFrom(backgroundColor: AppColors.primary)),
                  ],
                ],
              ),
            ),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : provider.error != null
                      ? _buildError(provider.error!, context)
                      : provider.produtos.isEmpty
                          ? _buildEmpty()
                          : RefreshIndicator(
                              color: AppColors.primary,
                              onRefresh: _refreshData,
                              child: isWeb ? _buildWebGrid(provider) : _buildMobileGrid(provider),
                            ),
            ),
          ],
        ),
      ),
      floatingActionButton: isWeb ? null : FloatingActionButton.extended(onPressed: () {}, backgroundColor: AppColors.primary, foregroundColor: Colors.white, icon: const Icon(Icons.add), label: const Text('Novo', style: TextStyle(fontWeight: FontWeight.w700))),
    );
  }

  Widget _buildError(String error, BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.error_outline, size: 64, color: AppColors.error), const SizedBox(height: 16), Text('Erro ao carregar produtos', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 8), Text(error, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textGrey)), const SizedBox(height: 16), FilledButton(onPressed: _loadData, child: const Text('Tentar novamente'))]));
  Widget _buildEmpty() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.inventory_outlined, size: 64, color: Colors.grey[400]), const SizedBox(height: 16), Text('Nenhum produto encontrado', style: TextStyle(fontSize: 16, color: Colors.grey[600]))]));

  Widget _buildMobileGrid(ProdutoProvider provider) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.9, crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemCount: provider.produtos.length + (provider.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.produtos.length) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        return _ProdutoCard(produto: provider.produtos[index]);
      },
    );
  }

  Widget _buildWebGrid(ProdutoProvider provider) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 0.95, crossAxisSpacing: 16, mainAxisSpacing: 16),
      itemCount: provider.produtos.length + (provider.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.produtos.length) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        return _ProdutoCard(produto: provider.produtos[index]);
      },
    );
  }
}

class _ProdutoCard extends StatelessWidget {
  final ProdutoModel produto;
  const _ProdutoCard({required this.produto});

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Container(
      decoration: AppTheme.cardDecoration,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetalheProdutoPage(produtoId: produto.id))),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: produto.disponivel ? AppColors.successBg : const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(20)),
                    child: Text(produto.disponivel ? 'Disponível' : 'Indisponível', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: produto.disponivel ? AppColors.success : AppColors.error)),
                  ),
                  if (produto.categoriaNome != null) Text(produto.categoriaNome!, style: const TextStyle(fontSize: 10, color: AppColors.textGrey, fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 20),
              ),
              const SizedBox(height: 10),
              Text(produto.nome, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              if (produto.descricao != null) ...[
                const SizedBox(height: 4),
                Text(produto.descricao!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
              ],
              const Spacer(),
              Text(numberFormat.format(produto.preco), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.accent)),
            ],
          ),
        ),
      ),
    );
  }
}
