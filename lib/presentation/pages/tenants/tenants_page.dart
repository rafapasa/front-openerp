// lib/presentation/pages/tenants/tenants_page.dart (versão completa)
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:front_openerp/data/models/tenant_model.dart';
import 'package:front_openerp/presentation/pages/tenants/detalhe_tenant_page.dart';
import 'package:front_openerp/presentation/pages/tenants/form_tenant_page.dart';
import 'package:front_openerp/presentation/providers/tenant_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TenantsPage extends StatefulWidget {
  const TenantsPage({super.key});

  @override
  State<TenantsPage> createState() => _TenantsPageState();
}

class _TenantsPageState extends State<TenantsPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ✅ Usar addPostFrameCallback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final provider = context.read<TenantProvider>();
    await provider.loadTenants();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      final provider = context.read<TenantProvider>();
      if (!provider.isLoadingMore && provider.hasMore) {
        provider.loadMore();
      }
    }
  }

  Future<void> _refreshData() async {
    final provider = context.read<TenantProvider>();
    await provider.refreshTenants();
  }

  void _search(String query) {
    final provider = context.read<TenantProvider>();
    if (query.isEmpty) {
      provider.loadTenants();
    } else {
      provider.loadTenants(nome: query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TenantProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenants'),
        actions: [
          // Filtro de Status
          PopupMenuButton<bool?>(
            icon: const Icon(Icons.filter_alt),
            onSelected: (value) {
              final provider = context.read<TenantProvider>();
              provider.loadTenants(ativo: value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('Todos')),
              const PopupMenuItem(value: true, child: Text('Ativos')),
              const PopupMenuItem(value: false, child: Text('Inativos')),
            ],
          ),
          const SizedBox(width: 8),
          // Botão Novo
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FormTenantPage()),
              ).then((_) => _refreshData());
            },
            tooltip: 'Novo Tenant',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou CNPJ...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _search('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: _search,
            ),
          ),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erro ao carregar tenants', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadData, child: const Text('Tentar novamente')),
                ],
              ),
            )
          : provider.tenants.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.business_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Nenhum tenant encontrado', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FormTenantPage()),
                      ).then((_) => _refreshData());
                    },
                    child: const Text('Criar primeiro tenant'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: provider.tenants.length + (provider.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == provider.tenants.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final tenant = provider.tenants[index];
                  return _TenantCard(tenant: tenant);
                },
              ),
            ),
    );
  }
}

class _TenantCard extends StatelessWidget {
  final TenantModel tenant;

  const _TenantCard({required this.tenant});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => DetalheTenantPage(tenantId: tenant.id)));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(tenant.nome, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: tenant.ativo ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tenant.statusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: tenant.ativo ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (tenant.cnpj != null)
                Text('CNPJ/CPF: ${tenant.cnpjFormatado}', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              if (tenant.telefone != null)
                Text('Telefone: ${tenant.telefone}', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(tenant.segmentoLabel, style: TextStyle(fontSize: 12, color: Colors.blue[700])),
                  ),
                  const SizedBox(width: 8),
                  if (tenant.isWhatsappConnected)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FaIcon(FontAwesomeIcons.whatsapp, size: 14, color: Colors.green),
                          SizedBox(width: 4),
                          Text('WhatsApp', style: TextStyle(fontSize: 12, color: Colors.green)),
                        ],
                      ),
                    ),
                  const Spacer(),
                  Text(
                    'Criado: ${dateFormat.format(tenant.createdAt)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
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
