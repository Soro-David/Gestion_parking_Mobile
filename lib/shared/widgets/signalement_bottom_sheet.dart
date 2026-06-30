import 'package:flutter/material.dart';
import 'package:parking_mobile/core/theme/app_theme.dart';
import 'package:parking_mobile/shared/data/repositories/signalement_repository.dart';

class SignalementBottomSheet extends StatefulWidget {
  final String licensePlate;
  final int parkingId;
  final BuildContext parentContext;

  const SignalementBottomSheet({
    super.key,
    required this.licensePlate,
    required this.parkingId,
    required this.parentContext,
  });

  @override
  State<SignalementBottomSheet> createState() => _SignalementBottomSheetState();
}

class _SignalementBottomSheetState extends State<SignalementBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _motifController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _motifController = TextEditingController();
  }

  @override
  void dispose() {
    _motifController.dispose();
    super.dispose();
  }

  Future<void> _submitSignalement() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await SignalementRepository().createSignalement(
        parkingId: widget.parkingId,
        licensePlate: widget.licensePlate.trim().toUpperCase(),
        motif: _motifController.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context).pop(success);

      if (success) {
        ScaffoldMessenger.of(widget.parentContext).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Signalement enregistré avec succès !',
                    style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF22C55E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      } else {
        _showError('Échec de l\'enregistrement du signalement.');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(false);
      _showError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(widget.parentContext).showSnackBar(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;
    final keyboardInset = mediaQuery.viewInsets.bottom;

    return Container(
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
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    color: Colors.redAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.warning_amber_rounded,
                      color: Colors.redAccent, size: 22),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Signaler un problème',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Immatriculation (Lecture seule)
            const Text(
              'PLAQUE D\'IMMATRICULATION',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.directions_car_rounded, color: Colors.white70, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    widget.licensePlate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Motif du signalement
            const Text(
              'MOTIF DU SIGNALEMENT',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _motifController,
              maxLines: 4,
              minLines: 2,
              style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                hintText: 'Décrivez le problème constaté...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 14, fontFamily: 'Inter'),
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez saisir le motif du problème';
                }
                if (value.trim().length < 5) {
                  return 'Le motif doit contenir au moins 5 caractères';
                }
                return null;
              },
            ),
            const SizedBox(height: 28),

            // Boutons d'action
            _isSubmitting
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.redAccent),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Annuler',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _submitSignalement,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.redAccent, Color(0xFFDC2626)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.redAccent.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'Signaler',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
