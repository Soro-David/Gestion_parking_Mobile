import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/auth/presentation/pages/login_screen.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

class CaissierSettingsScreen extends StatelessWidget {
  const CaissierSettingsScreen({super.key});

  void _handleLogout(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: AppTheme.secondary,
        ),
      ),
    );

    try {
      await AuthProvider.repository.logout();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // fermer l'indicateur de chargement
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      children: [
        const Text(
          'Parametres Caissier',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Preferences et acces de la caisse.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 18),
        _tile(Icons.person_outline_rounded, 'Profil caissier', () {}),
        _tile(Icons.notifications_none_rounded, 'Notifications', () {}),
        _tile(Icons.lock_outline_rounded, 'Securite', () {}),
        _tile(Icons.logout_rounded, 'Deconnexion', () => _handleLogout(context), isDanger: true),
      ],
    );
  }

  Widget _tile(IconData icon, String label, VoidCallback onTap, {bool isDanger = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: ListTile(
        leading: Icon(icon, color: isDanger ? Colors.red[300] : AppTheme.secondary),
        title: Text(
          label,
          style: TextStyle(color: isDanger ? Colors.red[300] : Colors.white),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
