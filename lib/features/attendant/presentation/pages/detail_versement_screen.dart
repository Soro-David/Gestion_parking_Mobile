import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/versement_model.dart';
import '../providers/agent_versement_provider.dart';

class AgentDetailVersementScreen extends StatefulWidget {
  final int versementId;

  const AgentDetailVersementScreen({super.key, required this.versementId});

  @override
  State<AgentDetailVersementScreen> createState() =>
      _AgentDetailVersementScreenState();
}

class _AgentDetailVersementScreenState
    extends State<AgentDetailVersementScreen> {
  late Future<VersementDetailModel> _futureDetail;

  @override
  void initState() {
    super.initState();
    _futureDetail = AgentVersementProvider.repository
        .getVersementDetail(widget.versementId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Détails Versement',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Inter',
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E1E2C), Color(0xFF232539)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder<VersementDetailModel>(
        future: _futureDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: Colors.redAccent, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _futureDetail = AgentVersementProvider.repository
                              .getVersementDetail(widget.versementId);
                        });
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Réessayer'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary),
                    ),
                  ],
                ),
              ),
            );
          }

          final detail = snapshot.data!;
          final isValide = detail.status.toLowerCase() == 'validé' ||
              detail.status.toLowerCase() == 'valide' ||
              detail.status.toLowerCase() == 'paid';
          final statusColor =
              isValide ? Colors.greenAccent : Colors.orangeAccent;
          final statusIcon =
              isValide ? Icons.check_circle_rounded : Icons.pending_rounded;
          final statusLabel = isValide ? 'Versement Validé' : 'En attente';

          final formattedDate =
              '${detail.date.day.toString().padLeft(2, '0')}/'
              '${detail.date.month.toString().padLeft(2, '0')}/'
              '${detail.date.year} '
              '${detail.date.hour.toString().padLeft(2, '0')}:'
              '${detail.date.minute.toString().padLeft(2, '0')}';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── En-tête Statut ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 24, horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(statusIcon, color: statusColor, size: 40),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          statusLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${detail.amount.toStringAsFixed(0)} FCFA',
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Informations du Versement ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.secondary
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                    Icons.receipt_long_rounded,
                                    color: AppTheme.secondary,
                                    size: 18),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'INFORMATIONS',
                                style: TextStyle(
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
                        const SizedBox(height: 4),
                        _buildInfoRow(
                          icon: Icons.tag_rounded,
                          label: 'ID Versement',
                          value: '#${detail.id}',
                        ),
                        _buildDivider(),
                        _buildInfoRow(
                          icon: Icons.calendar_today_rounded,
                          label: 'Date & Heure',
                          value: formattedDate,
                        ),
                        _buildInfoRow(
                          icon: Icons.payments_rounded,
                          label: 'Montant versé',
                          value: '${detail.amount.toStringAsFixed(0)} FCFA',
                          valueColor: statusColor,
                        ),
                        if (detail.reste > 0) ...[
                          _buildDivider(),
                          _buildInfoRow(
                            icon: Icons.money_off_rounded,
                            label: 'Reste à payer',
                            value: '${detail.reste.toStringAsFixed(0)} FCFA',
                            valueColor: Colors.redAccent,
                          ),
                        ],
                        _buildDivider(),
                        _buildInfoRow(
                          icon: Icons.info_outline_rounded,
                          label: 'Statut',
                          value: detail.status,
                          valueColor: statusColor,
                        ),
                        if (detail.info.isNotEmpty) ...[
                          _buildDivider(),
                          _buildInfoRow(
                            icon: Icons.notes_rounded,
                            label: 'Note',
                            value: detail.info,
                          ),
                        ],
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Bouton Télécharger le reçu ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.download_rounded,
                                  color: Colors.white, size: 20),
                              SizedBox(width: 10),
                              Text('Téléchargement du reçu en cours...'),
                            ],
                          ),
                          backgroundColor: AppTheme.secondary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primary, AppTheme.secondary],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.download_rounded,
                              color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Télécharger le reçu',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 90),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 1,
        color: Colors.white.withValues(alpha: 0.06),
      ),
    );
  }
}
