// lib/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:front_openerp/presentation/pages/clientes/clientes_page.dart';
import 'package:front_openerp/presentation/pages/dashboard/dashboard_page.dart';
import 'package:front_openerp/presentation/pages/pedidos/pedidos_page.dart';
import 'package:front_openerp/presentation/pages/produtos/produtos_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const PedidosPage(),
    const ClientesPage(),
    const ProdutosPage(),
  ];

  final List<BottomNavigationBarItem> _bottomNavItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
    BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Pedidos'),
    BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Clientes'),
    BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Produtos'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: _bottomNavItems,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
