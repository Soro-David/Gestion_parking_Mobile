import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/token_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/caissier_report.dart';
import '../providers/caissier_report_provider.dart';

class CashierReportsScreen extends StatefulWidget {
  const CashierReportsScreen({super.key});

  @override
  State<CashierReportsScreen> createState() => _CashierReportsScreenState();
}

class _CashierReportsScreenState extends State<CashierReportsScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  CaissierReportData? _reportData;

  String _selectedPeriod = 'jour'; // 'jour', 'mois', 'annee', 'custom'
  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  Future<void> _fetchReport({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final fromStr = _dateFrom != null
          ? '${_dateFrom!.year}-${_dateFrom!.month.toString().padLeft(2, '0')}-${_dateFrom!.day.toString().padLeft(2, '0')}'
          : null;
      final toStr = _dateTo != null
          ? '${_dateTo!.year}-${_dateTo!.month.toString().padLeft(2, '0')}-${_dateTo!.day.toString().padLeft(2, '0')}'
          : null;

      final data = await CaissierReportProvider.repository.getReport(
        periode: _selectedPeriod,
        dateFrom: fromStr,
        dateTo: toStr,
        forceRefresh: forceRefresh,
      );

      setState(() {
        _reportData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateFrom(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateFrom ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _dateFrom) {
      setState(() {
        _dateFrom = picked;
        if (_dateTo != null && _dateFrom!.isAfter(_dateTo!)) {
          _dateTo = null;
        }
      });
      if (_dateTo != null) {
        _fetchReport();
      }
    }
  }

  Future<void> _selectDateTo(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateTo ?? _dateFrom ?? DateTime.now(),
      firstDate: _dateFrom ?? DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _dateTo) {
      setState(() {
        _dateTo = picked;
      });
      _fetchReport();
    }
  }

  Future<void> _exportReport(String type) async {
    final token = await TokenService.getToken();
    if (!mounted) return;
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez vous reconnecter.')),
      );
      return;
    }

    final fromStr = _dateFrom != null
        ? '${_dateFrom!.year}-${_dateFrom!.month.toString().padLeft(2, '0')}-${_dateFrom!.day.toString().padLeft(2, '0')}'
        : '';
    final toStr = _dateTo != null
        ? '${_dateTo!.year}-${_dateTo!.month.toString().padLeft(2, '0')}-${_dateTo!.day.toString().padLeft(2, '0')}'
        : '';

    final endpoint = type == 'pdf' ? 'pdf' : 'csv';
    final url = '${ApiConstants.baseUrl}/api/caissier/reports/export/$endpoint'
        '?token=$token'
        '&periode=$_selectedPeriod'
        '&date_from=$fromStr'
        '&date_to=$toStr';

    debugPrint('Launching export URL: $url');

    try {
      final uri = Uri.parse(url);
      final canLaunch = await canLaunchUrl(uri);
      if (!mounted) return;
      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir l\'URL de téléchargement.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du téléchargement : $e')),
      );
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '--/--/----';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateTimeString(DateTime? dateTime) {
    if (dateTime == null) return '—';
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── En-tête de la Page ──
        _buildHeader(),

        // ── Filtres de Périodes ──
        _buildFilters(),

        // ── Contenu Principal (Rapport) ──
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _fetchReport(forceRefresh: true),
            color: AppTheme.primary,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : _errorMessage.isNotEmpty
                    ? _buildErrorView()
                    : _buildReportContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rapports Caissier',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _reportData != null
                ? 'Période : ${_reportData!.dateFrom} au ${_reportData!.dateTo}'
                : 'Sélectionnez une période pour analyser les recettes.',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPeriodChip('jour', 'Jour'),
              _buildPeriodChip('mois', 'Mois'),
              _buildPeriodChip('annee', 'Année'),
              _buildPeriodChip('custom', 'Perso.'),
            ],
          ),
          if (_selectedPeriod == 'custom') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDateFrom(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 16, color: AppTheme.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Début', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontFamily: 'Inter')),
                                Text(_formatDate(_dateFrom), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87, fontFamily: 'Inter')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDateTo(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 16, color: AppTheme.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Fin', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontFamily: 'Inter')),
                                Text(_formatDate(_dateTo), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87, fontFamily: 'Inter')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String value, String label) {
    final isSelected = _selectedPeriod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = value;
          if (value != 'custom') {
            _dateFrom = null;
            _dateTo = null;
            _fetchReport();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontFamily: 'Inter',
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.black87, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _fetchReport(forceRefresh: true),
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportContent() {
    if (_reportData == null) return const SizedBox();

    final stats = _reportData!.stats;
    final sessions = _reportData!.sessions;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Grille des Statistiques Financières ──
          _buildStatsGrid(stats),

          const SizedBox(height: 24),

          // ── Boutons d'exportation ──
          _buildExportActions(),

          const SizedBox(height: 28),

          // ── Liste des Transactions ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Détail des stationnements',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Inter',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${sessions.length}',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (sessions.isEmpty)
            _buildEmptyState()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sessions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final session = sessions[index];
                return _buildSessionCard(session);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(CaissierReportStats stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Encaissé',
                value: '${stats.totalMontant.toStringAsFixed(0)} FCFA',
                icon: Icons.payments_rounded,
                color: const Color(0xFF00E5FF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Transactions',
                value: '${stats.totalSessions}',
                icon: Icons.receipt_long_rounded,
                color: const Color(0xFFE040FB),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Reversé',
                value: '${stats.totalReverse.toStringAsFixed(0)} FCFA',
                icon: Icons.check_circle_rounded,
                color: Colors.greenAccent[700]!,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Non Reversé',
                value: '${stats.totalNonReverse.toStringAsFixed(0)} FCFA',
                icon: Icons.pending_actions_rounded,
                color: Colors.amber[700]!,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _exportReport('pdf'),
            icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
            label: const Text('Export PDF', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 2,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _exportReport('csv'),
            icon: const Icon(Icons.grid_on_rounded, size: 18),
            label: const Text('Export Excel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_rounded, color: Colors.grey[400], size: 48),
          const SizedBox(height: 16),
          const Text(
            'Aucun stationnement trouvé',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Aucune transaction enregistrée pour cette période.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontFamily: 'Inter',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(CaissierReportSession session) {
    final isReversed = session.reversementId != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: Colors.grey[150] ?? const Color(0xFFF0F2F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Plaque & Statut ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  session.licensePlate.toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    letterSpacing: 1.0,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isReversed
                      ? Colors.greenAccent[100]!.withValues(alpha: 0.6)
                      : Colors.orangeAccent[100]!.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isReversed ? Icons.check_circle_rounded : Icons.pending_rounded,
                      color: isReversed ? Colors.green[800] : Colors.orange[800],
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isReversed ? 'Reversé' : 'Non reversé',
                      style: TextStyle(
                        color: isReversed ? Colors.green[800] : Colors.orange[800],
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Infos Véhicule & Parking ──
          Row(
            children: [
              Expanded(
                child: _buildSessionSubInfo(
                  icon: Icons.directions_car_rounded,
                  label: 'Véhicule',
                  value: session.marque != null && session.modele != null
                      ? '${session.marque} ${session.modele}'
                      : (session.marque ?? session.modele ?? '—'),
                ),
              ),
              Expanded(
                child: _buildSessionSubInfo(
                  icon: Icons.local_parking_rounded,
                  label: 'Parking',
                  value: session.parkingName,
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFF0F2F5)),
          ),

          // ── Dates Entrée & Sortie ──
          Row(
            children: [
              Expanded(
                child: _buildSessionSubInfo(
                  icon: Icons.login_rounded,
                  label: 'Entrée',
                  value: _formatDateTimeString(session.startedAt),
                ),
              ),
              Expanded(
                child: _buildSessionSubInfo(
                  icon: Icons.logout_rounded,
                  label: 'Sortie',
                  value: _formatDateTimeString(session.endedAt),
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFF0F2F5)),
          ),

          // ── Durée & Montant ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer_rounded, color: AppTheme.textSecondary, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    session.durationMinutes != null ? '${session.durationMinutes} min' : '—',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              Text(
                '${session.amount.toStringAsFixed(0)} FCFA',
                style: const TextStyle(
                  color: AppTheme.accent,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionSubInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontFamily: 'Inter',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
