import 'package:flutter/material.dart';
import 'package:parking_mobile/core/theme/app_theme.dart';
import 'package:parking_mobile/shared/domain/entities/parking_entry.dart';

/// Carte de stationnement actif, identique pour le Caissier et l'Agent.
/// [onTap] est appelé quand l'utilisateur appuie sur la carte.
class ParkingEntryCard extends StatelessWidget {
  final ParkingEntry entry;
  final VoidCallback onTap;

  const ParkingEntryCard({
    super.key,
    required this.entry,
    required this.onTap,
  });

  String _formatDuration(DateTime entryTime) {
    final diff = DateTime.now().difference(entryTime);
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    if (h > 0) return '${h}h ${m.toString().padLeft(2, '0')}min';
    if (m > 0) return '${m}min';
    return "Vient d'arriver";
  }

  String _formatHeure(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);
    if (date == today) return "Aujourd'hui";
    final yesterday = today.subtract(const Duration(days: 1));
    if (date == yesterday) return 'Hier';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Color _durationColor(DateTime entryTime) {
    final diff = DateTime.now().difference(entryTime);
    if (diff.inHours >= 4) return Colors.redAccent;
    if (diff.inHours >= 2) return Colors.orangeAccent;
    return const Color(0xFF22C55E);
  }

  /// Calcule le coût estimé sur la base du tarif horaire réel.
  /// Retourne null si le tarif n'est pas connu.
  int? _estimatedCost(DateTime entryTime, double? pricePerHour) {
    if (pricePerHour == null) return null;
    final diff = DateTime.now().difference(entryTime);
    final hours = diff.inMinutes <= 0 ? 1 : ((diff.inMinutes / 60.0).ceil());
    return (hours * pricePerHour).round();
  }

  @override
  Widget build(BuildContext context) {
    final durColor = _durationColor(entry.entryTime);
    final duree = _formatDuration(entry.entryTime);
    final heure = _formatHeure(entry.entryTime);
    final date = _formatDate(entry.entryTime);
    final cost = _estimatedCost(entry.entryTime, entry.pricePerHour);

    final initials = entry.licensePlate.length >= 2
        ? entry.licensePlate.substring(0, 2).toUpperCase()
        : entry.licensePlate.toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: durColor.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Avatar initiales ─────────────────────────
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // ── Infos gauche ─────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Plaque
                      Text(
                        entry.licensePlate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Zone
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 13, color: AppTheme.textSecondary),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              entry.zone.isNotEmpty ? entry.zone : 'Parking',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                                fontFamily: 'Inter',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      // Date + heure
                      Text(
                        '$date · $heure',
                        style: TextStyle(
                          color:
                              AppTheme.textSecondary.withValues(alpha: 0.55),
                          fontSize: 11,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Infos droite ──────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Badge statut "Actif"
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Actif',
                        style: TextStyle(
                          color: Color(0xFF22C55E),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Durée
                    Text(
                      duree,
                      style: TextStyle(
                        color: durColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Montant estimé
                    Text(
                      cost != null ? '~$cost FCFA' : '',
                      style: const TextStyle(
                        color: AppTheme.secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),

                // ── Chevron ───────────────────────────────────
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textSecondary.withValues(alpha: 0.6),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
