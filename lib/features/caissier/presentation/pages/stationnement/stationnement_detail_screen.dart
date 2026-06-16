import 'package:flutter/material.dart';
import 'package:parking_mobile/core/theme/app_theme.dart';
// removed unused import

class CaissierStationnementDetailScreen extends StatelessWidget {
  final Map<String, dynamic> stationnement;

  const CaissierStationnementDetailScreen({super.key, required this.stationnement});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Détail Stationnement')),
      body: const Center(child: Text('Détail')),
    );
  }
}
