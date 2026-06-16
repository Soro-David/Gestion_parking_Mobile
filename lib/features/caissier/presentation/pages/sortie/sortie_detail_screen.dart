import 'package:flutter/material.dart';
import 'package:parking_mobile/core/theme/app_theme.dart';
import 'package:parking_mobile/shared/domain/entities/parking_exit.dart';

class CaissierSortieDetailScreen extends StatelessWidget {
  final ParkingExit exit;

  const CaissierSortieDetailScreen({super.key, required this.exit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Sortie Détail')),
      body: const Center(child: Text('Sortie détail')),
    );
  }
}
