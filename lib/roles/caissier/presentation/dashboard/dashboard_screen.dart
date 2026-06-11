import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../profil/profil_screen.dart';

class CaissierDashboardScreen extends StatelessWidget {
  const CaissierDashboardScreen({super.key});

  // Données mockées des transactions récentes
  static final List<Map<String, String>> _recentTransactions = [
    {
      'ticket': 'Ticket #8942',
      'immatriculation': 'LT-9082-HG',
      'montant': '3 500 FCFA',
      'heure': 'Il y a 5 min',
      'methode': 'Espèces',
    },
    {
      'ticket': 'Ticket #8941',
      'immatriculation': 'CE-1248-IO',
      'montant': '1 200 FCFA',
      'heure': 'Il y a 12 min',
      'methode': 'Orange Money',
    },
    {
      'ticket': 'Ticket #8940',
      'immatriculation': 'LT-4569-AZ',
      'montant': '6 000 FCFA',
      'heure': 'Il y a 25 min',
      'methode': 'MTN MoMo',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CaissierProfilScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE040FB), Color(0xFF00E5FF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24, width: 1.5),
                            ),
                            child: const Center(
                              child: Icon(Icons.support_agent_rounded, color: Colors.white, size: 28),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Session Caissier 👋', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontFamily: 'Inter')),
                            Text('Marc-Aurèle', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Inter')),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Badge(
                        label: Text('3'),
                        child: Icon(Icons.notifications_none_rounded, color: Colors.white),
                      ),
                      onPressed: () {},
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
                      'Encaissements récents',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Inter'),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_recentTransactions.length}',
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
          SizedBox(
            height: 155,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _recentTransactions.length,
              itemBuilder: (context, index) {
                final tx = _recentTransactions[index];
                return _buildTransactionCard(tx, index);
              },
            ),
          ),

          const SizedBox(height: 28),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Outils & Statistiques Caisse',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Inter'),
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
                  infoText: '96 000 FCFA',
                ),
                _buildToolCard(
                  icon: Icons.receipt_long_rounded,
                  title: 'Nombre Tickets',
                  color: const Color(0xFFE040FB),
                  infoText: '48 encaissements',
                ),
                _buildToolCard(
                  icon: Icons.pending_actions_rounded,
                  title: 'En Attente',
                  color: Colors.amber[600]!,
                  infoText: '3 transactions',
                ),
                _buildToolCard(
                  icon: Icons.history_edu_rounded,
                  title: 'Rapport Caisse',
                  color: Colors.greenAccent,
                  infoText: 'Généré à 90%',
                ),
              ],
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, String> tx, int index) {
    final List<List<Color>> gradients = [
      [const Color(0xFF1E3C72), const Color(0xFF2A5298)],
      [const Color(0xFF3A7BD5), const Color(0xFF3A6073)],
      [const Color(0xFF2C3E50), const Color(0xFF3498DB)],
    ];
    final gradient = gradients[index % gradients.length];

    return Container(
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
            color: gradient[0].withOpacity(0.3),
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
                tx['ticket']!,
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
                  tx['methode']!,
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
                tx['immatriculation']!,
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
                tx['montant']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                tx['heure']!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                infoText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
