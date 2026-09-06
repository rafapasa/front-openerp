// lib/presentation/pages/splash_page.dart
import 'package:flutter/material.dart';
import 'package:front_openerp/presentation/pages/auth/login_page.dart';
import 'package:front_openerp/presentation/pages/auth/selecionar_tenant_page.dart';
import 'package:front_openerp/presentation/pages/home_page.dart';
import 'package:front_openerp/presentation/providers/providers.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final isAuthenticated = authProvider.isAuthenticated;

    if (!isAuthenticated) {
      _navigateTo(LoginPage());
      return;
    }

    // Recuperar usuário do cache
    await authProvider.restoreSession();

    if (!mounted) return;

    // Se o login devolveu várias empresas e nenhuma foi selecionada,
    // exibe a tela de seleção; caso contrário vai direto para o Home.
    if (authProvider.precisaSelecionarConta) {
      _navigateTo(const SelecionarTenantPage());
    } else {
      _navigateTo(const HomePage());
    }
  }

  void _navigateTo(Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withValues(alpha: 0.7)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(60)),
                child: const Icon(Icons.storefront, size: 60, color: Colors.blue),
              ),
              const SizedBox(height: 24),
              const Text(
                'Front-OpenERP',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text('Conversation Commerce Dashboard', style: TextStyle(fontSize: 16, color: Colors.white70)),
              const SizedBox(height: 48),
              const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
