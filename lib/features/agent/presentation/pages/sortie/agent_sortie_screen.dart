import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:parking_mobile/core/routes/route_names.dart';
import 'package:parking_mobile/core/theme/app_theme.dart';
import 'package:parking_mobile/shared/domain/entities/parking_entry.dart';
import '../../../data/repositories/dio_agent_stationnement_repository.dart';
import '../../../domain/repositories/agent_stationnement_repository.dart';

class AgentSortieScreen extends StatefulWidget {
  const AgentSortieScreen({super.key});

  @override
  State<AgentSortieScreen> createState() => _AgentSortieScreenState();
}

class _AgentSortieScreenState extends State<AgentSortieScreen> {
  final AgentStationnementRepository _repository = DioAgentStationnementRepository();

  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _isAnalyzing = false;
  String? _qrResult;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _searchController;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isAnalyzing || _isSearching) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final code = barcodes.first.rawValue;
      if (code != null && code.isNotEmpty) {
        setState(() {
          _qrResult = code;
          _searchController.text = code;
        });
        _scannerController.stop(); // Stop scanning while bottom sheet is open
        _showExitBottomSheet();
      }
    }
  }

  void _showExitBottomSheet() {
    if (_qrResult == null || _qrResult!.isEmpty) {
      _searchController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ExitBottomSheet(
        formKey: _formKey,
        searchController: _searchController,
        onSubmit: _searchAndNavigateToDetail,
      ),
    ).whenComplete(() {
      // Resume scanning when bottom sheet is closed
      if (mounted) {
        _resetState();
        _scannerController.start();
      }
    });
  }

  Future<void> _searchAndNavigateToDetail() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSearching = true);

    try {
      final sessions = await _repository.getStationnementsEnCours();
      final input = _searchController.text.trim().toUpperCase();
      final cleanInput = input.replaceAll(RegExp(r'[^A-Z0-9]'), '');

      ParkingEntry? matchedSession;

      // 1. Exact match on Ticket Number or Plate
      for (final s in sessions) {
        final cleanSessionPlate = s.licensePlate.replaceAll(RegExp(r'[^A-Z0-9]'), '').toUpperCase();
        final ticketNum = s.ticketNumber.toUpperCase();
        if (cleanSessionPlate == cleanInput || ticketNum == input || ticketNum.contains(input)) {
          matchedSession = s;
          break;
        }
      }

      // 2. Substring match fallback for Plate
      if (matchedSession == null) {
        for (final s in sessions) {
          final cleanSessionPlate = s.licensePlate.replaceAll(RegExp(r'[^A-Z0-9]'), '').toUpperCase();
          if (cleanSessionPlate.contains(cleanInput) || cleanInput.contains(cleanSessionPlate)) {
            matchedSession = s;
            break;
          }
        }
      }

      if (!mounted) return;
      setState(() => _isSearching = false);

      if (matchedSession != null) {
        // Close bottom sheet
        Navigator.of(context).pop();
        _resetState();

        // Navigate to details
        context.push(AppRoutes.agentStationnementDetail, extra: matchedSession);
      } else {
        _showErrorSnackBar('Aucun stationnement en cours trouvé pour "$input".');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSearching = false);
      _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _resetState() {
    setState(() {
      _qrResult = null;
      _searchController.clear();
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontFamily: 'Inter'),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: MobileScanner(
                  controller: _scannerController,
                  onDetect: _onDetect,
                ),
              ),

              // Overlay for QR Code scanning frame
              Positioned.fill(
                child: CustomPaint(
                  painter: ScannerOverlayPainter(),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height / 2 - 50 - (MediaQuery.of(context).size.width * 0.7 / 2) - 40,
                left: 24,
                right: 24,
                child: const Center(
                  child: Text(
                    'Scanner le ticket QR Code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                    ),
                  ),
                ),
              ),

              if (_qrResult != null)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: _QrResultBadge(result: _qrResult!),
                ),
            ],
          ),
        ),

        SafeArea(
          top: false,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D1B35), Color(0xFF152A4A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: ElevatedButton.icon(
              onPressed: (_isAnalyzing || _isSearching) ? null : () {
                _scannerController.stop();
                _showExitBottomSheet();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondary,
                disabledBackgroundColor: AppTheme.secondary.withValues(alpha: 0.35),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              icon: (_isAnalyzing || _isSearching)
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white54,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.qr_code_scanner_rounded, size: 22),
              label: Text(
                _isSearching
                    ? 'Recherche…'
                    : 'Saisir Plaque ou Ticket',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
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
    
    canvas.drawPath(
      Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(16)))
        ..fillType = PathFillType.evenOdd,
      paint,
    );

    final borderPaint = Paint()
      ..color = AppTheme.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const double r = 16;
    const double borderLen = 24;

    canvas.drawPath(
      Path()
        ..moveTo(scanRect.left, scanRect.top + borderLen)
        ..lineTo(scanRect.left, scanRect.top + r)
        ..arcToPoint(Offset(scanRect.left + r, scanRect.top), radius: const Radius.circular(r))
        ..lineTo(scanRect.left + borderLen, scanRect.top),
      borderPaint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(scanRect.right - borderLen, scanRect.top)
        ..lineTo(scanRect.right - r, scanRect.top)
        ..arcToPoint(Offset(scanRect.right, scanRect.top + r), radius: const Radius.circular(r))
        ..lineTo(scanRect.right, scanRect.top + borderLen),
      borderPaint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(scanRect.left, scanRect.bottom - borderLen)
        ..lineTo(scanRect.left, scanRect.bottom - r)
        ..arcToPoint(Offset(scanRect.left + r, scanRect.bottom), radius: const Radius.circular(r), clockwise: false)
        ..lineTo(scanRect.left + borderLen, scanRect.bottom),
      borderPaint,
    );

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

class _QrResultBadge extends StatelessWidget {
  final String result;
  const _QrResultBadge({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22C55E).withValues(alpha: 0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            'QR Détecté : $result',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExitBottomSheet extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController searchController;
  final Future<void> Function() onSubmit;

  const _ExitBottomSheet({
    required this.formKey,
    required this.searchController,
    required this.onSubmit,
  });

  @override
  State<_ExitBottomSheet> createState() => _ExitBottomSheetState();
}

class _ExitBottomSheetState extends State<_ExitBottomSheet> {
  bool _isSubmitting = false;

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);
    await widget.onSubmit();
    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardInset = mediaQuery.viewInsets.bottom;
    final bottomPadding = mediaQuery.padding.bottom;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF1A2540),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        24 + keyboardInset + (keyboardInset > 0 ? 0 : bottomPadding),
      ),
      child: Form(
        key: widget.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.logout_rounded,
                      color: AppTheme.secondary, size: 22),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Enregistrer une sortie',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _FormField(
              controller: widget.searchController,
              label: 'N° Ticket ou Immatriculation *',
              hint: 'Ex: QR-12345 ou AB-123-CD',
              icon: Icons.search_rounded,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-\s]')),
                UpperCaseTextFormatter(),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Le champ est obligatoire';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  disabledBackgroundColor: AppTheme.primary.withValues(alpha: 0.5),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Rechercher le stationnement',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.validator,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      inputFormatters: inputFormatters,
      style: const TextStyle(
        color: Colors.white,
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.secondary, size: 20),
        labelStyle: const TextStyle(
          color: Colors.white60,
          fontFamily: 'Inter',
          fontSize: 13,
        ),
        hintStyle: const TextStyle(
          color: Colors.white24,
          fontFamily: 'Inter',
          fontSize: 13,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.secondary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        errorStyle: const TextStyle(
          color: Color(0xFFEF4444),
          fontFamily: 'Inter',
          fontSize: 11,
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
