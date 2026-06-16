import 'package:flutter/material.dart';
import 'package:parking_mobile/core/theme/app_theme.dart';
import 'package:parking_mobile/shared/domain/entities/parking_entry.dart';

class CaissierEntreeDetailScreen extends StatelessWidget {
  final ParkingEntry entry;

  const CaissierEntreeDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Entrée Détail')),
      body: const Center(child: Text('Entrée détail')), 
    );
  }
}
