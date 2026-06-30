import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parking_mobile/core/theme/app_theme.dart';
import 'package:parking_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:parking_mobile/core/routes/route_names.dart';
import 'package:parking_mobile/core/services/settings_manager.dart';
import 'package:parking_mobile/core/utils/translations.dart';

class AgentSettingsScreen extends StatefulWidget {
  const AgentSettingsScreen({super.key});

  @override
  State<AgentSettingsScreen> createState() => _AgentSettingsScreenState();
}

class _AgentSettingsScreenState extends State<AgentSettingsScreen> {
  bool _isSaving = false;

  Color get _activeColor => AppSettingsManager.instance.isDarkMode ? AppTheme.secondary : const Color(0xFF182C4D);

  Future<void> _updateTheme(ThemeMode mode) async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
    });

    try {
      // Simulation d'une sauvegarde pour afficher le loader professionnel
      await Future.delayed(const Duration(milliseconds: 600));
      await AppSettingsManager.instance.setThemeMode(mode);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.translate('save_success')),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.translate('save_error')} : ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _updateLanguage(String langCode) async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
    });

    try {
      // Simulation d'une sauvegarde
      await Future.delayed(const Duration(milliseconds: 600));
      await AppSettingsManager.instance.setLanguage(langCode);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.translate('save_success')),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.translate('save_error')} : ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _handleLogout() async {
    final isDark = AppSettingsManager.instance.isDarkMode;
    final dialogBg = isDark ? const Color(0xFF182C4D) : Colors.white;
    final textCol = isDark ? Colors.white : const Color(0xFF0F172A);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          context.translate('logout_confirm_title'),
          style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
        ),
        content: Text(
          context.translate('logout_confirm_desc'),
          style: TextStyle(color: isDark ? const Color(0xFF8A9CB4) : const Color(0xFF475569), fontFamily: 'Inter'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.translate('cancel'), style: TextStyle(color: _activeColor)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(context.translate('confirm'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          color: _activeColor,
        ),
      ),
    );

    try {
      await AuthProvider.repository.logout();
      if (!mounted) return;
      context.go(AppRoutes.login);
    } catch (e) {
      if (!mounted) return;
      context.pop(); // fermer l'indicateur de chargement
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppSettingsManager.instance.isDarkMode;
    final currentLang = AppSettingsManager.instance.languageCode;

    // Theme values
    final bgColor = isDark ? const Color(0xFF0D121E) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF161F30) : Colors.white;
    final borderCol = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05);
    final textCol = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextCol = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.translate('settings'),
          style: const TextStyle(
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
      body: Column(
        children: [
          if (_isSaving)
            LinearProgressIndicator(
              color: _activeColor,
              backgroundColor: Colors.transparent,
              minHeight: 3,
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 80),
              children: [
                // SECTION 1: COMPTE
                _buildSectionHeader(context.translate('account_security_section'), _activeColor),
                const SizedBox(height: 10),
                _buildGroupedCard(
                  cardColor: const Color(0xFF182C4D),
                  borderCol: Colors.transparent,
                  children: [
                    _tileWithoutContainer(Icons.person_outline_rounded, context.translate('profile_agent'), () {
                      context.push(AppRoutes.agentProfile);
                    }, Colors.white, isInverse: true),
                    _buildDivider(Colors.white.withValues(alpha: 0.15)),
                    _tileWithoutContainer(Icons.notifications_none_rounded, context.translate('notifications'), () {
                      context.push(AppRoutes.agentNotifications);
                    }, Colors.white, isInverse: true),
                    _buildDivider(Colors.white.withValues(alpha: 0.15)),
                    _tileWithoutContainer(Icons.lock_outline_rounded, context.translate('security'), () {
                      context.push(AppRoutes.agentSecurity);
                    }, Colors.white, isInverse: true),
                  ],
                ),

                const SizedBox(height: 24),

                // SECTION 2: PREFERENCES (LANGUE & APPARENCE)
                _buildSectionHeader(context.translate('preferences_section'), _activeColor),
                const SizedBox(height: 10),

                // Carte Langue
                _buildPreferenceCard(
                  icon: Icons.language_rounded,
                  title: context.translate('language'),
                  subtitle: '${context.translate('language_desc')}${currentLang == 'fr' ? 'Français' : 'English'}',
                  cardColor: cardColor,
                  borderCol: borderCol,
                  textCol: textCol,
                  subTextCol: subTextCol,
                  content: Row(
                    children: [
                      Expanded(
                        child: _buildChoiceButton(
                          label: 'Français',
                          isSelected: currentLang == 'fr',
                          onTap: () => _updateLanguage('fr'),
                          textCol: textCol,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildChoiceButton(
                          label: 'English',
                          isSelected: currentLang == 'en',
                          onTap: () => _updateLanguage('en'),
                          textCol: textCol,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Carte Apparence
                _buildPreferenceCard(
                  icon: Icons.palette_rounded,
                  title: context.translate('appearance'),
                  subtitle: '${context.translate('appearance_desc')}${isDark ? context.translate('dark_theme') : context.translate('light_theme')}',
                  cardColor: cardColor,
                  borderCol: borderCol,
                  textCol: textCol,
                  subTextCol: subTextCol,
                  content: Row(
                    children: [
                      Expanded(
                        child: _buildChoiceButton(
                          label: context.translate('light_theme'),
                          icon: Icons.light_mode_rounded,
                          isSelected: !isDark,
                          onTap: () => _updateTheme(ThemeMode.light),
                          textCol: textCol,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildChoiceButton(
                          label: context.translate('dark_theme'),
                          icon: Icons.dark_mode_rounded,
                          isSelected: isDark,
                          onTap: () => _updateTheme(ThemeMode.dark),
                          textCol: textCol,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // SECTION 3: ACTIONS
                _buildSectionHeader(context.translate('actions_section'), _activeColor),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _handleLogout,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          context.translate('logout'),
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildGroupedCard({
    required List<Widget> children,
    Color? cardColor,
    Gradient? gradient,
    required Color borderCol,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildDivider(Color borderCol) {
    return Divider(
      height: 1,
      thickness: 1,
      color: borderCol,
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _tileWithoutContainer(IconData icon, String label, VoidCallback onTap, Color textCol, {bool isDanger = false, bool isInverse = false}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDanger
              ? Colors.red
              : (isInverse ? Colors.white.withValues(alpha: 0.2) : _activeColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
      title: Text(
        label,
        style: TextStyle(color: textCol, fontWeight: FontWeight.w600, fontSize: 15, fontFamily: 'Inter'),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: textCol.withValues(alpha: 0.4)),
      onTap: onTap,
    );
  }

  Widget _buildPreferenceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color cardColor,
    required Color borderCol,
    required Color textCol,
    required Color subTextCol,
    required Widget content,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _activeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.tune_rounded, color: _activeColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Inter'),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(color: subTextCol, fontSize: 12, fontFamily: 'Inter'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildChoiceButton({
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color textCol,
  }) {
    final isDark = AppSettingsManager.instance.isDarkMode;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF182C4D) 
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF182C4D) : textCol.withValues(alpha: 0.08),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF182C4D).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isSelected ? Colors.white : textCol.withValues(alpha: 0.7),
                size: 18,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : textCol.withValues(alpha: 0.8),
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
