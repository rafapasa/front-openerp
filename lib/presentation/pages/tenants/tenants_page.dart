// lib/presentation/pages/tenants/tenants_page.dart
import 'package:flutter/material.dart';
import 'package:front_openerp/presentation/pages/tenants/detalhe_tenant_page.dart';
import 'package:front_openerp/presentation/pages/tenants/form_tenant_page.dart';
import 'package:front_openerp/presentation/providers/tenant_provider.dart';
import 'package:provider/provider.dart';

class TenantsPage extends StatefulWidget {
  const TenantsPage({super.key});

  @override
  State<TenantsPage> createState() => _TenantsPageState();
}

class _TenantsPageState extends State<TenantsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TenantProvider>().carregarTenants();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Empresas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const FormTenantPage()));
            },
          ),
        ],
      ),
      body: Consumer<TenantProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Erro ao carregar empresas', style: TextStyle(color: Colors.red[700])),
                  const SizedBox(height: 8),
                  Text(provider.error ?? 'Erro desconhecido'),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () => provider.carregarTenants(), child: const Text('Tentar novamente')),
                ],
              ),
            );
          }

          if (provider.tenants.isEmpty) {
            return const Center(child: Text('Nenhuma empresa cadastrada'));
          }

          return ListView.builder(
            itemCount: provider.tenants.length,
            itemBuilder: (context, index) {
              final tenant = provider.tenants[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    child: Text(
                      tenant.nome.isNotEmpty ? tenant.nome[0].toUpperCase() : '?',
                      style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(tenant.nome, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(tenant.cnpj ?? '', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DetalheTenantPage(tenant: tenant)),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
