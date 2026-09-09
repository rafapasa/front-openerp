// lib/presentation/pages/tenants/detalhe_tenant_page.dart
// Refatorado eTools - Responsivo
import 'package:flutter/material.dart';
import 'package:front_openerp/data/models/tenant_model.dart';
import 'package:front_openerp/presentation/pages/tenants/form_tenant_page.dart';
import 'package:front_openerp/presentation/providers/tenant_provider.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class DetalheTenantPage extends StatelessWidget {
  final TenantModel tenant;

  const DetalheTenantPage({super.key, required this.tenant});

  Color _getAvatarColor(String name) {
    final colors = [AppColors.primary, const Color(0xFF0EA5E9), AppColors.accent, const Color(0xFFF59E0B)];
    return colors[name.hashCode % colors.length];
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return (parts[0][0] + parts[1][0]).toUpperCase();
    return name.isNotEmpty ? name.substring(0, 2).toUpperCase() : '?';
  }

  String _formatCnpj(String? cnpj) {
    if (cnpj == null || cnpj.length != 14) return cnpj ?? 'Não informado';
    return '${cnpj.substring(0, 2)}.${cnpj.substring(2, 5)}.${cnpj.substring(5, 8)}/${cnpj.substring(8, 12)}-${cnpj.substring(12, 14)}';
  }

  String _formatTelefone(String? tel) {
    if (tel == null || tel.isEmpty) return 'Não informado';
    if (tel.length == 11) return '(${tel.substring(0, 2)}) ${tel.substring(2, 7)}-${tel.substring(7)}';
    if (tel.length == 10) return '(${tel.substring(0, 2)}) ${tel.substring(2, 6)}-${tel.substring(6)}';
    return tel;
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Detalhes da Empresa', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'edit') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => FormTenantPage(tenant: tenant)));
              } else if (v == 'delete') {
                _confirmarExclusao(context);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text('Editar')])),
              const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 8), Text('Excluir', style: TextStyle(color: Colors.red))])),
            ],
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWeb ? 900 : double.infinity),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, isWeb ? 24 : 100),
            child: Column(
              children: [
                // HEADER CARD
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: AppTheme.cardDecorationElevated,
                  child: Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: AppTheme.avatarDecoration(_getAvatarColor(tenant.nome)),
                        child: Center(child: Text(_getInitials(tenant.nome), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 26))),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tenant.nome, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                            const SizedBox(height: 4),
                            Text('CNPJ: ${_formatCnpj(tenant.cnpj)}', style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(color: tenant.ativo ? AppColors.successBg : Colors.grey[200], borderRadius: BorderRadius.circular(20)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(tenant.ativo ? Icons.verified : Icons.block, size: 14, color: tenant.ativo ? AppColors.success : Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(tenant.ativo ? 'Ativo' : 'Inativo', style: TextStyle(color: tenant.ativo ? AppColors.success : Colors.grey[700], fontWeight: FontWeight.w700, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
                                  child: const Text('Premium', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Grid responsivo: Web 2 colunas, Mobile 1 coluna
                LayoutBuilder(
                  builder: (context, c) {
                    final isWide = c.maxWidth > 700;
                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                _buildSection(title: 'Contato', icon: Icons.call_outlined, iconColor: AppColors.primary, children: [
                                  _buildRowInfo(Icons.phone_outlined, 'Telefone', _formatTelefone(tenant.telefone)),
                                  _buildRowInfo(Icons.email_outlined, 'E-mail', tenant.email ?? 'Não informado', isEmail: true),
                                ]),
                                const SizedBox(height: 16),
                                _buildSection(title: 'Endereço', icon: Icons.location_on_outlined, iconColor: const Color(0xFFFF8A5B), children: [
                                  _buildRowInfo(Icons.home_outlined, 'Endereço', tenant.endereco ?? 'Não informado'),
                                ]),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSection(title: 'Informações Gerais', icon: Icons.info_outline, iconColor: AppColors.accent, children: [
                              if (tenant.createdAt != null) _buildRowInfo(Icons.calendar_today_outlined, 'Criado em', _formatDate(tenant.createdAt!)),
                              if (tenant.updatedAt != null) _buildRowInfo(Icons.update, 'Atualizado em', _formatDate(tenant.updatedAt!)),
                              _buildRowInfo(Icons.tag, 'ID', tenant.id?.toString() ?? '-'),
                              _buildRowInfo(Icons.business, 'Plano', 'Premium - ERPCloud'),
                            ]),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          _buildSection(title: 'Contato', icon: Icons.call_outlined, iconColor: AppColors.primary, children: [
                            _buildRowInfo(Icons.phone_outlined, 'Telefone', _formatTelefone(tenant.telefone)),
                            _buildRowInfo(Icons.email_outlined, 'E-mail', tenant.email ?? 'Não informado', isEmail: true),
                          ]),
                          const SizedBox(height: 16),
                          _buildSection(title: 'Endereço', icon: Icons.location_on_outlined, iconColor: const Color(0xFFFF8A5B), children: [
                            _buildRowInfo(Icons.home_outlined, 'Endereço', tenant.endereco ?? 'Não informado'),
                          ]),
                          const SizedBox(height: 16),
                          _buildSection(title: 'Informações Gerais', icon: Icons.info_outline, iconColor: AppColors.accent, children: [
                            if (tenant.createdAt != null) _buildRowInfo(Icons.calendar_today_outlined, 'Criado em', _formatDate(tenant.createdAt!)),
                            if (tenant.updatedAt != null) _buildRowInfo(Icons.update, 'Atualizado em', _formatDate(tenant.updatedAt!)),
                            _buildRowInfo(Icons.tag, 'ID', tenant.id?.toString() ?? '-'),
                          ]),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),
                // Rodapé eTools
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/Icone_azul_500x500.png', width: 18, height: 18, errorBuilder: (_, __, ___) => const Icon(Icons.bolt, size: 16, color: AppColors.primary)),
                      const SizedBox(width: 6),
                      const Text('Gerenciado por eTools Tecnologia • ERPCloud OpenERP', style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: isWeb
          ? null
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: FilledButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FormTenantPage(tenant: tenant))),
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                icon: const Icon(Icons.edit),
                label: const Text('Editar Empresa', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
    );
  }

  Widget _buildSection({required String title, required IconData icon, required Color iconColor, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 20, color: iconColor)),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRowInfo(IconData icon, String label, String value, {bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textGrey),
          const SizedBox(width: 10),
          SizedBox(width: 110, child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54))),
          Expanded(child: Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isEmail ? AppColors.primary : Colors.black87))),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  void _confirmarExclusao(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Excluir empresa?'),
        content: Text('Deseja realmente excluir "${tenant.nome}"? Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<TenantProvider>();
              await provider.excluirTenant(tenant.id!);
              if (provider.error == null && context.mounted) Navigator.pop(context, true);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
