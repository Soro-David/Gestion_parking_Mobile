import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../../../shared/widgets/camera_preview_widget.dart';

class AgentSortieScreen extends StatelessWidget {
  final CameraController? controller;
  final Future<void>? initializeFuture;

  const AgentSortieScreen({
    super.key,
    this.controller,
    this.initializeFuture,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CameraPreviewWidget(
        isQrCodeMode: true,
        controller: controller,
        initializeControllerFuture: initializeFuture,
      ),
    );
  }
}
