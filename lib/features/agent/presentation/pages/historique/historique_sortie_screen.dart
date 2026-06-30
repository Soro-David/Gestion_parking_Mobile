import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parking_mobile/core/routes/route_names.dart';
import 'package:parking_mobile/core/theme/app_theme.dart';
import 'package:parking_mobile/features/agent/presentation/providers/agent_history_provider.dart';
import 'package:parking_mobile/shared/domain/entities/parking_exit.dart';

class HistoriqueSortieScreen extends StatefulWidget {
  final bool isActive;
  const HistoriqueSortieScreen({super.key, this.isActive = false});

  @override
  State<HistoriqueSortieScreen> createState() => _HistoriqueSortieScreenState();
}

class _HistoriqueSortieScreenState extends State<HistoriqueSortieScreen> {
  List<ParkingExit> _allRecords = [];
  List<ParkingExit> _filteredRecords = [];
  String _search = '';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void didUpdateWidget(covariant HistoriqueSortieScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _loadHistory();
    }
  }

  Future<void> _loadHistory() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final records = await AgentHistoryProvider.repository.getExitHistory();
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadHistory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Réessayer'),
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
        color: AppTheme.secondary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.logout_rounded, size: 72, color: AppTheme.secondary),
                      SizedBox(height: 24),
                      Text(
                        'Aucune sortie enregistrée pour le moment.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      color: AppTheme.secondary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final e = list[index];
          return GestureDetector(
            onTap: () {
              context.push(AppRoutes.agentSortieDetail, extra: e);
            },
            child: Container(
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Text(_formatDateTime(e.exitTime), style: const TextStyle(color: Colors.white70)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white30, size: 14),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${e.amount.toStringAsFixed(0)} FCFA',
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
