// lib/presentation/pages/tenants/detalhe_tenant_page.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:front_openerp/data/models/tenant_model.dart';
import 'package:front_openerp/data/services/tenant_service.dart';
import 'package:front_openerp/presentation/pages/tenants/form_tenant_page.dart';
import 'package:front_openerp/presentation/providers/tenant_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DetalheTenantPage extends StatefulWidget {
  final int tenantId;

  const DetalheTenantPage({super.key, required this.tenantId});

  @override
  State<DetalheTenantPage> createState() => _DetalheTenantPageState();
}

class _DetalheTenantPageState extends State<DetalheTenantPage> {
  TenantModel? _tenant;
  bool _isLoading = true;
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
      final provider = context.read<TenantProvider>();
      final tenant = await provider.getTenantById(widget.tenantId);

      setState(() {
        _tenant = tenant;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleStatus() async {
    if (_tenant == null) return;

    final s = context.read<TenantService>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_tenant!.ativo ? 'Desativar Tenant' : 'Ativar Tenant'),
        content: Text(
          _tenant!.ativo
              ? 'Tem certeza que deseja desativar o tenant "${_tenant!.nome}"?'
              : 'Tem certeza que deseja ativar o tenant "${_tenant!.nome}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              _tenant!.ativo ? 'Desativar' : 'Ativar',
              style: TextStyle(
                color: _tenant!.ativo ? Colors.red : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await s.toggleStatus(_tenant!.id);
      await _loadData(); // Recarregar dados

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _tenant!.ativo
                ? 'Tenant desativado com sucesso!'
                : 'Tenant ativado com sucesso!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao alterar status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteTenant() async {
    if (_tenant == null) return;

    final provider = context.read<TenantProvider>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Tenant'),
        content: Text(
          'Tem certeza que deseja excluir o tenant "${_tenant!.nome}"?\n\n'
          'Esta ação não pode ser desfeita e todos os dados relacionados '
          'serão removidos permanentemente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final success = await provider.deleteTenant(_tenant!.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tenant excluído com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir tenant: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(_tenant?.nome ?? 'Detalhes do Tenant'),
        actions: [
          // Botão Editar
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _tenant != null
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FormTenantPage(tenant: _tenant),
                      ),
                    ).then((_) => _loadData());
                  }
                : null,
            tooltip: 'Editar',
          ),
          // Botão Ativar/Desativar
          if (_tenant != null)
            IconButton(
              icon: Icon(
                _tenant!.ativo
                    ? Icons.pause_circle_outline
                    : Icons.play_circle_outline,
                color: _tenant!.ativo ? Colors.orange : Colors.green,
              ),
              onPressed: _toggleStatus,
              tooltip: _tenant!.ativo ? 'Desativar' : 'Ativar',
            ),
          // Botão Excluir
          if (_tenant != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _deleteTenant,
              tooltip: 'Excluir',
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
                    'Erro ao carregar tenant',
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
          : _tenant == null
          ? const Center(child: Text('Tenant não encontrado'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ============================================================
                  // 📋 Card Principal
                  // ============================================================
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    _tenant!.nome.isNotEmpty
                                        ? _tenant!.nome[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
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
                                      _tenant!.nome,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _tenant!.ativo
                                                ? Colors.green.withValues(
                                                    alpha: 0.1,
                                                  )
                                                : Colors.red.withValues(
                                                    alpha: 0.1,
                                                  ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            _tenant!.statusLabel,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: _tenant!.ativo
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withValues(
                                              alpha: 0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            _tenant!.segmentoLabel,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.blue[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          const SizedBox(height: 8),

                          // Informações
                          _InfoRow(
                            icon: Icons.badge,
                            label: 'CNPJ/CPF',
                            value: _tenant!.cnpjFormatado,
                          ),
                          if (_tenant!.telefone != null)
                            _InfoRow(
                              icon: Icons.phone,
                              label: 'Telefone',
                              value: _tenant!.telefone!,
                            ),
                          if (_tenant!.endereco != null)
                            _InfoRow(
                              icon: Icons.location_on,
                              label: 'Endereço',
                              value: _tenant!.endereco!,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ============================================================
                  // 💬 WhatsApp
                  // ============================================================
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                '💬 WhatsApp Business',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _tenant!.isWhatsappConnected
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.whatsapp,
                                      size: 14,
                                      color: _tenant!.isWhatsappConnected
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _tenant!.isWhatsappConnected
                                          ? 'Conectado'
                                          : 'Desconectado',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _tenant!.isWhatsappConnected
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_tenant!.wabaId != null)
                            _InfoRow(
                              icon: Icons.code,
                              label: 'WABA ID',
                              value: _tenant!.wabaId!,
                            ),
                          if (_tenant!.whatsappPhoneId != null)
                            _InfoRow(
                              icon: Icons.phone_android,
                              label: 'Phone ID',
                              value: _tenant!.whatsappPhoneId!,
                            ),
                          if (_tenant!.whatsappDisplayNumber != null)
                            _InfoRow(
                              icon: Icons.phone,
                              label: 'Número de Exibição',
                              value: _tenant!.whatsappDisplayNumber!,
                            ),
                          if (!_tenant!.isWhatsappConnected)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'Nenhuma conexão WhatsApp configurada',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ============================================================
                  // 📊 Métricas
                  // ============================================================
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '📊 Métricas',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _MetricItem(
                                label: 'Total de Pedidos',
                                value: '0',
                                icon: Icons.shopping_cart,
                                color: Colors.blue,
                              ),
                              _MetricItem(
                                label: 'Total de Produtos',
                                value: '0',
                                icon: Icons.inventory,
                                color: Colors.green,
                              ),
                              _MetricItem(
                                label: 'Total de Clientes',
                                value: '0',
                                icon: Icons.people,
                                color: Colors.purple,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '⚠️ Métricas em desenvolvimento',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ============================================================
                  // 📝 Metadados
                  // ============================================================
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
                              'Criado em: ${dateFormat.format(_tenant!.createdAt)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botão Editar (rodapé)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FormTenantPage(tenant: _tenant),
                          ),
                        ).then((_) => _loadData());
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar Tenant'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ============================================================
// 📦 Widgets Auxiliares
// ============================================================

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

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
