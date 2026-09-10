// lib/presentation/pages/auth/login_page.dart
// Refatorado eTools - OpenERP
import 'package:flutter/material.dart';
import 'package:front_openerp/presentation/pages/auth/selecionar_tenant_page.dart';
import 'package:front_openerp/presentation/pages/home_page.dart';
import 'package:front_openerp/presentation/providers/providers.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'etoolstec@etoolstec.com.br');
  final _passwordController = TextEditingController(text: 'admin123');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(_emailController.text.trim(), _passwordController.text.trim());

    if (!success || !mounted) return;

    if (authProvider.precisaSelecionarConta) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SelecionarTenantPage()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isLoading = authProvider.isLoading;
    final error = authProvider.error;
    final isWeb = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryDark, AppColors.primary, Color(0xFF2A6ACF)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWeb ? 1100 : double.infinity),
            child: isWeb
                ? Row(
                    children: [
                      // Lado esquerdo - branding
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(48),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.all(12),
                                child: Image.asset('assets/Icone_azul_500x500.png', errorBuilder: (_, _, _) => const Icon(Icons.bolt, size: 40, color: AppColors.primary)),
                              ),
                              const SizedBox(height: 24),
                              const Text('OpenERP', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Text('ERPCloud', style: TextStyle(fontSize: 16, color: Colors.white70, letterSpacing: 2, fontWeight: FontWeight.w600)),
                                  const SizedBox(width: 12),
                                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
                                  const SizedBox(width: 12),
                                  const Text('by eTools Tecnologia', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700, fontSize: 14)),
                                ],
                              ),
                              const SizedBox(height: 24),
                              const Text('Soluções inteligentes\npara sua empresa.', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700, height: 1.2)),
                              const SizedBox(height: 16),
                              const Text('Gerencie pedidos, clientes e produtos em um só lugar.', style: TextStyle(color: Colors.white70, fontSize: 14)),
                              const SizedBox(height: 40),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.12))),
                                child: const Row(
                                  children: [
                                    Icon(Icons.verified_user_outlined, color: Colors.white70, size: 20),
                                    SizedBox(width: 12),
                                    Expanded(child: Text('Acesso seguro com multi-tenant e auditoria completa.', style: TextStyle(color: Colors.white70, fontSize: 12))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Lado direito - form
                      Expanded(child: _buildFormCard(isLoading, error, isWeb)),
                    ],
                  )
                : _buildFormCard(isLoading, error, isWeb),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(bool isLoading, String? error, bool isWeb) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isWeb ? 32 : 24),
        child: Container(
          constraints: BoxConstraints(maxWidth: isWeb ? 420 : double.infinity),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 30, offset: const Offset(0, 10))]),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isWeb) ...[
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.storefront, size: 32, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                const Text('Bem-vindo!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                const SizedBox(height: 6),
                const Text('Faça login para acessar o dashboard', style: TextStyle(fontSize: 13, color: AppColors.textGrey)),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', hintText: 'seu@email.com', prefixIcon: Icon(Icons.email_outlined, size: 20)),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Digite seu email';
                    if (!value.contains('@')) return 'Email inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Digite sua senha';
                    if (value.length < 6) return 'Senha deve ter no mínimo 6 caracteres';
                    return null;
                  },
                  onFieldSubmitted: (_) => _login(),
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFFECACA))),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, size: 16, color: AppColors.error),
                        const SizedBox(width: 8),
                        Expanded(child: Text(error, style: const TextStyle(color: AppColors.error, fontSize: 12))),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: isLoading ? null : _login,
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Entrar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/Icone_azul_500x500.png', width: 14, height: 14, errorBuilder: (_, _, _) => const Icon(Icons.bolt, size: 12, color: AppColors.primary)),
                    const SizedBox(width: 6),
                    const Text('eTools Tecnologia • v3.2.1', style: TextStyle(color: AppColors.textGrey, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
