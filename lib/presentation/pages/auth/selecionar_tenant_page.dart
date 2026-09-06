// lib/presentation/pages/auth/selecionar_tenant_page.dart
import 'package:flutter/material.dart';
import 'package:front_openerp/data/models/models.dart';
import 'package:front_openerp/presentation/pages/auth/login_page.dart';
import 'package:front_openerp/presentation/pages/home_page.dart';
import 'package:front_openerp/presentation/providers/providers.dart';
import 'package:provider/provider.dart';

class SelecionarTenantPage extends StatelessWidget {
  const SelecionarTenantPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final contas = authProvider.contas;
    final primeiroConta = contas.isNotEmpty ? contas.first : null;
    final usuario = authProvider.usuario;

    final nomeExibicao = primeiroConta?.nome.isNotEmpty == true
        ? primeiroConta!.nome
        : primeiroConta?.email.isNotEmpty == true
            ? primeiroConta!.email
            : usuario?.nome ?? usuario?.email ?? 'Usuário';

    return Scaffold(
      appBar: AppBar(title: const Text('Selecionar Empresa')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Text(
              'Olá, $nomeExibicao!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Você tem acesso a ${contas.length} empresa(s). Selecione qual deseja acessar:',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Lista de Empresas/Contas
            Expanded(
              child: ListView.separated(
                itemCount: contas.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final conta = contas[index];
                  return _ContaCard(
                    conta: conta,
                    onTap: () => _selecionarEmpresa(context, conta.tenantId),
                  );
                },
              ),
            ),

            // Botão Sair
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text('Sair', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selecionarEmpresa(BuildContext context, int tenantId) async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.selectTenant(tenantId);

    if (success && context.mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Erro ao selecionar empresa'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _ContaCard extends StatelessWidget {
  final LoginConta conta;
  final VoidCallback onTap;

  const _ContaCard({required this.conta, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pessoa = conta.nome.isNotEmpty ? conta.nome : conta.email;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícone/Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: pessoa.isNotEmpty
                      ? Text(
                          pessoa[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        )
                      : const Icon(Icons.business, color: Colors.blue),
                ),
              ),
              const SizedBox(width: 16),

              // Informações
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Empresa #${conta.tenantId}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      conta.roleLabel,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    if (conta.email.isNotEmpty)
                      Text(
                        conta.email,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // Seta de seleção
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

