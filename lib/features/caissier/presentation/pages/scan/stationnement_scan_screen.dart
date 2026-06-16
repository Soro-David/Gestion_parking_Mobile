import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CaissierStationnementScanScreen extends StatelessWidget {
  final CameraController? controller;
  final Future<void>? initializeFuture;

  const CaissierStationnementScanScreen({super.key, this.controller, this.initializeFuture});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Stationnement Scan'));
  }
}
