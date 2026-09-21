// lib/presentation/layout/main_layout.dart
// Layout responsivo eTools - Web com sidebar + Topbar, Mobile com bottom nav
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class MainLayout extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Widget child;
  final String? title;

  const MainLayout({super.key, required this.currentIndex, required this.onTap, required this.child, this.title});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWeb = constraints.maxWidth > 800;

        if (isWeb) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Row(
              children: [
                // SIDEBAR eTools
                Container(
                  width: 268,
                  color: AppColors.primaryDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Image.asset(
                          'assets/images/Logo_openerp_3D.png',
                          width: double.infinity,
                          fit: BoxFit.fitWidth,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (_, _, _) => const Text(
                            'OpenERP',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Menu
                      _SideItem(
                        icon: Icons.dashboard_outlined,
                        label: 'Dashboard',
                        selected: currentIndex == 0,
                        onTap: () => onTap(0),
                      ),
                      _SideItem(
                        icon: Icons.shopping_cart_outlined,
                        label: 'Pedidos',
                        selected: currentIndex == 1,
                        onTap: () => onTap(1),
                      ),
                      _SideItem(
                        icon: Icons.people_outline,
                        label: 'Clientes',
                        selected: currentIndex == 2,
                        onTap: () => onTap(2),
                      ),
                      _SideItem(
                        icon: Icons.inventory_2_outlined,
                        label: 'Produtos',
                        selected: currentIndex == 3,
                        onTap: () => onTap(3),
                      ),
                      _SideItem(
                        icon: Icons.business_outlined,
                        label: 'Empresas',
                        selected: currentIndex == 4,
                        onTap: () => onTap(4),
                      ),
                      const Spacer(),
                      Container(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.1),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      const SizedBox(height: 12),
                      // Rodapé sidebar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                child: const Center(
                                  child: Text(
                                    'R',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Rafael Pasa',
                                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                    Text('Admin', style: TextStyle(color: Colors.white60, fontSize: 11)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          '© eTools Tecnologia v3.2.1',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 10),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                // CONTEÚDO
                Expanded(
                  child: Column(
                    children: [
                      // TOPBAR WEB
                      Container(
                        height: 68,
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Row(
                          children: [
                            Text(
                              title ?? _getTitle(currentIndex),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                                color: AppColors.textDark,
                              ),
                            ),
                            const Spacer(),
                            // Busca
                            Container(
                              width: 340,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const TextField(
                                decoration: InputDecoration(
                                  hintText: 'Buscar pedidos, clientes...',
                                  prefixIcon: Icon(Icons.search, size: 18, color: AppColors.textGrey),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.notifications_outlined, color: AppColors.textGrey),
                            ),
                            const SizedBox(width: 8),
                            const CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.primary,
                              child: Text('R', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 1, color: AppColors.border),
                      // Conteúdo centralizado com maxWidth
                      Expanded(
                        child: child,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // MOBILE
        return Scaffold(
          body: child,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10)],
            ),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: onTap,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textGrey,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart_outlined),
                  activeIcon: Icon(Icons.shopping_cart),
                  label: 'Pedidos',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline),
                  activeIcon: Icon(Icons.people),
                  label: 'Clientes',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_2_outlined),
                  activeIcon: Icon(Icons.inventory_2),
                  label: 'Produtos',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.business_outlined),
                  activeIcon: Icon(Icons.business),
                  label: 'Empresas',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getTitle(int i) {
    const titles = ['Dashboard', 'Pedidos', 'Clientes', 'Produtos', 'Empresas'];
    return titles[i.clamp(0, titles.length - 1)];
  }
}

class _SideItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SideItem({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: selected ? Border.all(color: Colors.white.withValues(alpha: 0.1)) : null,
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 20),
        title: Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
        ),
        trailing: selected
            ? Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
              )
            : null,
        onTap: onTap,
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
