import 'package:flutter/material.dart';
import 'package:parking_mobile/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:parking_mobile/core/routes/route_names.dart';
import 'package:parking_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:parking_mobile/shared/domain/entities/user.dart';
import 'package:parking_mobile/features/caissier/presentation/providers/caissier_stat_provider.dart';
import 'package:parking_mobile/shared/domain/entities/parking_entry.dart';
import 'package:parking_mobile/features/caissier/presentation/providers/caissier_stationnement_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_mobile/shared/notifications/presentation/cubit/notification_cubit.dart';
import 'package:parking_mobile/shared/notifications/presentation/cubit/notification_state.dart';

class CaissierDashboardScreen extends StatefulWidget {
  const CaissierDashboardScreen({super.key});

  @override
  State<CaissierDashboardScreen> createState() => _CaissierDashboardScreenState();
}

class _CaissierDashboardScreenState extends State<CaissierDashboardScreen> {
  String _userName = 'Marc-Aurèle';
  String? _avatarUrl;
  String _totalEncaisser = '... FCFA';
  String _stationnements = '...';
  String _encaisseNonVerse = '... FCFA';
  String _dette = '... FCFA';
  List<ParkingEntry> _activeParkings = [];
  bool _isLoadingParkings = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadStats();
    _loadActiveParkings();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await CaissierStatProvider.repository.getStats();

      if (mounted) {
        setState(() {
          _totalEncaisser = '${stats.totalEncaisser.toStringAsFixed(0)} FCFA';
          _stationnements = '${stats.stationnements}';
          _encaisseNonVerse = '${stats.encaisseNonVerse.toStringAsFixed(0)} FCFA';
          _dette = '${stats.dette.toStringAsFixed(0)} FCFA';
        });
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
    }
  }

  Future<void> _loadProfile() async {
    try {
      final profileData = await AuthProvider.repository.getProfile();
      final user = profileData['user'] as Map<String, dynamic>?;
      if (user != null && mounted) {
        setState(() {
          final firstName = user['first_name'] ?? '';
          final lastName = user['name'] ?? '';
          _userName = '$firstName $lastName'.trim();
          if (_userName.isEmpty) {
            _userName = user['name'] ?? 'Caissier';
          }
          _avatarUrl = User.sanitizeAvatarUrl(user['avatar_url'] as String?);
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  int _estimatedCost(DateTime entryTime, double? pricePerHour) {
    final double rate = pricePerHour ?? 500.0;
    final diff = DateTime.now().difference(entryTime);
    final hours = diff.inMinutes <= 0 ? 1 : ((diff.inMinutes / 60.0).ceil());
    return (hours * rate).round();
  }

  Future<void> _loadActiveParkings() async {
    setState(() {
      _isLoadingParkings = true;
    });
    try {
      final parkings = await CaissierStationnementProvider.repository.getStationnementsEnCours();
      if (mounted) {
        setState(() {
          _activeParkings = parkings;
          _isLoadingParkings = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading active parkings: $e');
      if (mounted) {
        setState(() {
          _isLoadingParkings = false;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    await Future.wait([
      _loadProfile(),
      _loadStats(),
      _loadActiveParkings(),
    ]);
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Header avec avatar + recherche ──
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await context.push(AppRoutes.caissierProfile);
                            _loadProfile();
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24, width: 1.5),
                              image: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                                  ? DecorationImage(
                                      image: NetworkImage(_avatarUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: (_avatarUrl == null || _avatarUrl!.isEmpty)
                                ? const Center(
                                    child: Icon(Icons.person_rounded, color: Colors.white, size: 28),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Session Caissier 👋', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontFamily: 'Inter')),
                            Text(_userName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Inter')),
                          ],
                        ),
                      ],
                    ),
                    BlocBuilder<NotificationCubit, NotificationState>(
                      builder: (context, state) {
                        final count = state is NotificationLoaded ? state.unreadCount : 0;
                        if (count > 0) {
                          return IconButton(
                            icon: Badge(
                              label: Text('$count'),
                              child: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                            ),
                            onPressed: () => context.push(AppRoutes.notificationHistory),
                          );
                        }
                        return IconButton(
                          icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                          onPressed: () => context.push(AppRoutes.notificationHistory),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.background,
                    prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary),
                    hintText: 'Rechercher un ticket, une immatriculation...',
                    hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, fontFamily: 'Inter'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: AppTheme.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 28),

          // ── Section Caisse Active (Derniers Encaissements) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Ticket Actif',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Inter'),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_activeParkings.length > 3 ? 3 : _activeParkings.length}',
                        style: const TextStyle(
                          color: AppTheme.secondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.receipt_rounded,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Liste horizontale scrollable des transactions ──
          if (_isLoadingParkings)
            const SizedBox(
              height: 155,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_activeParkings.isEmpty)
            const SizedBox(
              height: 155,
              child: Center(
                child: Text('Aucun ticket actif', style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            SizedBox(
              height: 155,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _activeParkings.length > 3 ? 3 : _activeParkings.length,
                itemBuilder: (context, index) {
                  final tx = _activeParkings[index];
                  return _buildTransactionCard(tx, index);
                },
              ),
            ),

          const SizedBox(height: 28),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Services & outils',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Inter'),
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GridView.count(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.45,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildToolCard(
                  icon: Icons.payments_rounded,
                  title: 'Total Encaissé',
                  color: const Color(0xFF00E5FF),
                  infoText: _totalEncaisser,
                ),
                _buildToolCard(
                  icon: Icons.receipt_long_rounded,
                  title: 'Stationnements',
                  color: const Color(0xFFE040FB),
                  infoText: _stationnements,
                ),
                _buildToolCard(
                  icon: Icons.pending_actions_rounded,
                  title: 'Encaissé non versé',
                  color: Colors.amber[600]!,
                  infoText: _encaisseNonVerse,
                ),
                _buildToolCard(
                  icon: Icons.history_edu_rounded,
                  title: 'Dette',
                  color: Colors.greenAccent,
                  infoText: _dette,
                ),
              ],
            ),
          ),
          const SizedBox(height: 120),
              ],
            ),
          ),
            ),
          ),
        ],
    );
  }

  Widget _buildTransactionCard(ParkingEntry tx, int index) {
    final List<List<Color>> gradients = [
      [const Color(0xFF1E3C72), const Color(0xFF2A5298)],
      [const Color(0xFF3A7BD5), const Color(0xFF3A6073)],
      [const Color(0xFF2C3E50), const Color(0xFF3498DB)],
    ];
    final gradient = gradients[index % gradients.length];

    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.caissierStationnementDetail, extra: tx);
      },
      child: Container(
      width: 250,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tx.ticketNumber,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tx.status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.directions_car_rounded, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                tx.licensePlate,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  letterSpacing: 0.8,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '~ ${_estimatedCost(tx.entryTime, tx.pricePerHour)} FCFA',
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.timer_rounded, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${tx.entryTime.hour.toString().padLeft(2, '0')}:${tx.entryTime.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildToolCard({
    required IconData icon,
    required String title,
    required Color color,
    required String infoText,
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
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              infoText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
