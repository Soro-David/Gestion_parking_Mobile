import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CaissierSortieScanScreen extends StatelessWidget {
  final CameraController? controller;
  final Future<void>? initializeFuture;

  const CaissierSortieScanScreen({super.key, this.controller, this.initializeFuture});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Sortie Scan'));
  }
}
