import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parking_mobile/core/theme/app_theme.dart';
import 'package:parking_mobile/shared/domain/entities/parking_entry.dart';
import 'package:parking_mobile/features/caissier/presentation/providers/caissier_stationnement_provider.dart';
import 'package:parking_mobile/features/agent/presentation/providers/agent_stationnement_provider.dart';
import 'package:parking_mobile/shared/widgets/signalement_bottom_sheet.dart';

/// Page de détail d'un stationnement en cours.
/// Utilisée à la fois par le Caissier et l'Agent.
class StationnementDetailPage extends StatelessWidget {
  final ParkingEntry entry;
  final bool isAgent;

  const StationnementDetailPage({
    super.key,
    required this.entry,
    required this.isAgent,
  });

  String _formatDuration(DateTime entryTime) {
    final diff = DateTime.now().difference(entryTime);
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    if (h == 0) return '$m min';
    return '${h}h ${m.toString().padLeft(2, '0')}m';
  }

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year à $h:$m';
  }

  /// Calcule le coût estimé basé sur le tarif horaire réel du parking.
  /// Si [pricePerHour] est null, renvoie null (montant inconnu).
  int? _estimatedCost(DateTime entryTime, double? pricePerHour) {
    if (pricePerHour == null) return null;
    final diff = DateTime.now().difference(entryTime);
    // On arrondit à l'heure supérieure, minimum 1h
    final hours = diff.inMinutes <= 0 ? 1 : ((diff.inMinutes / 60.0).ceil());
    return (hours * pricePerHour).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Détail du stationnement',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 26),
            tooltip: 'Signaler un problème',
            onPressed: () {
              showModalBottomSheet<bool>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => SignalementBottomSheet(
                  licensePlate: entry.licensePlate,
                  parkingId: entry.parkingId ?? 1,
                  parentContext: context,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── En-tête plaque + véhicule ───────────────────────────
            _VehicleHeader(entry: entry),

            const SizedBox(height: 24),

            // ── Section détails ─────────────────────────────────────
            _buildSectionCard(
              title: 'TICKET DE STATIONNEMENT',
              icon: Icons.receipt_long_rounded,
              items: [
                _InfoRow(
                  icon: Icons.confirmation_number_rounded,
                  label: 'N° de Ticket',
                  value: entry.ticketNumber,
                  valueColor: AppTheme.accent,
                ),
                const _Divider(),
                _InfoRow(
                  icon: Icons.access_time_filled_rounded,
                  label: "Heure d'entrée",
                  value: _formatDateTime(entry.entryTime),
                ),
                const _Divider(),
                _InfoRow(
                  icon: Icons.hourglass_top_rounded,
                  label: 'Durée de présence',
                  value: _formatDuration(entry.entryTime),
                ),
                const _Divider(),
                _InfoRow(
                  icon: Icons.location_on_rounded,
                  label: 'Zone / Parking',
                  value: entry.zone.isNotEmpty ? entry.zone : 'Non spécifié',
                ),
                const _Divider(),
                _InfoRow(
                  icon: Icons.person_rounded,
                  label: 'Agent',
                  value: entry.agentName?.isNotEmpty == true
                      ? entry.agentName!
                      : 'Non spécifié',
                ),
                if (entry.vehicleType.isNotEmpty) ...[
                  const _Divider(),
                  _InfoRow(
                    icon: Icons.directions_car_rounded,
                    label: 'Véhicule',
                    value: entry.vehicleType,
                  ),
                ],
                if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                  const _Divider(),
                  _InfoRow(
                    icon: Icons.description_rounded,
                    label: 'Observations',
                    value: entry.notes!,
                  ),
                ],
              ],
            ),

            const SizedBox(height: 20),

            // ── Estimation ──────────────────────────────────────────
            _buildSectionCard(
              title: 'ESTIMATION',
              icon: Icons.attach_money_rounded,
              items: [
                _InfoRow(
                  icon: Icons.monetization_on_rounded,
                  label: 'Montant estimé',
                  value: _estimatedCost(entry.entryTime, entry.pricePerHour) != null
                      ? '${_estimatedCost(entry.entryTime, entry.pricePerHour)} FCFA'
                      : 'N/A',
                  valueColor: AppTheme.secondary,
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Bouton Enregistrer la sortie ───────────────────────────
              _ActionButton(
                icon: Icons.logout_rounded,
                label: 'Enregistrer la sortie',
                gradient: const LinearGradient(
                  colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                ),
                onTap: () {
                  showModalBottomSheet<bool>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => _PaymentBottomSheet(
                      entry: entry,
                      estimatedCost: _estimatedCost(entry.entryTime, entry.pricePerHour) ?? 0,
                      isAgent: isAgent,
                      parentContext: context,
                    ),
                  ).then((success) {
                    if (success == true && context.mounted) {
                      Navigator.of(context).pop(); // Retour à la liste et actualiser
                    }
                  });
                },
              ),

              const SizedBox(height: 12),

              // ── Bouton Signaler ─────────────────────────────────────
              _ActionButton(
                icon: Icons.warning_amber_rounded,
                label: 'Signaler un problème',
                isOutlined: true,
                outlineColor: Colors.redAccent,
                backgroundColor: Colors.redAccent.withValues(alpha: 0.15),
                onTap: () {
                  showModalBottomSheet<bool>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => SignalementBottomSheet(
                      licensePlate: entry.licensePlate,
                      parkingId: entry.parkingId ?? 1,
                      parentContext: context,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppTheme.secondary, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          ...items,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────── Sous-widgets ────────────────────────────────────

class _VehicleHeader extends StatelessWidget {
  final ParkingEntry entry;
  const _VehicleHeader({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icône voiture
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.secondary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.directions_car_rounded,
                color: AppTheme.secondary, size: 40),
          ),
          const SizedBox(height: 14),
          // Type de véhicule
          if (entry.vehicleType.isNotEmpty)
            Text(
              entry.vehicleType,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          const SizedBox(height: 12),
          // Plaque immatriculée style réel
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primary, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'SN',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  entry.licensePlate,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Badge statut
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'En stationnement',
                  style: TextStyle(
                    color: Color(0xFF22C55E),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                fontFamily: 'Inter',
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 1,
        color: Colors.white.withValues(alpha: 0.06),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Gradient? gradient;
  final bool isOutlined;
  final Color? outlineColor;
  final Color? backgroundColor;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.gradient,
    this.isOutlined = false,
    this.outlineColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isOutlined ? null : gradient,
          color: isOutlined ? (backgroundColor ?? Colors.transparent) : backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: isOutlined
              ? Border.all(color: outlineColor ?? Colors.white, width: 1.5)
              : null,
          boxShadow: isOutlined
              ? null
              : [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isOutlined ? (outlineColor ?? Colors.white) : Colors.white,
                size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color:
                    isOutlined ? (outlineColor ?? Colors.white) : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Widget — Bottom Sheet de paiement
// ═══════════════════════════════════════════════════════════════════
class _PaymentBottomSheet extends StatefulWidget {
  final ParkingEntry entry;
  final int estimatedCost;
  final bool isAgent;
  final BuildContext parentContext;

  const _PaymentBottomSheet({
    required this.entry,
    required this.estimatedCost,
    required this.isAgent,
    required this.parentContext,
  });

  @override
  State<_PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<_PaymentBottomSheet> {
  String _selectedMethod = 'cash';
  bool _isSubmitting = false;

  final Map<String, Map<String, dynamic>> _paymentMethods = {
    'cash': {
      'name': 'Espèces',
      'icon': Icons.payments_rounded,
      'isAsset': false,
    },
    'wave': {
      'name': 'Wave',
      'asset': 'assets/logos/wave.png',
      'isAsset': true,
    },
    'orange': {
      'name': 'Orange Money',
      'asset': 'assets/logos/orange_money.png',
      'isAsset': true,
    },
    'mtn': {
      'name': 'MTN MoMo',
      'asset': 'assets/logos/mtn_momo.png',
      'isAsset': true,
    },
    'moov': {
      'name': 'Moov Money',
      'asset': 'assets/logos/moov_money.png',
      'isAsset': true,
    },
  };

  String _formatDuration(DateTime entryTime) {
    final diff = DateTime.now().difference(entryTime);
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    if (h == 0) return '$m min';
    return '${h}h ${m.toString().padLeft(2, '0')}m';
  }

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year à $h:$m';
  }

  Future<void> _showReceiptDialog(
    BuildContext context,
    Map<String, dynamic> methodInfo,
    DateTime exitTime,
    ParkingEntry entry,
    int estimatedCost,
  ) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.print_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('Impression automatique du ticket de sortie...'),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          color: AppTheme.secondary,
                          size: 48,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'TICKET DE SORTIE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Paiement effectué',
                          style: TextStyle(
                            color: Color(0xFF22C55E),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: List.generate(
                      30,
                      (index) => Expanded(
                        child: Container(
                          color: index % 2 == 0 ? Colors.transparent : Colors.white24,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.primary, width: 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: const Text(
                              'SN',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            entry.licensePlate,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildReceiptRow('N° de Ticket', entry.ticketNumber),
                  _buildReceiptRow('Véhicule', entry.vehicleType.isNotEmpty ? entry.vehicleType : 'Non spécifié'),
                  _buildReceiptRow("Heure d'entrée", _formatDateTime(entry.entryTime)),
                  _buildReceiptRow("Heure de sortie", _formatDateTime(exitTime)),
                  _buildReceiptRow("Durée", _formatDuration(entry.entryTime)),
                  _buildReceiptRow("Mode de paiement", methodInfo['name'] as String),
                  _buildReceiptRow("Agent", entry.agentName ?? 'Non spécifié'),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(
                      30,
                      (index) => Expanded(
                        child: Container(
                          color: index % 2 == 0 ? Colors.transparent : Colors.white24,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'MONTANT PAYÉ',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                      Text(
                        '$estimatedCost FCFA',
                        style: const TextStyle(
                          color: AppTheme.secondary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.print_rounded, color: Colors.white, size: 20),
                              SizedBox(width: 10),
                              Text('Impression du ticket en cours...'),
                            ],
                          ),
                          backgroundColor: AppTheme.secondary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.print_rounded),
                    label: const Text(
                      'Réimprimer le ticket',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Fermer',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processCheckout() async {
    final parentCtx = widget.parentContext;
    final entry = widget.entry;
    final cost = widget.estimatedCost;
    final selectedMethodInfo = _paymentMethods[_selectedMethod]!;

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (widget.isAgent) {
        await AgentStationnementProvider.repository
            .checkoutParkingSession(entry.id, paymentMethod: _selectedMethod, amount: cost.toDouble());
      } else {
        await CaissierStationnementProvider.repository
            .checkoutParkingSession(entry.id, paymentMethod: _selectedMethod, amount: cost.toDouble());
      }

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });

      // Fermer le bottom sheet de paiement
      Navigator.of(context).pop(true);

      if (parentCtx.mounted) {
        // Afficher le message de succès
        ScaffoldMessenger.of(parentCtx).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text('Sortie enregistrée avec succès !', style: TextStyle(fontFamily: 'Inter')),
              ],
            ),
            backgroundColor: const Color(0xFF22C55E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );

        // Afficher le ticket/reçu et lancer l'impression automatique
        await _showReceiptDialog(parentCtx, selectedMethodInfo, DateTime.now(), entry, cost);

        // Fermer l'écran de détail pour retourner à la liste et actualiser
        if (parentCtx.mounted) {
          Navigator.of(parentCtx).pop(true);
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });

      // Fermer le bottom sheet de paiement
      Navigator.of(context).pop(false);

      if (parentCtx.mounted) {
        // Afficher le message d'erreur
        ScaffoldMessenger.of(parentCtx).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    e.toString().replaceAll('Exception: ', ''),
                    style: const TextStyle(fontFamily: 'Inter'),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;
    final keyboardInset = mediaQuery.viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A2540),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        24 + keyboardInset + (keyboardInset > 0 ? 0 : bottomPadding),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.payments_rounded,
                    color: Color(0xFF22C55E), size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'Enregistrer la sortie & Paiement',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.entry.licensePlate,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ticket: ${widget.entry.ticketNumber}',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontFamily: 'Inter',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Montant à payer',
                      style: TextStyle(
                        color: Colors.white54,
                        fontFamily: 'Inter',
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.estimatedCost} FCFA',
                      style: const TextStyle(
                        color: AppTheme.secondary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'CHOISIR LE MODE DE PAIEMENT',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          ..._paymentMethods.entries.map((entry) {
            final key = entry.key;
            final data = entry.value;
            final isSelected = _selectedMethod == key;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: _isSubmitting
                    ? null
                    : () {
                        setState(() {
                          _selectedMethod = key;
                        });
                      },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.secondary.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.secondary
                          : Colors.white.withValues(alpha: 0.08),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: data['isAsset'] as bool
                            ? Image.asset(
                                data['asset'] as String,
                                fit: BoxFit.contain,
                              )
                            : Icon(
                                data['icon'] as IconData,
                                color: const Color(0xFF0F172A),
                                size: 24,
                              ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          data['name'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppTheme.secondary : Colors.white24,
                            width: 2,
                          ),
                          color: isSelected ? AppTheme.secondary : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _processCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                disabledBackgroundColor: const Color(0xFF22C55E).withValues(alpha: 0.5),
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Valider le paiement',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
