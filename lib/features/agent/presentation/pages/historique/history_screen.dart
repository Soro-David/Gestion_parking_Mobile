import 'package:flutter/material.dart';
import 'package:parking_mobile/core/theme/app_theme.dart';
import 'package:parking_mobile/features/agent/presentation/pages/historique/historique_entree_screen.dart';
import 'package:parking_mobile/features/agent/presentation/pages/historique/historique_sortie_screen.dart';

class AgentHistoryScreen extends StatelessWidget {
	final bool isActive;
	const AgentHistoryScreen({super.key, this.isActive = false});

	@override
	Widget build(BuildContext context) {
		return DefaultTabController(
			length: 2,
			child: Scaffold(
				backgroundColor: AppTheme.background,
				appBar: AppBar(
					backgroundColor: AppTheme.surface,
					elevation: 0,
					title: const Text(
						'Historique',
						style: TextStyle(
							fontFamily: 'Inter',
							color: Colors.white,
							fontSize: 22,
							fontWeight: FontWeight.bold,
						),
					),
					bottom: const TabBar(
						indicatorColor: AppTheme.secondary,
						labelColor: Colors.white,
						unselectedLabelColor: Colors.white70,
						tabs: [
							Tab(text: 'Entrée'),
							Tab(text: 'Sortie'),
						],
					),
				),
				body: TabBarView(
					children: [
						HistoriqueEntreeScreen(isActive: isActive),
						HistoriqueSortieScreen(isActive: isActive),
					],
				),
			),
		);
	}
}
