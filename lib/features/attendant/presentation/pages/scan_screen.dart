import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import '../../../../core/theme/app_theme.dart';
import 'stationnement_screen.dart';
import 'sortie_screen.dart';

class AgentScanScreen extends StatefulWidget {
  const AgentScanScreen({super.key});

  @override
  State<AgentScanScreen> createState() => _AgentScanScreenState();
}

class _AgentScanScreenState extends State<AgentScanScreen> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
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
      debugPrint('Error initializing camera in ScanScreen: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          toolbarHeight: 70,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
            tooltip: 'Fermer le scanner',
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Scanner',
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
          bottom: const TabBar(
            indicatorColor: AppTheme.secondary,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFamily: 'Inter',
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 16,
              fontFamily: 'Inter',
            ),
            dividerColor: Colors.transparent,
            tabs: [
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
          children: [
            const AgentStationnementScreen(),
            AgentSortieScreen(
              controller: _cameraController,
              initializeFuture: _initializeControllerFuture,
            ),
          ],
        ),
      ),
    );
  }
}
