import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parking_mobile/core/routes/route_names.dart';
import 'package:parking_mobile/core/theme/app_theme.dart';
import 'package:parking_mobile/features/agent/presentation/providers/agent_stationnement_provider.dart';
import 'package:parking_mobile/shared/domain/entities/parking_entry.dart';
import 'package:parking_mobile/shared/widgets/parking_entry_card.dart';

/// Écran listant les stationnements en cours enregistrés par cet agent. 
/// Consomme GET /api/attendant/parking-sessions/stationnement_en_cours  
class AgentStationnementEnCoursScreen extends StatefulWidget {
  const AgentStationnementEnCoursScreen({super.key});

  @override
  State<AgentStationnementEnCoursScreen> createState() =>
      _AgentStationnementEnCoursScreenState();
}

class _AgentStationnementEnCoursScreenState
    extends State<AgentStationnementEnCoursScreen> {
  static List<ParkingEntry> _staticCache = [];

  List<ParkingEntry> _allRecords = _staticCache;
  List<ParkingEntry> _filteredRecords = List.from(_staticCache);
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = _allRecords.isEmpty;
      _errorMessage = null;
    });

    try {
      final records =
          await AgentStationnementProvider.repository.getStationnementsEnCours();
      if (mounted) {
        setState(() {
          _allRecords = records;
          _staticCache = records;
          _isLoading = false;
          _filter(_searchQuery);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _filter(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredRecords = List.from(_allRecords);
      } else {
        _filteredRecords = _allRecords
            .where((e) =>
                e.licensePlate.toLowerCase().contains(_searchQuery) ||
                e.vehicleType.toLowerCase().contains(_searchQuery) ||
                e.zone.toLowerCase().contains(_searchQuery) ||
                e.ticketNumber.toLowerCase().contains(_searchQuery) ||
                (e.agentName?.toLowerCase().contains(_searchQuery) ?? false))
            .toList();
      }
    });
  }

  void _openDetail(ParkingEntry entry) {
    context
        .push(AppRoutes.agentStationnementDetail, extra: entry)
        .then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // ── Header bleu foncé ───────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Color(0x40143F85),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre + compteur
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (context.canPop()) ...[
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                            onPressed: () => context.pop(),
                          ),
                          const SizedBox(width: 8),
                        ],
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Stationnements',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              Text(
                                'Véhicules actuellement garés',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.directions_car_rounded,
                                  color: Colors.white, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                '${_allRecords.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Barre de recherche
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                            color: Colors.black87, fontFamily: 'Inter'),
                        decoration: InputDecoration(
                          hintText: 'Rechercher par immatriculation...',
                          hintStyle: const TextStyle(
                              color: Colors.black38,
                              fontFamily: 'Inter',
                              fontSize: 14),
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: Colors.black54),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded,
                                      color: Colors.black54),
                                  onPressed: () {
                                    _searchController.clear();
                                    _filter('');
                                    FocusScope.of(context).unfocus();
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                        ),
                        onChanged: _filter,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Contenu ─────────────────────────────────────────
          Expanded(child: _buildBodyContent()),
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    // Chargement initial
    if (_isLoading && _allRecords.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondary),
        ),
      );
    }

    // Erreur sans données
    if (_errorMessage != null && _allRecords.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Liste vide
    if (_filteredRecords.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.secondary,
        backgroundColor: AppTheme.surface,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.18),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Icon(
                      _searchQuery.isEmpty
                          ? Icons.directions_car_rounded
                          : Icons.search_off_rounded,
                      size: 56,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _searchQuery.isEmpty
                        ? 'Aucune liste disponible'
                        : 'Aucune plaque correspondante',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _searchQuery.isEmpty
                        ? 'Aucun stationnement actif.\nGlissez vers le bas pour actualiser.'
                        : 'Aucun stationnement ne correspond à "$_searchQuery".',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 13,
                      fontFamily: 'Inter',
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (_searchQuery.isEmpty)
                    ElevatedButton.icon(
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Actualiser'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Liste des stationnements
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.secondary,
      backgroundColor: AppTheme.surface,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        itemCount: _filteredRecords.length,
        itemBuilder: (context, index) => ParkingEntryCard(
          entry: _filteredRecords[index],
          onTap: () => _openDetail(_filteredRecords[index]),
        ),
      ),
    );
  }
}
