import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

/// Andamio principal con barra de navegación inferior personalizada.
/// Muestra las 3 pestañas: Inicio, Mi Progreso y Guía, reflejando fielmente el diseño.
class MainScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(
              color: AppColors.textMuted.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                label: 'Inicio',
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                isSelected: currentIndex == 0,
                activeColor: AppColors.orangePrimary,
                onTap: () => _onTap(0),
              ),
              _NavBarItem(
                label: 'Mi Progreso',
                checkSuffix: true,
                icon: Icons.bar_chart_outlined,
                selectedIcon: Icons.bar_chart_rounded,
                isSelected: currentIndex == 1,
                activeColor: AppColors.steelBlue,
                onTap: () => _onTap(1),
              ),
              _NavBarItem(
                label: 'Guía',
                checkSuffix: true,
                icon: Icons.menu_book_outlined,
                selectedIcon: Icons.menu_book_rounded,
                isSelected: currentIndex == 2,
                activeColor: AppColors.steelBlue,
                onTap: () => _onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final String label;
  final bool checkSuffix;
  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.label,
    this.checkSuffix = false,
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isSelected ? selectedIcon : icon,
                size: 22,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isSelected && checkSuffix ? '$label ✓' : label,
              style: AppTypography.caption(
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              ).copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
