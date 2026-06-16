import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:parking_mobile/core/theme/app_theme.dart';

class AgentSortieScreen extends StatelessWidget {
  final CameraController? controller;
  final Future<void>? initializeFuture;

  const AgentSortieScreen({
    super.key,
    required this.controller,
    required this.initializeFuture,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: initializeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondary),
              ),
            );
          }

          if (controller == null || !controller!.value.isInitialized) {
            return const Center(
              child: Text(
                'Impossible d_initialiser la caméra.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return CameraPreview(controller!);
        },
      ),
    );
  }
}
