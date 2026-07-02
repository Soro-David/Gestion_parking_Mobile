import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:parking_mobile/core/theme/app_theme.dart';
import 'package:parking_mobile/shared/data/repositories/signalement_repository.dart';
import 'package:parking_mobile/shared/domain/entities/signalement.dart';
import 'package:parking_mobile/shared/notifications/domain/entities/app_notification.dart';
import 'package:parking_mobile/shared/notifications/presentation/cubit/notification_cubit.dart';

class NotificationDetailPage extends StatelessWidget {
  final AppNotification notification;

  const NotificationDetailPage({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    // Marquer la notification comme lue dès l'ouverture de la page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<NotificationCubit>().markAsRead(notification.id);
      }
    });

    final signalementIdStr = notification.data?['id'];
    final signalementId = signalementIdStr != null ? int.tryParse(signalementIdStr.toString()) : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: const Text(
          'Détail de la notification',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
            onPressed: () {
              _showDeleteConfirmation(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Header
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _typeColor(notification.type).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _typeIcon(notification.type),
                          color: _typeColor(notification.type),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _typeLabel(notification.type),
                              style: TextStyle(
                                color: _typeColor(notification.type),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(notification.createdAt),
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    notification.title,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Body
                  Text(
                    notification.body,
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            // Si c'est un signalement, charger et afficher le détail du véhicule signalé
            if (notification.type == 'rapport' && signalementId != null) ...[
              const SizedBox(height: 24),
              FutureBuilder<Signalement>(
                future: SignalementRepository().getSignalementById(signalementId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: AppTheme.primary),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Impossible de charger les détails du signalement : ${snapshot.error.toString().replaceAll('Exception: ', '')}',
                              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (snapshot.hasData) {
                    final signalement = snapshot.data!;
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'DÉTAILS DU VÉHICULE SIGNALÉ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Plaque d'immatriculation
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.primary, width: 2.5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: const Text(
                                      'SN',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    signalement.licensePlate,
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

                          _buildDetailRow('Motif', signalement.motif, isMultiLine: true),
                          _buildDetailRow('Parking', signalement.parkingName ?? 'Parking principal'),
                          _buildDetailRow('Signalé par', signalement.userName ?? 'Agent de service'),
                          _buildDetailRow('Date & Heure', _formatDate(signalement.createdAt)),
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isMultiLine = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: isMultiLine ? FontWeight.normal : FontWeight.w600,
              fontFamily: 'Inter',
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white10),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Supprimer la notification',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          content: const Text(
            'Voulez-vous vraiment supprimer cette notification ?',
            style: TextStyle(color: Color(0xFF475569)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Annuler', style: TextStyle(color: Color(0xFF64748B))),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.read<NotificationCubit>().deleteNotification(notification.id);
                context.pop(); // Retour à l'historique
              },
              child: const Text('Supprimer', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  IconData _typeIcon(String? type) {
    switch (type) {
      case 'entree':
        return Icons.login_rounded;
      case 'sortie':
        return Icons.logout_rounded;
      case 'paiement':
        return Icons.payment_rounded;
      case 'versement':
        return Icons.account_balance_wallet_rounded;
      case 'rapport':
        return Icons.bar_chart_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _typeColor(String? type) {
    switch (type) {
      case 'entree':
        return const Color(0xFF27AE60);
      case 'sortie':
        return const Color(0xFFEB5757);
      case 'paiement':
        return const Color(0xFF9B59B6);
      case 'versement':
        return const Color(0xFFF2994A);
      case 'rapport':
        return AppTheme.primary;
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _typeLabel(String? type) {
    switch (type) {
      case 'entree':
        return 'ENTRÉE DU VÉHICULE';
      case 'sortie':
        return 'SORTIE DU VÉHICULE';
      case 'paiement':
        return 'PAIEMENT';
      case 'versement':
        return 'VERSEMENT';
      case 'rapport':
        return 'SIGNALEMENT / RAPPORT';
      default:
        return 'NOTIFICATION';
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year à $hour:$minute';
  }
}
