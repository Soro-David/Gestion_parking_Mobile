// Écran de gestion des catégories de notifications
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:parking_mobile/core/theme/app_theme.dart';
import 'package:parking_mobile/shared/notifications/presentation/cubit/notification_cubit.dart';
import 'package:parking_mobile/shared/notifications/presentation/cubit/notification_state.dart';

class NotificationCategoriesPage extends StatelessWidget {
  const NotificationCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationCubit()..loadCategories(),
      child: const _CategoriesView(),
    );
  }
}

class _CategoriesView extends StatelessWidget {
  const _CategoriesView();

  static const _categories = [
    _CategoryItem(
      key: 'entrees',
      label: 'Entrées véhicules',
      description: 'Notifié à chaque nouvelle entrée enregistrée',
      icon: Icons.login_rounded,
      color: Color(0xFF27AE60),
    ),
    _CategoryItem(
      key: 'sorties',
      label: 'Sorties véhicules',
      description: 'Notifié à chaque sortie avec le montant encaissé',
      icon: Icons.logout_rounded,
      color: Color(0xFFEB5757),
    ),
    _CategoryItem(
      key: 'paiements',
      label: 'Paiements',
      description: 'Alertes sur les transactions et paiements',
      icon: Icons.payment_rounded,
      color: Color(0xFF9B59B6),
    ),
    _CategoryItem(
      key: 'versements',
      label: 'Versements',
      description: 'Notifié à chaque versement créé ou validé',
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFFF2994A),
    ),
    _CategoryItem(
      key: 'rapports',
      label: 'Rapports & Statistiques',
      description: 'Résumés journaliers et alertes de performance',
      icon: Icons.bar_chart_rounded,
      color: AppTheme.primary,
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
          'Catégories de notifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          final categories = state is NotificationLoaded
              ? state.categories
              : <String, bool>{};

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // En-tête
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personnalisez vos alertes',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Activez ou désactivez les notifications par catégorie',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Cartes catégories
              ..._categories.map((cat) => _CategoryCard(
                    categoryItem: cat,
                    isEnabled: categories[cat.key] ?? true,
                    onToggle: (value) => context
                        .read<NotificationCubit>()
                        .updateCategory(cat.key, value),
                  )),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _CategoryItem categoryItem;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;

  const _CategoryCard({
    required this.categoryItem,
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isEnabled ? Colors.white : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEnabled
              ? categoryItem.color.withValues(alpha: 0.25)
              : const Color(0xFFE2E8F0),
          width: isEnabled ? 1.5 : 1.0,
        ),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: categoryItem.color.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isEnabled
                    ? categoryItem.color.withValues(alpha: 0.12)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                categoryItem.icon,
                color: isEnabled ? categoryItem.color : Colors.grey.shade400,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryItem.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isEnabled
                          ? const Color(0xFF0F172A)
                          : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    categoryItem.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isEnabled ? const Color(0xFF475569) : Colors.grey.shade400,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Switch.adaptive(
              value: isEnabled,
              onChanged: onToggle,
              activeThumbColor: categoryItem.color,
              activeTrackColor: categoryItem.color.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}

// Modèle de catégorie (const, statique)
class _CategoryItem {
  final String key;
  final String label;
  final String description;
  final IconData icon;
  final Color color;

  const _CategoryItem({
    required this.key,
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
  });
}
