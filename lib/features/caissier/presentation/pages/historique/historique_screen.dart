import 'package:flutter/material.dart';
import 'package:parking_mobile/core/theme/app_theme.dart';
import 'package:parking_mobile/shared/domain/entities/parking_entry.dart';
// removed unused imports
import 'package:parking_mobile/features/caissier/presentation/providers/caissier_history_provider.dart';

class CaissierHistoryScreen extends StatelessWidget {
  const CaissierHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          toolbarHeight: 110,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E1E2C), Color(0xFF232539)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text(
              'Historique Caissier',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: AppTheme.secondary,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
              fontSize: 15,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.normal,
              fontFamily: 'Inter',
              fontSize: 15,
            ),
            tabs: [
              Tab(text: 'Entrée'),
              Tab(text: 'Sortie'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            CaissierHistoriqueEntreeScreen(),
            CaissierHistoriqueSortieScreen(),
          ],
        ),
      ),
    );
  }
}

// Entrée list
class CaissierHistoriqueEntreeScreen extends StatefulWidget {
  const CaissierHistoriqueEntreeScreen({super.key});

  @override
  State<CaissierHistoriqueEntreeScreen> createState() => _CaissierHistoriqueEntreeScreenState();
}

class _CaissierHistoriqueEntreeScreenState extends State<CaissierHistoriqueEntreeScreen> {
  List<ParkingEntry> _allRecords = [];
  List<ParkingEntry> _filteredRecords = [];
  String _search = '';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final records = await CaissierHistoryProvider.repository.getEntryHistory();
      if (mounted) {
        setState(() {
          _allRecords = records;
          _isLoading = false;
          _filter(_search);
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
      _search = query.toLowerCase();
      if (_search.isEmpty) {
        _filteredRecords = List.from(_allRecords);
      } else {
        _filteredRecords = _allRecords.where((e) =>
            e.licensePlate.toLowerCase().contains(_search) ||
            e.vehicleType.toLowerCase().contains(_search)).toList();
      }
    });
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);
    final timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    if (date == today) {
      return "Aujourd'hui, $timeStr";
    } else {
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}, $timeStr";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rechercher une plaque ou un véhicule...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontFamily: 'Inter'),
                prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.5)),
                filled: true,
                fillColor: AppTheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _filter,
            ),
          ),
          Expanded(
            child: _buildBodyContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading && _allRecords.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondary),
        ),
      );
    }

    if (_errorMessage != null && _allRecords.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final list = _filteredRecords.isNotEmpty || _search.isNotEmpty ? _filteredRecords : _allRecords;

    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadHistory,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.35),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                    ),
                    child: Icon(
                      Icons.history_rounded,
                      size: 56,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Aucun historique disponible', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final e = list[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.licensePlate, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(e.vehicleType, style: const TextStyle(color: Colors.white70)),
                ],
              ),
              Text(_formatDateTime(e.entryTime), style: const TextStyle(color: Colors.white70)),
            ],
          ),
        );
      },
    );
  }
}

// Placeholder for sortie tab
class CaissierHistoriqueSortieScreen extends StatelessWidget {
  const CaissierHistoriqueSortieScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Historique Sortie'));
  }
}
