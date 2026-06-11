import 'package:flutter/material.dart';
import 'stationnements_en_cours_screen.dart';

/// Point d'entrée de l'onglet "Stationnement" pour l'agent.
/// Affiche la liste live des stationnements en cours depuis l'API.
class AgentStationnementScreen extends StatelessWidget {
  const AgentStationnementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AgentStationnementEnCoursScreen();
  }
}
