import 'package:flutter/material.dart';
import 'package:parking_mobile/core/theme/app_theme.dart';
import 'package:parking_mobile/shared/domain/entities/parking_exit.dart';
import 'package:parking_mobile/shared/widgets/signalement_bottom_sheet.dart';

class CaissierSortieDetailScreen extends StatelessWidget {
	final ParkingExit exit;

	const CaissierSortieDetailScreen({
		super.key,
		required this.exit,
	});

	String _formatDuration(DateTime start, DateTime end) {
		final difference = end.difference(start);
		final hours = difference.inHours;
		final minutes = difference.inMinutes % 60;
		if (hours == 0) {
			return '$minutes min';
		}
		return '${hours}h ${minutes}m';
	}

	String _formatDateTime(DateTime dateTime) {
		final day = dateTime.day.toString().padLeft(2, '0');
		final month = dateTime.month.toString().padLeft(2, '0');
		final year = dateTime.year;
		final hour = dateTime.hour.toString().padLeft(2, '0');
		final minute = dateTime.minute.toString().padLeft(2, '0');
		return '$day/$month/$year à $hour:$minute';
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: AppTheme.background,
			appBar: AppBar(
				toolbarHeight: 80,
				backgroundColor: AppTheme.surface,
				elevation: 0,
				iconTheme: const IconThemeData(color: Colors.white),
				title: const Text(
					'Détails Sortie',
					style: TextStyle(
						color: Colors.white,
						fontFamily: 'Inter',
						fontSize: 22,
						fontWeight: FontWeight.bold,
					),
				),
				actions: [
					IconButton(
						icon: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 26),
						tooltip: 'Signaler un problème',
						onPressed: () {
							showModalBottomSheet<bool>(
								context: context,
								isScrollControlled: true,
								backgroundColor: Colors.transparent,
								builder: (ctx) => SignalementBottomSheet(
									licensePlate: exit.licensePlate,
									parkingId: exit.parkingId ?? 1,
									parentContext: context,
								),
							);
						},
					),
					const SizedBox(width: 8),
				],
			),
			body: ListView(
				padding: const EdgeInsets.all(24),
				children: [
					// 1. Visuel de Plaque d'Immatriculation Réaliste
					Center(
						child: Container(
							width: double.infinity,
							padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
							decoration: BoxDecoration(
								color: Colors.white,
								borderRadius: BorderRadius.circular(12),
								border: Border.all(color: const Color(0xFF143F85), width: 6),
								boxShadow: [
									BoxShadow(
										color: Colors.black.withValues(alpha: 0.5),
										blurRadius: 10,
										offset: const Offset(0, 5),
									),
								],
							),
							child: Row(
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children: [
									// Logo pays ou tag (ex: Cedeao/Sénégal)
									Container(
										width: 28,
										height: 50,
										decoration: BoxDecoration(
											color: const Color(0xFF143F85),
											borderRadius: BorderRadius.circular(4),
										),
										child: Column(
											mainAxisAlignment: MainAxisAlignment.center,
											children: const [
												Text('SN', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
												Icon(Icons.star, color: Colors.amber, size: 10),
											],
										),
									),
									// Le numéro de plaque au centre
									Expanded(
										child: Center(
											child: Text(
												exit.licensePlate,
												style: const TextStyle(
													color: Colors.black,
													fontSize: 28,
													fontWeight: FontWeight.w900,
													letterSpacing: 2.0,
													fontFamily: 'monospace',
												),
											),
										),
									),
									const SizedBox(width: 28), // Equilibre visuel avec le logo gauche
								],
							),
						),
					),
					const SizedBox(height: 16),
					// Type de véhicule sous la plaque
					Center(
						child: Text(
							exit.vehicleType,
							style: const TextStyle(
								color: Colors.white,
								fontSize: 18,
								fontWeight: FontWeight.bold,
							),
						),
					),
					const SizedBox(height: 32),

					// 2. Carte des Détails du Reçu de Sortie (Glassmorphic)
					Container(
						padding: const EdgeInsets.all(20),
						decoration: BoxDecoration(
							color: AppTheme.surface,
							borderRadius: BorderRadius.circular(24),
							border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
						),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Row(
									mainAxisAlignment: MainAxisAlignment.spaceBetween,
									children: [
										const Text(
											'REÇU DE SORTIE',
											style: TextStyle(
												color: AppTheme.textSecondary,
												fontSize: 12,
												fontWeight: FontWeight.bold,
												letterSpacing: 1.0,
											),
										),
										// Statut de paiement
										Container(
											padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
											decoration: BoxDecoration(
												color: Colors.greenAccent.withValues(alpha: 0.5),
												borderRadius: BorderRadius.circular(8),
											),
											child: Row(
												mainAxisSize: MainAxisSize.min,
												children: [
													Icon(Icons.check_circle_rounded, color: Colors.green[400], size: 12),
													const SizedBox(width: 4),
													Text(
														exit.status == 'regle' ? 'Réglé' : 'Impayé',
														style: TextStyle(
															color: Colors.green[400],
															fontSize: 11,
															fontWeight: FontWeight.bold,
														),
													),
												],
											),
										),
									],
								),
								const SizedBox(height: 8),
								Text(
									exit.ticketNumber,
									style: const TextStyle(
										color: Colors.white,
										fontSize: 22,
										fontWeight: FontWeight.bold,
										fontFamily: 'monospace',
									),
								),
								const Divider(color: Colors.white10, height: 24),
                
								// Informations clés
								_buildInfoRow(
									icon: Icons.login_rounded,
									label: 'Heure d\'entrée',
									value: _formatDateTime(exit.entryTime),
								),
								const SizedBox(height: 16),
								_buildInfoRow(
									icon: Icons.logout_rounded,
									label: 'Heure de sortie',
									value: _formatDateTime(exit.exitTime),
								),
								const SizedBox(height: 16),
								_buildInfoRow(
									icon: Icons.hourglass_full_rounded,
									label: 'Durée totale de présence',
									value: _formatDuration(exit.entryTime, exit.exitTime),
								),
								const SizedBox(height: 16),
								_buildInfoRow(
									icon: Icons.payments_rounded,
									label: 'Montant payé',
									value: ' ${exit.amount.toStringAsFixed(0)} FCFA',
									isAccent: true,
								),
								const SizedBox(height: 16),
								_buildInfoRow(
									icon: Icons.account_balance_wallet_rounded,
									label: 'Mode de paiement',
									value: exit.paymentMethod.toUpperCase(),
								),
								const SizedBox(height: 16),
								_buildInfoRow(
									icon: Icons.map_rounded,
									label: 'Zone / Emplacement',
									value: exit.zone,
								),
								const SizedBox(height: 16),
								_buildInfoRow(
									icon: Icons.person_rounded,
									label: 'Agent de sortie',
									value: exit.agentName ?? 'Non spécifié',
								),
								if (exit.notes != null && exit.notes!.isNotEmpty) ...[
									const SizedBox(height: 16),
									_buildInfoRow(
										icon: Icons.description_rounded,
										label: 'Observations',
										value: exit.notes!,
									),
								],
							],
						),
					),
					const SizedBox(height: 40),

					// 3. Actions
					ElevatedButton.icon(
						onPressed: () {
							ScaffoldMessenger.of(context).showSnackBar(
								const SnackBar(
									content: Text('Réimpression du reçu en cours...', style: TextStyle(fontFamily: 'Inter')),
									backgroundColor: AppTheme.primary,
								),
							);
						},
						style: ElevatedButton.styleFrom(
							backgroundColor: AppTheme.secondary,
							foregroundColor: Colors.white,
							padding: const EdgeInsets.symmetric(vertical: 16),
							shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
							elevation: 4,
						),
						icon: const Icon(Icons.print_rounded),
						label: const Text(
							'Réimprimer le reçu',
							style: TextStyle(
								fontSize: 16,
								fontWeight: FontWeight.bold,
								fontFamily: 'Inter',
							),
						),
					),
					const SizedBox(height: 12),
					OutlinedButton.icon(
						onPressed: () {
							showModalBottomSheet<bool>(
								context: context,
								isScrollControlled: true,
								backgroundColor: Colors.transparent,
								builder: (ctx) => SignalementBottomSheet(
									licensePlate: exit.licensePlate,
									parkingId: exit.parkingId ?? 1,
									parentContext: context,
								),
							);
						},
						style: OutlinedButton.styleFrom(
							foregroundColor: Colors.redAccent,
							backgroundColor: Colors.redAccent.withValues(alpha: 0.15),
							side: const BorderSide(color: Colors.redAccent, width: 1.5),
							padding: const EdgeInsets.symmetric(vertical: 16),
							shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
						),
						icon: const Icon(Icons.warning_amber_rounded),
						label: const Text(
							'Signaler un problème',
							style: TextStyle(
								fontSize: 16,
								fontWeight: FontWeight.bold,
								fontFamily: 'Inter',
							),
						),
					),
					const SizedBox(height: 90),
				],
			),
		);
	}

	Widget _buildInfoRow({
		required IconData icon,
		required String label,
		required String value,
		bool isAccent = false,
	}) {
		return Row(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Icon(icon, color: isAccent ? AppTheme.accent : AppTheme.textSecondary, size: 20),
				const SizedBox(width: 12),
				Expanded(
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Text(
								label,
								style: const TextStyle(
									color: AppTheme.textSecondary,
									fontSize: 12,
								),
							),
							const SizedBox(height: 4),
							Text(
								value,
								style: TextStyle(
									color: isAccent ? AppTheme.accent : Colors.white,
									fontSize: isAccent ? 18 : 15,
									fontWeight: FontWeight.bold,
								),
							),
						],
					),
				),
			],
		);
	}
}
