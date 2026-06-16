import 'package:flutter/material.dart';
import 'package:parking_mobile/core/theme/app_theme.dart';
import 'package:parking_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class CaissierEditProfileScreen extends StatefulWidget {
  const CaissierEditProfileScreen({super.key});

  @override
  State<CaissierEditProfileScreen> createState() => _CaissierEditProfileScreenState();
}

class _CaissierEditProfileScreenState extends State<CaissierEditProfileScreen> {
  // ignore: unused_field
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _adresseController = TextEditingController();

  bool _isLoading = true;
  // ignore: unused_field
  String? _errorMessage;
  String _headerName = '';
  // ignore: unused_field
  String _headerRole = 'Caissier de Service';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profileData = await AuthProvider.repository.getProfile();
      final user = profileData['user'] as Map<String, dynamic>?;
      if (user != null) {
        _nomController.text = user['name'] ?? '';
        _prenomController.text = user['first_name'] ?? '';
        _emailController.text = user['email'] ?? '';
        _phoneController.text = user['phone'] ?? '';
        _adresseController.text = '';

        _headerName = '${user['first_name'] ?? ''} ${user['name'] ?? ''}'.trim();
        if (_headerName.isEmpty) {
          _headerName = user['name'] ?? 'Caissier';
        }
        final roleStr = user['role'] ?? 'caissier';
        _headerRole = roleStr == 'caissier' ? 'Caissier de Service' : 'Agent de Service';
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _adresseController.dispose();
    super.dispose();
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
          'Modifier le Profil',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 22,
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
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.secondary,
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
