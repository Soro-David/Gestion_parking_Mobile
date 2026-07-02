import 'package:flutter/material.dart';
import 'package:parking_mobile/core/theme/app_theme.dart';
import 'package:parking_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:parking_mobile/shared/domain/entities/user.dart';
import 'package:parking_mobile/core/routes/route_names.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:parking_mobile/core/constants/api_constants.dart';
import 'package:parking_mobile/shared/services/avatar_cache_helper.dart';

class CaissierProfilScreen extends StatefulWidget {
  const CaissierProfilScreen({super.key});

  @override
  State<CaissierProfilScreen> createState() => _CaissierProfilScreenState();
}

class _CaissierProfilScreenState extends State<CaissierProfilScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  String _name = 'Caissier';
  String _role = 'Caissier de Service';
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    final cachedProvider = AvatarCacheHelper.getLocalAvatarProvider();
    if (cachedProvider != null) {
      _avatarUrl = 'cached';
    }
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profileData = await AuthProvider.repository.getProfile();
      final user = profileData['user'] as Map<String, dynamic>?;
      if (user != null) {
        final firstName = user['first_name'] ?? '';
        final lastName = user['name'] ?? '';
        _name = '$firstName $lastName'.trim();
        if (_name.isEmpty) {
          _name = user['name'] ?? 'Caissier';
        }
        final roleStr = user['role'] ?? 'caissier';
        _role = roleStr == 'caissier' ? 'Caissier de Service' : 'Agent de Service';
        _avatarUrl = User.sanitizeAvatarUrl(user['avatar_url'] as String?);

        await AvatarCacheHelper.cacheAvatarIfNeeded(_avatarUrl);
      }
      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

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
      context.go(AppRoutes.login);
    } catch (e) {
      if (!context.mounted) return;
      context.pop();
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
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        toolbarHeight: 80,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Mon Profil',
          style: TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
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
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.secondary,
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: Colors.redAccent,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _errorMessage = null;
                            });
                            _loadProfile();
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Réessayer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [AppTheme.primary, AppTheme.secondary],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.secondary.withValues(alpha: 0.35),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                  image: (_avatarUrl != null && _avatarUrl!.isNotEmpty) || AvatarCacheHelper.getLocalAvatarProvider() != null
                                      ? DecorationImage(
                                          image: AvatarCacheHelper.getAvatarImageProvider(_avatarUrl),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: (_avatarUrl == null || _avatarUrl!.isEmpty) && AvatarCacheHelper.getLocalAvatarProvider() == null
                                    ? const Icon(
                                        Icons.person_rounded,
                                        color: Colors.white,
                                        size: 50,
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _role,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildMenuSection(
                          title: 'Compte',
                          icon: Icons.person_outline_rounded,
                          items: [
                            _buildMenuItem(
                              context: context,
                              icon: Icons.person_outline_rounded,
                              label: 'Modifier Profil',
                              onTap: () async {
                                await context.push('${AppRoutes.caissierProfile}/edit');
                                _loadProfile();
                              },
                            ),
                            _buildDivider(),
                            _buildMenuItem(
                              context: context,
                              icon: Icons.notifications_none_rounded,
                              label: 'Notifications',
                              onTap: () => context.push(AppRoutes.notificationHistory),
                            ),
                            _buildDivider(),
                            _buildMenuItem(
                              context: context,
                              icon: Icons.lock_outline_rounded,
                              label: 'Sécurité',
                              onTap: () => context.push(AppRoutes.caissierSecurity),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildMenuSection(
                          title: 'Général',
                          icon: Icons.tune_rounded,
                          items: [
                            _buildMenuItem(
                              context: context,
                              icon: Icons.privacy_tip_outlined,
                              label: 'Politique de confidentialité',
                              onTap: () async {
                                final url = Uri.parse('${ApiConstants.baseUrl}/politique-confidentialite');
                                if (await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                  // Success
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Impossible d\'ouvrir la politique de confidentialité'),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                            _buildDivider(),
                            _buildMenuItem(
                              context: context,
                              icon: Icons.settings_outlined,
                              label: 'Paramètres',
                              onTap: () {
                                context.push(AppRoutes.caissierSettings);
                              },
                            ),
                            _buildDivider(),
                            _buildMenuItem(
                              context: context,
                              icon: Icons.warning_amber_rounded,
                              label: 'Signalements',
                              onTap: () {
                                context.push(AppRoutes.signalementsList);
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GestureDetector(
                          onTap: () => _handleLogout(context),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
                                SizedBox(width: 10),
                                Text(
                                  'Déconnexion',
                                  style: TextStyle(
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
                      ),

                      const SizedBox(height: 60),
                    ],
                  ),
                ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required IconData icon,
    required List<Widget> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppTheme.secondary, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          ...items,
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.4),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 1,
        color: Colors.white.withValues(alpha: 0.06),
      ),
    );
  }
}
