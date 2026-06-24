import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class CameraPreviewWidget extends StatefulWidget {
  final bool isQrCodeMode;
  final CameraController? controller;
  final Future<void>? initializeControllerFuture;
  /// Callback déclenché après chaque capture photo (hors mode QR)
  final void Function(XFile image)? onImageCaptured;

  const CameraPreviewWidget({
    super.key,
    this.isQrCodeMode = false,
    this.controller,
    this.initializeControllerFuture,
    this.onImageCaptured,
  });

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> with SingleTickerProviderStateMixin {
  CameraController? _localController;
  Future<void>? _localInitializeFuture;
  XFile? _capturedImage;
  AnimationController? _animationController;

  CameraController? get _controller => widget.controller ?? _localController;
  Future<void>? get _initializeControllerFuture => widget.initializeControllerFuture ?? _localInitializeFuture;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _initializeCamera();
    }
    if (widget.isQrCodeMode) {
      _animationController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2),
      )..repeat(reverse: true);

      // Lancer la simulation d'auto-détection du code QR après 3 secondes
      _startAutoScanSimulation();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint('No cameras available');
        return;
      }
      _localController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      _localInitializeFuture = _localController!.initialize();
      await _localInitializeFuture;
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  void _startAutoScanSimulation() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted || _capturedImage != null) return;
      _simulateQrCodeDetected();
    });
  }

  void _simulateQrCodeDetected() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 28),
              SizedBox(width: 10),
              Text('Ticket Validé', style: TextStyle(color: Colors.white, fontFamily: 'Inter')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Ticket: #QR-983427', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
              SizedBox(height: 12),
              Text('Véhicule: Toyota Corolla', style: TextStyle(color: AppTheme.textSecondary, fontFamily: 'Inter')),
              SizedBox(height: 6),
              Text('Durée de stationnement: 2h 15m', style: TextStyle(color: AppTheme.textSecondary, fontFamily: 'Inter')),
              SizedBox(height: 6),
              Text('Montant calculé: 1 500 FCFA', style: TextStyle(color: AppTheme.textSecondary, fontFamily: 'Inter')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
                _resetCapture();
                _startAutoScanSimulation(); // Relancer la simulation pour le prochain scan
              },
              child: const Text('Confirmer & imprimer le ticket', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final XFile picture = await _controller!.takePicture();
      setState(() {
        _capturedImage = picture;
      });
      // Notifier le parent
      widget.onImageCaptured?.call(picture);
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  void _resetCapture() {
    setState(() {
      _capturedImage = null;
    });
  }

  @override
  void dispose() {
    _localController?.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Center(
        child: Text('Aucune caméra disponible', style: TextStyle(color: Colors.white)),
      );
    }
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return ClipRRect(
            child: _capturedImage != null
                ? Stack(
                    children: [
                      Image.file(
                        File(_capturedImage!.path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      if (!widget.isQrCodeMode)
                        Positioned(
                          bottom: 80,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: ElevatedButton(
                              onPressed: _resetCapture,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.secondary,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(18),
                                elevation: 6,
                              ),
                              child: const Icon(
                                Icons.refresh_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                    ],
                  )
                : Stack(
                    children: [
                      SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _controller!.value.previewSize!.height,
                            height: _controller!.value.previewSize!.width,
                            child: CameraPreview(_controller!),
                          ),
                        ),
                      ),
                      // Overlay de Scan QR Code si activé
                      if (widget.isQrCodeMode) ...[
                        Positioned.fill(
                          child: CustomPaint(
                            painter: ScannerOverlayPainter(),
                          ),
                        ),
                        if (_animationController != null)
                          AnimatedBuilder(
                            animation: _animationController!,
                            builder: (context, child) {
                              final double value = _animationController!.value;
                              final double scanAreaSize = MediaQuery.of(context).size.width * 0.7;
                              final double top = MediaQuery.of(context).size.height / 2 - 50 - (scanAreaSize / 2) + (scanAreaSize * value);
                              final double left = MediaQuery.of(context).size.width * 0.15;
                              final double width = scanAreaSize;
                              
                              return Positioned(
                                top: top,
                                left: left,
                                width: width,
                                child: Container(
                                  height: 2.5,
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.secondary.withValues(alpha: 0.5),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                    color: AppTheme.secondary,
                                  ),
                                ),
                              );
                            },
                          ),
                        Positioned(
                          top: MediaQuery.of(context).size.height / 2 - 50 - (MediaQuery.of(context).size.width * 0.7 / 2) - 40,
                          left: 24,
                          right: 24,
                          child: const Center(
                            child: Text(
                              'Aligner le code QR dans le cadre',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                              ),
                            ),
                          ),
                        ),
                      ],
                      if (!widget.isQrCodeMode)
                        Positioned(
                          bottom: 80,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: ElevatedButton(
                              onPressed: _capturePhoto,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.secondary,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(18),
                                elevation: 6,
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Erreur caméra: ${snapshot.error}', style: const TextStyle(color: Colors.white)),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.5);
    final scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 50),
      width: size.width * 0.7,
      height: size.width * 0.7,
    );
    
    // Dessiner le fond sombre avec un trou carré au milieu
    canvas.drawPath(
      Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(16)))
        ..fillType = PathFillType.evenOdd,
      paint,
    );

    // Dessiner les coins du cadre de scan
    final borderPaint = Paint()
      ..color = AppTheme.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const double r = 16; // rayon des coins arrondis du rectangle
    const double borderLen = 24; // longueur des branches de coin

    // Coin Haut-Gauche
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.left, scanRect.top + borderLen)
        ..lineTo(scanRect.left, scanRect.top + r)
        ..arcToPoint(Offset(scanRect.left + r, scanRect.top), radius: const Radius.circular(r))
        ..lineTo(scanRect.left + borderLen, scanRect.top),
      borderPaint,
    );

    // Coin Haut-Droite
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.right - borderLen, scanRect.top)
        ..lineTo(scanRect.right - r, scanRect.top)
        ..arcToPoint(Offset(scanRect.right, scanRect.top + r), radius: const Radius.circular(r))
        ..lineTo(scanRect.right, scanRect.top + borderLen),
      borderPaint,
    );

    // Coin Bas-Gauche
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.left, scanRect.bottom - borderLen)
        ..lineTo(scanRect.left, scanRect.bottom - r)
        ..arcToPoint(Offset(scanRect.left + r, scanRect.bottom), radius: const Radius.circular(r), clockwise: false)
        ..lineTo(scanRect.left + borderLen, scanRect.bottom),
      borderPaint,
    );

    // Coin Bas-Droite
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.right - borderLen, scanRect.bottom)
        ..lineTo(scanRect.right - r, scanRect.bottom)
        ..arcToPoint(Offset(scanRect.right, scanRect.bottom - r), radius: const Radius.circular(r))
        ..lineTo(scanRect.right, scanRect.bottom - borderLen),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
