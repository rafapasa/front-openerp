// lib/presentation/pages/tenants/detalhe_tenant_page.dart
import 'package:flutter/material.dart';
import 'package:front_openerp/data/models/tenant_model.dart';
import 'package:front_openerp/presentation/pages/tenants/form_tenant_page.dart';
import 'package:front_openerp/presentation/providers/tenant_provider.dart';
import 'package:provider/provider.dart';

class DetalheTenantPage extends StatelessWidget {
  final TenantModel tenant;

  const DetalheTenantPage({super.key, required this.tenant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tenant.nome),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormTenantPage(tenant: tenant),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmarExclusao(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfo('CNPJ', tenant.cnpj ?? 'Não informado'),
            _buildInfo('Email', tenant.email ?? 'Não informado'),
            _buildInfo('Telefone', tenant.telefone ?? 'Não informado'),
            _buildInfo('Endereço', tenant.endereco ?? 'Não informado'),
            _buildInfo('Status', tenant.ativo ? 'Ativo' : 'Inativo'),
            if (tenant.createdAt != null)
              _buildInfo('Criado em', _formatDate(tenant.createdAt!)),
            if (tenant.updatedAt != null)
              _buildInfo('Atualizado em', _formatDate(tenant.updatedAt!)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _confirmarExclusao(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir a empresa "${tenant.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<TenantProvider>();
              await provider.excluirTenant(tenant.id!);
              if (provider.error == null && context.mounted) {
                Navigator.pop(context, true);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}