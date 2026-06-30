import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parking_mobile/core/theme/app_theme.dart';
import 'package:parking_mobile/shared/domain/entities/parking_entry.dart';
import 'package:parking_mobile/shared/widgets/signalement_bottom_sheet.dart';

class AgentEntreeDetailScreen extends StatelessWidget {
	final ParkingEntry entry;

	const AgentEntreeDetailScreen({
		super.key,
		required this.entry,
	});

	String _formatDuration(DateTime entryTime) {
		final difference = DateTime.now().difference(entryTime);
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
				leading: IconButton(
					icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
					onPressed: () => context.pop(),
				),
				title: const Text(
					'Détails de l\'Entrée',
					style: TextStyle(
						color: Colors.white,
						fontFamily: 'Inter',
						fontSize: 22,
						fontWeight: FontWeight.bold,
					),
				),
				centerTitle: true,
			),
			body: SingleChildScrollView(
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: [
						Padding(
							padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
							child: Container(
								padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
								decoration: BoxDecoration(
									color: AppTheme.surface,
									borderRadius: BorderRadius.circular(20),
									boxShadow: [
										BoxShadow(
											color: Colors.black.withValues(alpha: 0.08),
											blurRadius: 12,
											offset: const Offset(0, 4),
										),
									],
								),
								child: Column(
									children: [
										Container(
											padding: const EdgeInsets.all(16),
											decoration: BoxDecoration(
												color: AppTheme.secondary.withValues(alpha: 0.15),
												shape: BoxShape.circle,
											),
											child: const Icon(
												Icons.directions_car_rounded,
												color: AppTheme.secondary,
												size: 40,
											),
										),
										const SizedBox(height: 16),
										Text(
											entry.vehicleType.isNotEmpty ? entry.vehicleType : 'Véhicule inconnu',
											style: const TextStyle(
												color: Colors.white,
												fontSize: 20,
												fontWeight: FontWeight.bold,
												fontFamily: 'Inter',
											),
										),
										const SizedBox(height: 12),
										Container(
											padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
											decoration: BoxDecoration(
												color: Colors.white,
												borderRadius: BorderRadius.circular(8),
												border: Border.all(color: const Color(0xFF143F85), width: 3),
												boxShadow: [
													BoxShadow(
														color: Colors.black.withValues(alpha: 0.2),
														blurRadius: 4,
														offset: const Offset(0, 2),
													),
												],
											),
											child: Row(
												mainAxisSize: MainAxisSize.min,
												children: [
													Container(
														padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
														decoration: BoxDecoration(
															color: const Color(0xFF143F85),
															borderRadius: BorderRadius.circular(4),
														),
														child: const Text('SN', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
													),
													const SizedBox(width: 12),
													Text(
														entry.licensePlate,
														style: const TextStyle(
															color: Colors.black,
															fontSize: 22,
															fontWeight: FontWeight.w900,
															letterSpacing: 2.0,
															fontFamily: 'monospace',
														),
													),
												],
											),
										),
										const SizedBox(height: 16),
										Container(
											padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
											decoration: BoxDecoration(
												color: Colors.greenAccent.withValues(alpha: 0.15),
												borderRadius: BorderRadius.circular(12),
											),
											child: Row(
												mainAxisSize: MainAxisSize.min,
												children: [
													Container(
														width: 8,
														height: 8,
														decoration: const BoxDecoration(
															color: Colors.greenAccent,
															shape: BoxShape.circle,
														),
													),
													const SizedBox(width: 8),
													Text(
														entry.status == 'en_cours' ? 'En stationnement' : 'Terminé',
														style: const TextStyle(
															color: Colors.greenAccent,
															fontSize: 13,
															fontWeight: FontWeight.bold,
														),
													),
												],
											),
										),
									],
								),
							),
						),
						const SizedBox(height: 24),

						Padding(
							padding: const EdgeInsets.symmetric(horizontal: 20),
							child: _buildSectionCard(
								title: 'TICKET DE STATIONNEMENT',
								icon: Icons.receipt_long_rounded,
								items: [
									_buildInfoRow(
										icon: Icons.numbers_rounded,
										label: 'N° de Ticket',
										value: entry.ticketNumber,
										valueColor: AppTheme.accent,
									),
									_buildDivider(),
									_buildInfoRow(
										icon: Icons.access_time_filled_rounded,
										label: 'Heure d\'entrée',
										value: _formatDateTime(entry.entryTime),
									),
									_buildDivider(),
									_buildInfoRow(
										icon: Icons.hourglass_top_rounded,
										label: 'Durée de présence',
										value: _formatDuration(entry.entryTime),
									),
									_buildDivider(),
									_buildInfoRow(
										icon: Icons.location_on_rounded,
										label: 'Zone / Emplacement',
										value: entry.zone,
									),
									_buildDivider(),
									_buildInfoRow(
										icon: Icons.person_rounded,
										label: 'Agent d\'accueil',
										value: entry.agentName ?? 'Non spécifié',
									),
									if (entry.notes != null && entry.notes!.isNotEmpty) ...[
										_buildDivider(),
										_buildInfoRow(
											icon: Icons.description_rounded,
											label: 'Observations',
											value: entry.notes!,
										),
									],
								],
							),
						),

						const SizedBox(height: 32),

						Padding(
							padding: const EdgeInsets.symmetric(horizontal: 20),
							child: Column(
								children: [
									GestureDetector(
										onTap: () {
											ScaffoldMessenger.of(context).showSnackBar(
												const SnackBar(
													content: Row(
														children: [
															Icon(Icons.print_rounded, color: Colors.white, size: 20),
															SizedBox(width: 10),
															Text('Impression du ticket en cours...'),
														],
													),
													backgroundColor: AppTheme.secondary,
													behavior: SnackBarBehavior.floating,
												),
											);
										},
										child: Container(
											width: double.infinity,
											padding: const EdgeInsets.symmetric(vertical: 16),
											decoration: BoxDecoration(
												gradient: const LinearGradient(
													colors: [AppTheme.primary, AppTheme.secondary],
													begin: Alignment.centerLeft,
													end: Alignment.centerRight,
												),
												borderRadius: BorderRadius.circular(16),
												boxShadow: [
													BoxShadow(
														color: AppTheme.primary.withValues(alpha: 0.4),
														blurRadius: 12,
														offset: const Offset(0, 6),
													),
												],
											),
											child: const Row(
												mainAxisAlignment: MainAxisAlignment.center,
												children: [
													Icon(Icons.print_rounded, color: Colors.white, size: 20),
													SizedBox(width: 10),
													Text(
														'Imprimer le ticket',
														style: TextStyle(
															color: Colors.white,
															fontSize: 16,
															fontWeight: FontWeight.bold,
															fontFamily: 'Inter',
														),
													),
												],
											),
										),
									),
									const SizedBox(height: 16),
									GestureDetector(
										onTap: () {
											showModalBottomSheet<bool>(
												context: context,
												isScrollControlled: true,
												backgroundColor: Colors.transparent,
												builder: (ctx) => SignalementBottomSheet(
													licensePlate: entry.licensePlate,
													parkingId: entry.parkingId ?? 1,
													parentContext: context,
												),
											);
										},
										child: Container(
											width: double.infinity,
											padding: const EdgeInsets.symmetric(vertical: 16),
											decoration: BoxDecoration(
												color: Colors.redAccent.withValues(alpha: 0.15),
												borderRadius: BorderRadius.circular(16),
												border: Border.all(color: Colors.redAccent, width: 1.5),
											),
											child: const Row(
												mainAxisAlignment: MainAxisAlignment.center,
												children: [
													Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
													SizedBox(width: 10),
													Text(
														'Signaler un problème',
														style: TextStyle(
															color: Colors.redAccent,
															fontSize: 16,
															fontWeight: FontWeight.bold,
															fontFamily: 'Inter',
														),
													),
												],
											),
										),
									),
								],
							),
						),

						const SizedBox(height: 60),
					],
				),
			),
		);
	}

	Widget _buildSectionCard({
		required String title,
		required IconData icon,
		required List<Widget> items,
	}) {
		return Container(
			decoration: BoxDecoration(
				color: AppTheme.surface,
				borderRadius: BorderRadius.circular(20),
				boxShadow: [
					BoxShadow(
						color: Colors.black.withValues(alpha: 0.08),
						blurRadius: 12,
						offset: const Offset(0, 4),
					),
				],
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Padding(
						padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
						child: Row(
							children: [
								Container(
									padding: const EdgeInsets.all(8),
									decoration: BoxDecoration(
										color: AppTheme.secondary.withValues(alpha: 0.15),
										borderRadius: BorderRadius.circular(10),
									),
									child: Icon(icon, color: AppTheme.secondary, size: 18),
								),
								const SizedBox(width: 12),
								Text(
									title,
									style: const TextStyle(
										color: Colors.white,
										fontSize: 12,
										fontWeight: FontWeight.bold,
										letterSpacing: 1.0,
										fontFamily: 'Inter',
									),
								),
							],
						),
					),
					const SizedBox(height: 4),
					...items,
					const SizedBox(height: 8),
				],
			),
		);
	}

	Widget _buildInfoRow({
		required IconData icon,
		required String label,
		required String value,
		Color? valueColor,
	}) {
		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
			child: Row(
				crossAxisAlignment: CrossAxisAlignment.center,
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
				color: Colors.white.withValues(alpha: 0.06),
			),
		);
	}
}
