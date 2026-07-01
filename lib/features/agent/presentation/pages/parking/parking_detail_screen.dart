import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parking_mobile/core/theme/app_theme.dart';

class ParkingDetailScreen extends StatefulWidget {
	final Map<String, dynamic> data;

	const ParkingDetailScreen({
		super.key,
		required this.data,
	});

	@override
	State<ParkingDetailScreen> createState() => _ParkingDetailScreenState();
}

class _ParkingDetailScreenState extends State<ParkingDetailScreen> {
	late Map<String, dynamic> _data;
	final bool _isProcessing = false;

	@override
	void initState() {
		super.initState();
		_data = Map<String, dynamic>.from(widget.data);
	}

	String get _ticketNumber {
		final cleanPlaque = _data['plaque'].toString().replaceAll('-', '').replaceAll(' ', '');
		return 'TK-$cleanPlaque';
	}

	@override
	Widget build(BuildContext context) {
		final bool isActive = _data['statut'] == 'actif';

		return Scaffold(
			backgroundColor: AppTheme.background,
			appBar: AppBar(
				toolbarHeight: 80,
				backgroundColor: AppTheme.surface,
				elevation: 0,
				leading: IconButton(
					icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
					onPressed: () => context.pop(),
				),
				title: const Text(
					'Détail Stationnement',
					style: TextStyle(
						color: Colors.white,
						fontFamily: 'Inter',
						fontSize: 22,
						fontWeight: FontWeight.bold,
					),
				),
				centerTitle: true,
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
												_buildInfoRow(
													Icons.exit_to_app_rounded,
													'Heure de sortie',
													_data['heureSortie'] ?? '—',
												),
												_buildDivider(),
												_buildInfoRow(Icons.hourglass_top_rounded, 'Durée écoulée', _data['duree']),
												_buildDivider(),
												_buildInfoRow(
													Icons.monetization_on_rounded,
													'Tarif / Montant',
													_data['montant'],
													valueColor: AppTheme.accent,
												),
											],
										),
									),
									const SizedBox(height: 32),

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
															'Cette session est clôturée. La place de stationnement a été libérée.',
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

	void _showCheckoutDialog(BuildContext context) {

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
										'Enregistrer la sortie',
										style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
									),
									const SizedBox(height: 12),
									Text('Selectionner le mode de paiement et confirmer.'),
									const SizedBox(height: 20),
									ElevatedButton(
										onPressed: () {
											Navigator.of(context).pop();
											ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sortie enregistrée')));
										},
										child: const Text('Confirmer le paiement'),
									),
								],
							),
						);
					},
				);
			},
		);
	}

	void _showExtendDialog(BuildContext context) {
		showDialog(
			context: context,
			builder: (context) => AlertDialog(
				title: const Text('Prolonger le temps'),
				content: const Text('Fonctionnalité de prolongation non implémentée.'),
				actions: [
					TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Fermer')),
				],
			),
		);
	}
}
