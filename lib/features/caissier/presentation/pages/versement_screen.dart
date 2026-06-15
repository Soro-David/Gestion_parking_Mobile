import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/versement_model.dart';
import 'package:go_router/go_router.dart';
import '../../../../network/routes/route_names.dart';
import '../providers/caissier_versement_provider.dart';

class CaissierVersementScreen extends StatefulWidget {
  const CaissierVersementScreen({super.key});

  @override
  State<CaissierVersementScreen> createState() => _CaissierVersementScreenState();
}

class _CaissierVersementScreenState extends State<CaissierVersementScreen> {
  late Future<List<VersementModel>> _futureVersements;

  @override
  void initState() {
    super.initState();
    _futureVersements = CaissierVersementProvider.repository.getVersements();
  }

  void _reload() {
    setState(() {
      _futureVersements = CaissierVersementProvider.repository.getVersements();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        title: const Text(
          'Versements',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: _reload,
          ),
        ],
      ),
      body: FutureBuilder<List<VersementModel>>(
        future: _futureVersements,
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
                        color: Colors.redAccent, size: 38),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _reload,
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

          final versements = snapshot.data ?? [];

          if (versements.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async => _reload(),
              color: AppTheme.secondary,
              backgroundColor: AppTheme.surface,
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
                            Icons.account_balance_wallet_outlined,
                            size: 56,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Aucun versement disponible',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Vous n\'avez effectué aucun versement.\nGlissez vers le bas pour actualiser.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 13,
                            fontFamily: 'Inter',
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            itemCount: versements.length,
            itemBuilder: (context, index) {
              final v = versements[index];
              return _buildVersementItem(context, v);
            },
          );
        },
      ),
    );
  }

  Widget _buildVersementItem(BuildContext context, VersementModel v) {
    final isValide = v.status.toLowerCase() == 'validé' ||
        v.status.toLowerCase() == 'valide' ||
        v.status.toLowerCase() == 'paid';
    final statusColor = isValide ? Colors.greenAccent : Colors.orangeAccent;
    final statusIcon =
        isValide ? Icons.check_circle_rounded : Icons.pending_rounded;

    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.caissierVersementDetail, extra: v.id);},
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, color: statusColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Versement #${v.id}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${v.date.day.toString().padLeft(2, '0')}/'
                    '${v.date.month.toString().padLeft(2, '0')}/'
                    '${v.date.year} '
                    '${v.date.hour.toString().padLeft(2, '0')}:'
                    '${v.date.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+ ${v.amount.toStringAsFixed(0)} FCFA',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                if (v.reste > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Reste: ${v.reste.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    v.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
