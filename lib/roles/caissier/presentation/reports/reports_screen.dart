import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class CashierReportsScreen extends StatelessWidget {
  const CashierReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      children: [
        const Text(
          'Rapports caissier',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Synthese des operations journalieres de caisse.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 16),
        _buildReportCard('Total encaisse', '128 400 FCFA', Icons.payments_rounded),
        const SizedBox(height: 12),
        _buildReportCard('Transactions', '84', Icons.receipt_long_rounded),
        const SizedBox(height: 12),
        _buildReportCard('Paiements en attente', '7', Icons.pending_actions_rounded),
      ],
    );
  }

  Widget _buildReportCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
