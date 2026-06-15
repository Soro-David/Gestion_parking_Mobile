import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class CaissierStationnementDetailScreen extends StatefulWidget {
  final Map<String, dynamic> stationnement;

  const CaissierStationnementDetailScreen({
    super.key,
    required this.stationnement,
  });

  @override
  State<CaissierStationnementDetailScreen> createState() => _CaissierStationnementDetailScreenState();
}

class _CaissierStationnementDetailScreenState extends State<CaissierStationnementDetailScreen> {
  late Map<String, dynamic> _data;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _data = Map<String, dynamic>.from(widget.stationnement);
  }

  // Génère un numéro de ticket factice à partir de la plaque
  String get _ticketNumber {
    final cleanPlaque = _data['plaque'].toString().replaceAll('-', '').replaceAll(' ', '');
    return 'TK-$cleanPlaque';
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = _data['statut'] == 'Actif';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Détails Stationnement',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Inter',
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E1E2C), Color(0xFF232539)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isProcessing
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.secondary,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── En-tête Plaque & Statut ──
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.directions_car_rounded,
                            color: Colors.greenAccent,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Affichage réaliste de la plaque d'immatriculation (Style Afrique Centrale/CEMAC)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F9F9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF143F85), width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            _data['plaque'],
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Badge Statut
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isActive ? Colors.greenAccent.withValues(alpha: 0.5) : Colors.redAccent.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isActive ? Colors.greenAccent : Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isActive ? 'Session Active' : 'Session Clôturée',
                                style: TextStyle(
                                  color: isActive ? Colors.greenAccent : Colors.redAccent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Carte Détails ──
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.numbers_rounded, 'N° de Ticket', _ticketNumber),
                        _buildDivider(),
                        _buildInfoRow(Icons.map_rounded, 'Zone / Secteur', _data['zone']),
                        _buildDivider(),
                        _buildInfoRow(Icons.local_parking_rounded, 'Emplacement précis', 'Place ${_data['place']}'),
                        _buildDivider(),
                        _buildInfoRow(Icons.calendar_month_rounded, 'Date de début', _data['date']),
                        _buildDivider(),
                        _buildInfoRow(Icons.access_time_filled_rounded, 'Heure d\'arrivée', _data['heureEntree']),
                        _buildDivider(),
                        _buildInfoRow(Icons.hourglass_top_rounded, 'Durée écoulée', _data['duree']),
                        _buildDivider(),
                        _buildInfoRow(
                          Icons.monetization_on_rounded,
                          'Montant cumulé',
                          _data['montant'],
                          valueColor: AppTheme.accent,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Actions Caissier ──
                  if (isActive) ...[
                    ElevatedButton.icon(
                      onPressed: () => _showCheckoutDialog(context),
                      icon: const Icon(Icons.check_circle_outline_rounded),
                      label: const Text('Enregistrer la sortie'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                        shadowColor: AppTheme.primary.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _showExtendDialog(context),
                      icon: const Icon(Icons.add_alarm_rounded, color: Colors.white),
                      label: const Text(
                        'Prolonger le temps',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Message session terminée
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: AppTheme.textSecondary),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Ce stationnement a été réglé et clôturé. Aucune action supplémentaire n\'est requise.',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  // Ligne d'information stylisée
  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                fontFamily: 'Inter',
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 1,
        color: Colors.white.withValues(alpha: 0.5),
      ),
    );
  }

  // Bouton secondaire d'action
  // ignore: unused_element
  Widget _buildSecondaryActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white70,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Dialogue d'Encaissement ──
  void _showCheckoutDialog(BuildContext context) {
    String selectedMethod = 'OM'; // OM, MoMo, Cash, Card
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                50 + MediaQuery.of(context).viewInsets.bottom,
              ),
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
                  const Text(
                    'Encaisser le règlement',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sélectionnez le moyen de paiement pour clore le stationnement de la plaque ${_data['plaque']}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Total à payer
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'TOTAL À ENCAISSER',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _data['montant'],
                          style: const TextStyle(
                            color: AppTheme.accent,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Options de paiement
                  _buildPaymentOption(
                    id: 'OM',
                    name: 'Orange Money',
                    icon: Icons.phone_android_rounded,
                    color: Colors.orange,
                    assetPath: 'assets/logos/orange_money.png',
                    selectedValue: selectedMethod,
                    onTap: (val) => setModalState(() => selectedMethod = val),
                  ),
                  const SizedBox(height: 8),
                  _buildPaymentOption(
                    id: 'MOMO',
                    name: 'MTN Mobile Money',
                    icon: Icons.mobile_friendly_rounded,
                    color: Colors.amber,
                    assetPath: 'assets/logos/mtn_momo.png',
                    selectedValue: selectedMethod,
                    onTap: (val) => setModalState(() => selectedMethod = val),
                  ),
                  const SizedBox(height: 8),
                  _buildPaymentOption(
                    id: 'WAVE',
                    name: 'Wave',
                    icon: Icons.waves_rounded,
                    color: const Color(0xFF1DC3E2),
                    assetPath: 'assets/logos/wave.png',
                    selectedValue: selectedMethod,
                    onTap: (val) => setModalState(() => selectedMethod = val),
                  ),
                  const SizedBox(height: 8),
                  _buildPaymentOption(
                    id: 'MOOV',
                    name: 'Moov Money',
                    icon: Icons.account_balance_wallet_rounded,
                    color: Colors.deepOrange,
                    assetPath: 'assets/logos/moov_money.png',
                    selectedValue: selectedMethod,
                    onTap: (val) => setModalState(() => selectedMethod = val),
                  ),
                  const SizedBox(height: 8),
                  _buildPaymentOption(
                    id: 'CASH',
                    name: 'Espèces / Cash',
                    icon: Icons.money_rounded,
                    color: Colors.greenAccent,
                    selectedValue: selectedMethod,
                    onTap: (val) => setModalState(() => selectedMethod = val),
                  ),
                  const SizedBox(height: 24),

                  // Bouton valider
                  ElevatedButton(
                    onPressed: () {
                      context.pop(); // Fermer le bottom sheet
                      _processPayment(selectedMethod);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      minimumSize: const Size(double.infinity, 56),
                      elevation: 4,
                      shadowColor: AppTheme.primary.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Confirmer le Paiement',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String name,
    required IconData icon,
    required Color color,
    String? assetPath,
    required String selectedValue,
    required ValueChanged<String> onTap,
  }) {
    final isSelected = selectedValue == id;
    return InkWell(
      onTap: () => onTap(id),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.5) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.white.withValues(alpha: 0.5),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: assetPath != null ? Colors.white : color.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              child: assetPath != null
                  ? Padding(
                      padding: const EdgeInsets.all(4),
                      child: Image.asset(
                        assetPath,
                        fit: BoxFit.contain,
                      ),
                    )
                  : Center(child: Icon(icon, color: color, size: 20)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 15,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: color, size: 22)
            else
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white30, width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Traitement du paiement fictif
  void _processPayment(String method) {
    setState(() {
      _isProcessing = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _data['statut'] = 'Payé';
      });

      // Afficher le dialogue de succès
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            backgroundColor: AppTheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
                      color: Colors.greenAccent,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Paiement Enregistré !',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Le stationnement pour ${_data['plaque']} a été réglé avec succès via ${method == 'OM' ? 'Orange Money' : method == 'MOMO' ? 'MTN MoMo' : method == 'CASH' ? 'Espèces' : 'Carte Bancaire'}.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            context.pop();
                            _simulatePrint(context);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.print_rounded, size: 16, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Reçu', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            context.pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Fermer'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  // ── Dialogue Prolonger le temps ──
  void _showExtendDialog(BuildContext context) {
    int durationMinutes = 60; // Par défaut +1h
    int costPerHour = 500;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            int extraCost = ((durationMinutes / 60) * costPerHour).round();
            return AlertDialog(
              backgroundColor: AppTheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Prolonger la durée',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Sélectionnez le temps additionnel à allouer :',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, fontFamily: 'Inter'),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTimeSelectButton(
                        minutes: 30,
                        current: durationMinutes,
                        onTap: (val) => setDialogState(() => durationMinutes = val),
                      ),
                      _buildTimeSelectButton(
                        minutes: 60,
                        current: durationMinutes,
                        onTap: (val) => setDialogState(() => durationMinutes = val),
                      ),
                      _buildTimeSelectButton(
                        minutes: 120,
                        current: durationMinutes,
                        onTap: (val) => setDialogState(() => durationMinutes = val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Coût additionnel :',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontFamily: 'Inter'),
                        ),
                        Text(
                          '$extraCost FCFA',
                          style: const TextStyle(
                            color: AppTheme.accent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Annuler', style: TextStyle(color: AppTheme.textSecondary, fontFamily: 'Inter')),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.pop();
                    _confirmExtension(durationMinutes, extraCost);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Confirmer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTimeSelectButton({required int minutes, required int current, required ValueChanged<int> onTap}) {
    final isSelected = minutes == current;
    final String label = minutes >= 60 ? '${(minutes / 60).round()}h' : '${minutes}m';
    return InkWell(
      onTap: () => onTap(minutes),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.secondary : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.secondary : Colors.white12),
        ),
        child: Text(
          '+$label',
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }

  void _confirmExtension(int minutes, int cost) {
    setState(() {
      _isProcessing = true;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        // Mettre à jour fictivement la durée et le montant
        final existingMontant = int.tryParse(_data['montant'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final newMontant = existingMontant + cost;
        _data['montant'] = '${_formatWithSpaces(newMontant)} FCFA';

        final double hoursAdded = minutes / 60;
        // On modifie juste la chaine de durée pour la démo
        _data['duree'] = '${_data['duree']} (+${hoursAdded >= 1 ? '${hoursAdded.round()}h' : '${minutes}m'})';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Temps prolongé de +${minutes >= 60 ? '${(minutes / 60).round()}h' : '${minutes}min'} avec succès !',
            style: const TextStyle(fontFamily: 'Inter'),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  String _formatWithSpaces(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if ((str.length - i) % 3 == 0 && i != 0) {
        buffer.write(' ');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  // ── Impression Reçu/Ticket ──
  void _simulatePrint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Impression du reçu en cours...', style: TextStyle(fontFamily: 'Inter')),
          ],
        ),
        backgroundColor: AppTheme.surface,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ── Dialogue Signaler Infraction ──
  // ignore: unused_element
  void _showReportDialog(BuildContext context) {
    String selectedInfraction = 'Non-paiement';
    final List<String> types = [
      'Non-paiement',
      'Dépassement de temps',
      'Stationnement hors zone',
      'Véhicule gênant la circulation',
      'Autre'
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Signaler une infraction',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Choisissez le type d\'infraction :',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontFamily: 'Inter'),
                  ),
                  const SizedBox(height: 12),
                  ...types.map((type) {
                    final isSel = type == selectedInfraction;
                    return RadioListTile<String>(
                      title: Text(
                        type,
                        style: TextStyle(
                          color: isSel ? Colors.white : Colors.white70,
                          fontSize: 14,
                          fontFamily: 'Inter',
                        ),
                      ),
                      value: type,
                      // ignore: deprecated_member_use
                          groupValue: selectedInfraction,
                      activeColor: Colors.orangeAccent,
                      contentPadding: EdgeInsets.zero,
                      // ignore: deprecated_member_use
                          onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedInfraction = val);
                        }
                      },
                    );
                  }),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Annuler', style: TextStyle(color: AppTheme.textSecondary, fontFamily: 'Inter')),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Infraction "$selectedInfraction" signalée aux agents de terrain !'),
                        backgroundColor: Colors.orangeAccent,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Signaler'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
