import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CaissierBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CaissierBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomNavigationBar(
          backgroundColor: AppTheme.surface,
          currentIndex: currentIndex,
          selectedItemColor: AppTheme.secondary,
          unselectedItemColor: AppTheme.textSecondary,
          selectedFontSize: 11.0,
          unselectedFontSize: 10.0,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          onTap: onTap,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.space_dashboard_rounded),
              label: 'Tableau',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'Historique',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.payments_rounded),
              label: 'Versement',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_parking_rounded),
              label: 'Stationnement',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Rapport',
            ),
          ],
        ),
      ),
    );
  }
}
