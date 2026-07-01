import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parking_mobile/core/routes/route_names.dart';
import 'package:parking_mobile/core/theme/app_theme.dart';
import 'package:parking_mobile/features/caissier/presentation/providers/caissier_stationnement_provider.dart';
import 'package:parking_mobile/shared/domain/entities/parking_entry.dart';
import 'package:parking_mobile/shared/widgets/parking_entry_card.dart';

class CaissierStationnementScreen extends StatefulWidget {
  const CaissierStationnementScreen({super.key});

  @override
  State<CaissierStationnementScreen> createState() =>
      _CaissierStationnementScreenState();
}

class _CaissierStationnementScreenState
    extends State<CaissierStationnementScreen> {
  static List<ParkingEntry> _staticCache = [];

  List<ParkingEntry> _allEntries = _staticCache;
  List<ParkingEntry> _filteredEntries = List.from(_staticCache);
  bool _isLoading = false;
  String? _errorMessage;
  String _search = '';

  // Rafraîchit les durées toutes les 30s
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _loadStationnements();
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _loadStationnements({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = _allEntries.isEmpty;
      _errorMessage = null;
    });
    try {
      final entries = await CaissierStationnementProvider.repository
          .getStationnementsEnCours(forceRefresh: forceRefresh);
      if (mounted) {
        setState(() {
          _allEntries = entries;
          _staticCache = entries;
          _isLoading = false;
          _applyFilter(_search);
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

  void _applyFilter(String query) {
    setState(() {
      _search = query.toLowerCase();
      if (_search.isEmpty) {
        _filteredEntries = List.from(_allEntries);
      } else {
        _filteredEntries = _allEntries.where((e) {
          return e.licensePlate.toLowerCase().contains(_search) ||
              e.vehicleType.toLowerCase().contains(_search) ||
              e.zone.toLowerCase().contains(_search) ||
              e.ticketNumber.toLowerCase().contains(_search) ||
              (e.agentName?.toLowerCase().contains(_search) ?? false);
        }).toList();
      }
    });
  }

  void _openDetail(ParkingEntry entry) {
    context
        .push(AppRoutes.caissierStationnementDetail, extra: entry)
        .then((_) => _loadStationnements(forceRefresh: true));
  }

  @override
  Widget build(BuildContext context) {
    final displayList = _search.isNotEmpty ? _filteredEntries : _allEntries;

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
                            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: Colors.white),
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
                                '${_allEntries.length}',
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
                        style: const TextStyle(
                            color: Colors.black87, fontFamily: 'Inter'),
                        decoration: InputDecoration(
                          hintText: 'Plaque, zone, ticket, agent…',
                          hintStyle: const TextStyle(
                              color: Colors.black38,
                              fontFamily: 'Inter',
                              fontSize: 14),
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: Colors.black54),
                          suffixIcon: _search.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded,
                                      color: Colors.black54),
                                  onPressed: () {
                                    _applyFilter('');
                                    FocusScope.of(context).unfocus();
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 14),
                        ),
                        onChanged: _applyFilter,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Body ───────────────────────────────────────────
          Expanded(child: _buildBody(displayList)),
        ],
      ),
    );
  }

  Widget _buildBody(List<ParkingEntry> displayList) {
    // Chargement initial
    if (_isLoading && _allEntries.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondary),
        ),
      );
    }

    // Erreur sans données
    if (_errorMessage != null && _allEntries.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _loadStationnements(forceRefresh: true),
        color: AppTheme.secondary,
        backgroundColor: AppTheme.surface,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.wifi_off_rounded,
                          color: Colors.redAccent, size: 48),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                          color: Colors.white70,
                          fontFamily: 'Inter',
                          fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _loadStationnements(forceRefresh: true),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Réessayer',
                          style: TextStyle(fontFamily: 'Inter')),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Liste vide
    if (displayList.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _loadStationnements(forceRefresh: true),
        color: AppTheme.secondary,
        backgroundColor: AppTheme.surface,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Icon(
                      _search.isNotEmpty
                          ? Icons.search_off_rounded
                          : Icons.local_parking_rounded,
                      size: 56,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _search.isNotEmpty
                        ? 'Aucun résultat pour "$_search"'
                        : 'Aucun stationnement actif',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _search.isNotEmpty
                        ? 'Essayez une autre recherche'
                        : 'Glissez vers le bas pour actualiser',
                    style: const TextStyle(
                        color: Colors.white54,
                        fontFamily: 'Inter',
                        fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Liste
    return RefreshIndicator(
      onRefresh: () => _loadStationnements(forceRefresh: true),
      color: AppTheme.secondary,
      backgroundColor: AppTheme.surface,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        itemCount: displayList.length,
        itemBuilder: (context, index) => ParkingEntryCard(
          entry: displayList[index],
          onTap: () => _openDetail(displayList[index]),
        ),
      ),
    );
  }
}
