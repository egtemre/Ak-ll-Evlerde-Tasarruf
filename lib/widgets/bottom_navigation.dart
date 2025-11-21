import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomBottomNavigation extends StatelessWidget {
  const CustomBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.home,
                label: 'Anasayfa',
                route: '/dashboard',
                isActive: currentRoute == '/dashboard',
              ),
              _buildNavItem(
                context,
                icon: Icons.devices,
                label: 'Cihazlar',
                route: '/devices',
                isActive: currentRoute == '/devices',
              ),
              _buildNavItem(
                context,
                icon: Icons.bar_chart,
                label: 'Raporlar',
                route: '/reports',
                isActive: currentRoute == '/reports',
              ),
              _buildNavItem(
                context,
                icon: Icons.lightbulb,
                label: 'Öneriler',
                route: '/suggestions',
                isActive: currentRoute == '/suggestions',
              ),
              _buildNavItem(
                context,
                icon: Icons.settings,
                label: 'Ayarlar',
                route: '/settings',
                isActive: currentRoute == '/settings',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushReplacementNamed(context, route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppTheme.primaryColor : Colors.grey[500],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppTheme.primaryColor : Colors.grey[500],
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
