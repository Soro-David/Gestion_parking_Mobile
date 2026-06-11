import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../../../shared/widgets/camera_preview_widget.dart';

class CaissierStationnementScanScreen extends StatelessWidget {
  final CameraController? controller;
  final Future<void>? initializeFuture;

  const CaissierStationnementScanScreen({
    super.key,
    this.controller,
    this.initializeFuture,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CameraPreviewWidget(
        isQrCodeMode: false,
        controller: controller,
        initializeControllerFuture: initializeFuture,
      ),
    );
  }
}
