import 'package:flutter/material.dart';
import 'package:parking_mobile/core/theme/app_theme.dart';
import 'package:parking_mobile/features/caissier/presentation/widgets/caissier_bottom_navigation_bar.dart';
import 'package:parking_mobile/features/caissier/presentation/pages/scan/scan_screen.dart';
import 'package:parking_mobile/features/caissier/presentation/pages/dashboard/dashboard_screen.dart';
import 'package:parking_mobile/features/caissier/presentation/pages/historique/historique_screen.dart';
import 'package:parking_mobile/features/caissier/presentation/pages/versement/versement_screen.dart';
import 'package:parking_mobile/features/caissier/presentation/pages/stationnement/stationnement_screen.dart';
import 'package:parking_mobile/features/caissier/presentation/pages/reports_screen.dart';

class CaissierHomeScreen extends StatefulWidget {
  const CaissierHomeScreen({super.key});

  @override
  State<CaissierHomeScreen> createState() => _CaissierHomeScreenState();
}

class _CaissierHomeScreenState extends State<CaissierHomeScreen> {
  int _currentIndex = 0;
  bool _isScanVisible = false;

  final List<Widget> _screens = const [
    CaissierDashboardScreen(),      // 0 - Tableau
    CaissierHistoryScreen(),        // 1 - Historique
    CaissierVersementScreen(),      // 2 - Versement
    CaissierStationnementScreen(),  // 3 - Stationnement
    CashierReportsScreen(),         // 4 - Rapport
  ];

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
      _isScanVisible = false;
    });
  }

  void _toggleScanner() {
    setState(() {
      _isScanVisible = !_isScanVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBody: true,
      body: _isScanVisible
          ? CaissierScanScreen(onClose: _toggleScanner)
          : IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
      bottomNavigationBar: _isScanVisible
          ? null
          : CaissierBottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onTabChanged,
            ),
      floatingActionButton: _isScanVisible
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 38),
              child: FloatingActionButton(
                onPressed: _toggleScanner,
                backgroundColor: AppTheme.secondary,
                foregroundColor: Colors.white,
                elevation: 6,
                shape: const CircleBorder(),
                child: const Icon(Icons.qr_code_scanner_rounded, size: 28),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// Backward compatibility wrapper for CashierHomeScreen
class CashierHomeScreen extends StatelessWidget {
  const CashierHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CaissierHomeScreen();
  }
}
