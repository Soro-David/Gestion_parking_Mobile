import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:parking_mobile/core/theme/app_theme.dart';
import 'package:parking_mobile/features/caissier/presentation/pages/scan/stationnement_scan_screen.dart';
import 'package:parking_mobile/features/caissier/presentation/pages/scan/sortie_scan_screen.dart';

class CaissierScanScreen extends StatefulWidget {
  final VoidCallback? onClose;

  const CaissierScanScreen({super.key, this.onClose});

  @override
  State<CaissierScanScreen> createState() => _CaissierScanScreenState();
}

class _CaissierScanScreenState extends State<CaissierScanScreen> with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _initCamera();
  }

  void _handleTabChange() {
    if (_tabController.index == 0) {
      _initCamera();
    } else {
      _disposeCamera();
    }
  }

  Future<void> _initCamera() async {
    if (_cameraController != null) return;
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.medium,
          enableAudio: false,
        );
        _initializeControllerFuture = _cameraController!.initialize();
        if (mounted) setState(() {});
      }
    } catch (e) {
      debugPrint('Error initializing camera in CaissierScanScreen: $e');
    }
  }

  Future<void> _disposeCamera() async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
      if (mounted) setState(() {});
    }
  }

  /// Libère la caméra puis ferme la page
  Future<void> _closeCamera() async {
    await _disposeCamera();
    // Utilise le callback onClose si fourni, sinon tente context.pop()
    if (mounted) {
      if (widget.onClose != null) {
        widget.onClose!();
      } else {
        context.pop();
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
          tooltip: 'Fermer le scanner',
          onPressed: _closeCamera,
        ),
        title: const Text(
          'Scanner Caissier',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Inter',
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E1E2C), Color(0xFF232539)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.secondary,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: 'Inter',
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 16,
            fontFamily: 'Inter',
          ),
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(
              text: 'Stationnement',
              icon: Icon(Icons.login_rounded, size: 20),
            ),
            Tab(
              text: 'Sortie',
              icon: Icon(Icons.logout_rounded, size: 20),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CaissierStationnementScanScreen(
            controller: _cameraController,
            initializeFuture: _initializeControllerFuture,
          ),
          const CaissierSortieScanScreen(
            // Do not pass camera controller, CaissierSortieScanScreen will use MobileScanner
          ),
        ],
      ),
    );
  }
}
