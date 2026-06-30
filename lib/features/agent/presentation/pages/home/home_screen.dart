import 'package:flutter/material.dart';
import 'package:parking_mobile/core/theme/app_theme.dart';
import 'package:parking_mobile/features/agent/presentation/pages/dashboard/dashboard_screen.dart';
import 'package:parking_mobile/features/agent/presentation/pages/historique/history_screen.dart';
import 'package:parking_mobile/features/agent/presentation/pages/scan/scan_screen.dart';
import 'package:parking_mobile/features/agent/presentation/pages/versement/versement_screen.dart';
import 'package:parking_mobile/features/agent/presentation/pages/stationnement/stationnement_screen.dart';
import 'package:parking_mobile/features/agent/presentation/widgets/custom_bottom_navigation_bar.dart';

class AgentHomeScreen extends StatefulWidget {
	const AgentHomeScreen({super.key});

	@override
	State<AgentHomeScreen> createState() => _AgentHomeScreenState();
}

class _AgentHomeScreenState extends State<AgentHomeScreen> {
	int _currentIndex = 0;
	bool _isScanVisible = false;

	List<Widget> get _screens => [
				const AgentDashboardScreen(),
				AgentHistoryScreen(isActive: _currentIndex == 1),
				const AgentVersementScreen(),
				const AgentStationnementScreen(),
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
					? AgentScanScreen(onClose: _toggleScanner)
					: IndexedStack(
							index: _currentIndex,
							children: _screens,
						),
			bottomNavigationBar: _isScanVisible
					? null
					: CustomBottomNavigationBar(
							currentIndex: _currentIndex,
							onTap: _onTabChanged,
						),
			floatingActionButton: _isScanVisible
					? null
					: FloatingActionButton(
							onPressed: _toggleScanner,
							backgroundColor: AppTheme.secondary,
							foregroundColor: Colors.white,
							elevation: 6,
							shape: const CircleBorder(),
							child: const Icon(Icons.qr_code_scanner_rounded, size: 28),
						),
			floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
		);
	}
}
