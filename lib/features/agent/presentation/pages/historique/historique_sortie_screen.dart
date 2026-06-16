import 'package:flutter/material.dart';
import 'package:parking_mobile/core/theme/app_theme.dart';

class HistoriqueSortieScreen extends StatelessWidget {
  const HistoriqueSortieScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.logout_rounded, size: 72, color: AppTheme.secondary),
              SizedBox(height: 24),
              Text(
                'Aucune sortie enregistrée pour le moment.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
