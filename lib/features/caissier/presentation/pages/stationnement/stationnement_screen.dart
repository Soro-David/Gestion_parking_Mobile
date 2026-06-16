import 'package:flutter/material.dart';
import 'package:parking_mobile/core/theme/app_theme.dart';
import 'package:parking_mobile/shared/domain/entities/parking_entry.dart';

class CaissierStationnementScreen extends StatefulWidget {
  const CaissierStationnementScreen({super.key});

  @override
  State<CaissierStationnementScreen> createState() => _CaissierStationnementScreenState();
}

class _CaissierStationnementScreenState extends State<CaissierStationnementScreen> {
  final List<ParkingEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    // load entries
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _entries.isEmpty
          ? const Center(child: Text('Aucun stationnement', style: TextStyle(color: Colors.white)))
          : ListView.builder(
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                final e = _entries[index];
                return ListTile(
                  title: Text(e.licensePlate, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(e.vehicleType, style: const TextStyle(color: Colors.white70)),
                );
              },
            ),
    );
  }
}
