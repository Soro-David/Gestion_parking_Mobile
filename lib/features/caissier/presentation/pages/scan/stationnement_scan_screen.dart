import 'package:camera/camera.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/widgets/camera_preview_widget.dart';
import '../../../data/repositories/dio_caissier_stationnement_repository.dart';
import '../../../domain/repositories/caissier_stationnement_repository.dart';

class CaissierStationnementScanScreen extends StatefulWidget {
  final CameraController? controller;
  final Future<void>? initializeFuture;

  const CaissierStationnementScanScreen({
    super.key,
    this.controller,
    this.initializeFuture,
  });

  @override
  State<CaissierStationnementScanScreen> createState() =>
      _CaissierStationnementScanScreenState();
}

class _CaissierStationnementScanScreenState
    extends State<CaissierStationnementScanScreen> {
  // ── Dépendances ─────────────────────────────────────────────────
  final CaissierStationnementRepository _repository =
      DioCaissierStationnementRepository();

  // ── État OCR ────────────────────────────────────────────────────
  XFile? _capturedImage;
  bool _isAnalyzing = false;
  String? _ocrResult;
  String? _ocrError;

  // ── Formulaire bottom sheet ──────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _immatController;
  late TextEditingController _marqueController;
  late TextEditingController _modeleController;
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    _immatController = TextEditingController();
    _marqueController = TextEditingController();
    _modeleController = TextEditingController();
  }

  @override
  void dispose() {
    _immatController.dispose();
    _marqueController.dispose();
    _modeleController.dispose();
    super.dispose();
  }

  // ── Callback caméra : capture → OCR ─────────────────────────────
  Future<void> _onImageCaptured(XFile image) async {
    setState(() {
      _capturedImage = image;
      _isAnalyzing = true;
      _ocrResult = null;
      _ocrError = null;
    });

    try {
      final plate = await _repository.extractLicensePlate(image);
      if (!mounted) return;
      setState(() {
        _ocrResult = plate;
        _isAnalyzing = false;
        if (plate != null && plate.isNotEmpty) {
          _immatController.text = plate;
        }
      });
      // Ouvrir automatiquement le bottom sheet après l'OCR
      _showEntryBottomSheet();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _ocrError = e.toString().replaceFirst('Exception: ', '');
        _isAnalyzing = false;
      });
      _showEntryBottomSheet(withError: _ocrError);
    }
  }

  // ── Bottom Sheet ─────────────────────────────────────────────────
  void _showEntryBottomSheet({String? withError}) {
    // Si l'OCR n'a pas pré-rempli, on laisse vide
    if (_ocrResult == null || _ocrResult!.isEmpty) {
      _immatController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EntryBottomSheet(
        formKey: _formKey,
        immatController: _immatController,
        marqueController: _marqueController,
        modeleController: _modeleController,
        ocrError: withError,
        onSubmit: _registerStationnement,
      ),
    );
  }

  // ── Enregistrement ───────────────────────────────────────────────
  Future<void> _registerStationnement() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isRegistering = true);

    try {
      // parking_id = 1 par défaut (récupéré depuis la session en production)
      final success = await _repository.registerStationnement(
        parkingId: 1,
        licensePlate: _immatController.text.trim().toUpperCase(),
        marque: _marqueController.text.trim(),
        modele: _modeleController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isRegistering = false);

      if (success) {
        // Fermer le bottom sheet
        Navigator.of(context).pop();
        _resetState();
        _showSuccessSnackBar();
      } else {
        _showErrorSnackBar('Échec de l\'enregistrement. Veuillez réessayer.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isRegistering = false);
      Navigator.of(context).pop();
      _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _resetState() {
    setState(() {
      _capturedImage = null;
      _ocrResult = null;
      _ocrError = null;
      _immatController.clear();
      _marqueController.clear();
      _modeleController.clear();
    });
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Stationnement enregistré avec succès !',
                style: const TextStyle(
                    fontFamily: 'Inter', fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF22C55E),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ── UI ───────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Zone caméra (prend tout l'espace disponible) ──────────
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: CameraPreviewWidget(
                  controller: widget.controller,
                  initializeControllerFuture: widget.initializeFuture,
                  isQrCodeMode: false,
                  onImageCaptured: _onImageCaptured,
                ),
              ),

              // Overlay analyse OCR
              if (_isAnalyzing)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.6),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: AppTheme.secondary,
                            strokeWidth: 3,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Analyse IA en cours…',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Reconnaissance de la plaque',
                            style: TextStyle(
                              color: Colors.white60,
                              fontFamily: 'Inter',
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Badge résultat OCR
              if (_capturedImage != null && !_isAnalyzing && _ocrResult != null)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: _OcrResultBadge(plate: _ocrResult!),
                ),
            ],
          ),
        ),

        // ── Barre bouton "Saisir manuellement" ────────────────────
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
              onPressed:
                  (_isAnalyzing || _isRegistering) ? null : _showEntryBottomSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondary,
                disabledBackgroundColor:
                    AppTheme.secondary.withValues(alpha: 0.35),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              icon: (_isAnalyzing || _isRegistering)
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white54,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.edit_note_rounded, size: 22),
              label: Text(
                _isAnalyzing
                    ? 'Analyse en cours…'
                    : _isRegistering
                        ? 'Enregistrement…'
                        : 'Saisir manuellement',
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

// ═══════════════════════════════════════════════════════════════════
// Widget — Badge résultat OCR
// ═══════════════════════════════════════════════════════════════════
class _OcrResultBadge extends StatelessWidget {
  final String plate;
  const _OcrResultBadge({required this.plate});

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
            'Plaque détectée : $plate',
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

// ═══════════════════════════════════════════════════════════════════
// Widget — Drag handle "Glisser vers le haut"
// ═══════════════════════════════════════════════════════════════════
class _SwipeUpHandle extends StatefulWidget {
  final VoidCallback onSwipeUp;
  final bool isLoading;

  const _SwipeUpHandle({
    required this.onSwipeUp,
    required this.isLoading,
  });

  @override
  State<_SwipeUpHandle> createState() => _SwipeUpHandleState();
}

class _SwipeUpHandleState extends State<_SwipeUpHandle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _arrowAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _arrowAnim = Tween<double>(begin: 0.0, end: -8.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Glissement vers le haut
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null &&
            details.primaryVelocity! < -200 &&
            !widget.isLoading) {
          widget.onSwipeUp();
        }
      },
      // Tap aussi possible
      onTap: widget.isLoading ? null : widget.onSwipeUp,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 12, bottom: 28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.75),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: widget.isLoading
            ? const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white54,
                    strokeWidth: 2,
                  ),
                ),
              )
            : AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Fleches animées
                      Transform.translate(
                        offset: Offset(0, _arrowAnim.value),
                        child: Opacity(
                          opacity: _pulseAnim.value,
                          child: const Icon(
                            Icons.keyboard_arrow_up_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Handle pill
                      Opacity(
                        opacity: _pulseAnim.value,
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Label
                      Opacity(
                        opacity: _pulseAnim.value,
                        child: const Text(
                          'Glisser vers le haut',
                          style: TextStyle(
                            color: Colors.white70,
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Widget — Bottom Sheet d'enregistrement
// ═══════════════════════════════════════════════════════════════════
class _EntryBottomSheet extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController immatController;
  final TextEditingController marqueController;
  final TextEditingController modeleController;
  final String? ocrError;
  final Future<void> Function() onSubmit;

  const _EntryBottomSheet({
    required this.formKey,
    required this.immatController,
    required this.marqueController,
    required this.modeleController,
    required this.onSubmit,
    this.ocrError,
  });

  @override
  State<_EntryBottomSheet> createState() => _EntryBottomSheetState();
}

class _EntryBottomSheetState extends State<_EntryBottomSheet> {
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
    final bottomPadding = mediaQuery.padding.bottom; // barre système

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
            // Poignée
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

            // Titre
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.directions_car_rounded,
                      color: AppTheme.secondary, size: 22),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Enregistrer un stationnement',
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

            // Alerte erreur OCR
            if (widget.ocrError != null) ...[
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Color(0xFFEF4444), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Analyse IA échouée : ${widget.ocrError}\nVeuillez saisir la plaque manuellement.',
                        style: const TextStyle(
                          color: Color(0xFFEF4444),
                          fontFamily: 'Inter',
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Champ immatriculation
            _FormField(
              controller: widget.immatController,
              label: 'Immatriculation *',
              hint: 'Ex: AB-123-CD',
              icon: Icons.badge_rounded,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-\s]')),
                UpperCaseTextFormatter(),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'L\'immatriculation est obligatoire';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Champ marque
            _FormField(
              controller: widget.marqueController,
              label: 'Marque (optionnel)',
              hint: 'Ex: Toyota, Renault…',
              icon: Icons.branding_watermark_rounded,
            ),
            const SizedBox(height: 14),

            // Champ modèle
            _FormField(
              controller: widget.modeleController,
              label: 'Modèle (optionnel)',
              hint: 'Ex: Corolla, Clio…',
              icon: Icons.car_repair_rounded,
            ),
            const SizedBox(height: 24),

            // Bouton enregistrer
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  disabledBackgroundColor:
                      AppTheme.primary.withValues(alpha: 0.5),
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
                          Icon(Icons.save_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Enregistrer le stationnement',
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

// ═══════════════════════════════════════════════════════════════════
// Widget — Champ de formulaire stylisé
// ═══════════════════════════════════════════════════════════════════
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          borderSide:
              const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFFEF4444), width: 1.5),
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

// ═══════════════════════════════════════════════════════════════════
// Formatter — Majuscules automatiques
// ═══════════════════════════════════════════════════════════════════
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
