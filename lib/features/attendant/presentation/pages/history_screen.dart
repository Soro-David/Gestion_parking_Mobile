import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'historique_entree_screen.dart';
import 'historique_sortie_screen.dart';

class AgentHistoryScreen extends StatelessWidget {
  const AgentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // backgroundColor: const Color(0xFF1E1E2C),
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          //  toolbarHeight: 100,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E1E2C), Color(0xFF232539)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: const Text('Historique', style: TextStyle(fontFamily: 'Inter')),
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
        body: const TabBarView(
          children: [
            HistoriqueEntreeScreen(),
            HistoriqueSortieScreen(),
          ],
        ),
      ),
    );
  }
}
