import 'package:flutter/material.dart';
import 'package:parking_mobile/core/theme/app_theme.dart';
import 'package:parking_mobile/shared/domain/entities/parking_entry.dart';
import 'package:parking_mobile/features/agent/presentation/providers/agent_stationnement_provider.dart';
import 'package:parking_mobile/core/routes/route_names.dart';
import 'package:go_router/go_router.dart';

/// Écran listant les stationnements en cours enregistrés par cet agent.
/// Consomme GET /api/attendant/parking-sessions/stationnement_en_cours
class AgentStationnementEnCoursScreen extends StatefulWidget {
	const AgentStationnementEnCoursScreen({super.key});

	@override
	State<AgentStationnementEnCoursScreen> createState() =>
			_AgentStationnementEnCoursScreenState();
}

class _AgentStationnementEnCoursScreenState
		extends State<AgentStationnementEnCoursScreen> {
	List<ParkingEntry> _allRecords = [];
	List<ParkingEntry> _filteredRecords = [];
	String _searchQuery = '';
	bool _isLoading = false;
	String? _errorMessage;

	@override
	void initState() {
		super.initState();
		_loadData();
	}

	Future<void> _loadData() async {
		if (!mounted) return;
		setState(() {
			_isLoading = true;
			_errorMessage = null;
		});

		try {
			final records =
					await AgentStationnementProvider.repository.getStationnementsEnCours();
			if (mounted) {
				setState(() {
					_allRecords = records;
					_isLoading = false;
					_filter(_searchQuery);
				});
			}
		} catch (e) {
			if (mounted) {
				setState(() {
					_errorMessage = e.toString().replaceAll('Exception: ', '');
					_isLoading = false;
				});
			}
		}
	}

	void _filter(String query) {
		setState(() {
			_searchQuery = query.toLowerCase();
			if (_searchQuery.isEmpty) {
				_filteredRecords = List.from(_allRecords);
			} else {
				_filteredRecords = _allRecords
						.where((e) =>
								e.licensePlate.toLowerCase().contains(_searchQuery) ||
								e.vehicleType.toLowerCase().contains(_searchQuery))
						.toList();
			}
		});
	}

	String _formatDuration(DateTime entryTime) {
		final difference = DateTime.now().difference(entryTime);
		final hours = difference.inHours;
		final minutes = difference.inMinutes % 60;
		if (hours == 0) return '$minutes min';
		return '${hours}h ${minutes}m';
	}

	String _formatDate(DateTime dt) {
		final months = [
			'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
			'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
		];
		return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
	}

	int _calculateEstimatedCost(DateTime entryTime) {
		final difference = DateTime.now().difference(entryTime);
		final hours = (difference.inMinutes / 60.0).ceil();
		final cost = hours * 500;
		return cost > 0 ? cost : 500; // minimum 500 FCFA
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: AppTheme.background,
			appBar: AppBar(
				toolbarHeight: 80,
				automaticallyImplyLeading: false,
				title: const Text(
					'Stationnements en cours',
					style: TextStyle(
						fontFamily: 'Inter',
						fontSize: 20,
						fontWeight: FontWeight.bold,
						color: Colors.white,
					),
				),
				centerTitle: true,
				backgroundColor: Colors.transparent,
				elevation: 0,
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
			body: Column(
				children: [
					// ── Champ de recherche ──
					Padding(
						padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
						child: TextField(
							onChanged: _filter,
							style: const TextStyle(color: Colors.white),
							decoration: InputDecoration(
								filled: true,
								fillColor: AppTheme.surface,
								prefixIcon: const Icon(Icons.search_rounded,
										color: AppTheme.textSecondary),
								hintText: 'Rechercher par immatriculation...',
								hintStyle: const TextStyle(
										color: AppTheme.textSecondary,
										fontSize: 14,
										fontFamily: 'Inter'),
								border: OutlineInputBorder(
									borderRadius: BorderRadius.circular(16),
									borderSide:
											BorderSide(color: Colors.white.withValues(alpha: 0.5)),
								),
								enabledBorder: OutlineInputBorder(
									borderRadius: BorderRadius.circular(16),
									borderSide:
											BorderSide(color: Colors.white.withValues(alpha: 0.5)),
								),
								focusedBorder: OutlineInputBorder(
									borderRadius: BorderRadius.circular(16),
									borderSide: const BorderSide(
											color: AppTheme.secondary, width: 1.5),
								),
							),
						),
					),

					// ── Contenu ──
					Expanded(child: _buildBodyContent()),
				],
			),
		);
	}

	Widget _buildBodyContent() {
		if (_isLoading && _allRecords.isEmpty) {
			return const Center(
				child: CircularProgressIndicator(
					valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondary),
				),
			);
		}

		if (_errorMessage != null && _allRecords.isEmpty) {
			return Center(
				child: Padding(
					padding: const EdgeInsets.all(24.0),
					child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							const Icon(Icons.error_outline_rounded,
									color: Colors.redAccent, size: 48),
							const SizedBox(height: 16),
							Text(
								_errorMessage!,
								textAlign: TextAlign.center,
								style: const TextStyle(color: Colors.white70, fontSize: 16),
							),
							const SizedBox(height: 24),
							ElevatedButton.icon(
								onPressed: _loadData,
								icon: const Icon(Icons.refresh_rounded),
								label: const Text('Réessayer'),
								style: ElevatedButton.styleFrom(
									backgroundColor: AppTheme.primary,
									foregroundColor: Colors.white,
									padding: const EdgeInsets.symmetric(
											horizontal: 24, vertical: 12),
									shape: RoundedRectangleBorder(
											borderRadius: BorderRadius.circular(12)),
								),
							),
						],
					),
				),
			);
		}

		if (_filteredRecords.isEmpty) {
			return RefreshIndicator(
				onRefresh: _loadData,
				color: AppTheme.secondary,
				backgroundColor: AppTheme.surface,
				child: ListView(
					physics: const AlwaysScrollableScrollPhysics(),
					children: [
						SizedBox(height: MediaQuery.of(context).size.height * 0.18),
						Center(
							child: Column(
								mainAxisAlignment: MainAxisAlignment.center,
								children: [
									Container(
										padding: const EdgeInsets.all(28),
										decoration: BoxDecoration(
											color: AppTheme.surface,
											shape: BoxShape.circle,
											border:
													Border.all(color: Colors.white.withValues(alpha: 0.5)),
										),
										child: Icon(
											_searchQuery.isEmpty
													? Icons.local_parking_rounded
													: Icons.search_off_rounded,
											size: 56,
											color: Colors.white.withValues(alpha: 0.5),
										),
									),
									const SizedBox(height: 24),
									Text(
										_searchQuery.isEmpty
												? 'Aucune liste disponible'
												: 'Aucune plaque correspondante',
										style: const TextStyle(
											color: Colors.white,
											fontSize: 17,
											fontWeight: FontWeight.bold,
											fontFamily: 'Inter',
										),
									),
									const SizedBox(height: 8),
									Text(
										_searchQuery.isEmpty
												? 'Aucun stationnement actif.\nGlissez vers le bas pour actualiser.'
												: 'Aucun stationnement ne correspond à "$_searchQuery".',
										textAlign: TextAlign.center,
										style: TextStyle(
											color: Colors.white.withValues(alpha: 0.5),
											fontSize: 13,
											fontFamily: 'Inter',
											height: 1.5,
										),
									),
									const SizedBox(height: 28),
									if (_searchQuery.isEmpty)
										ElevatedButton.icon(
											onPressed: _loadData,
											icon: const Icon(Icons.refresh_rounded, size: 18),
											label: const Text('Actualiser'),
											style: ElevatedButton.styleFrom(
												backgroundColor: AppTheme.secondary,
												foregroundColor: Colors.white,
												padding: const EdgeInsets.symmetric(
														horizontal: 24, vertical: 12),
												shape: RoundedRectangleBorder(
														borderRadius: BorderRadius.circular(12)),
											),
										),
								],
							),
						),
					],
				),
			);
		}

		return RefreshIndicator(
			onRefresh: _loadData,
			color: AppTheme.secondary,
			backgroundColor: AppTheme.surface,
			child: ListView.builder(
				physics: const AlwaysScrollableScrollPhysics(),
				padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
				itemCount: _filteredRecords.length,
				itemBuilder: (context, index) {
					final rec = _filteredRecords[index];
					final bool isEnCours = rec.status == 'en_cours';

					final Map<String, dynamic> data = {
						'plaque': rec.licensePlate,
						'zone': rec.zone.isNotEmpty ? rec.zone : 'Parking',
						'place': rec.notes ?? 'Non spécifiée',
						'heureEntree': '${rec.entryTime.hour.toString().padLeft(2, '0')}:${rec.entryTime.minute.toString().padLeft(2, '0')}',
						'duree': _formatDuration(rec.entryTime),
						'montant': '${_calculateEstimatedCost(rec.entryTime)} FCFA',
						'statut': isEnCours ? 'actif' : 'termine',
						'date': _formatDate(rec.entryTime),
					};

					return GestureDetector(
						onTap: () {
							context.push(AppRoutes.agentParkingDetail, extra: data).then((_) {
								_loadData();
							});
						},
						child: Container(
							margin: const EdgeInsets.only(bottom: 12),
							padding: const EdgeInsets.all(16),
							decoration: BoxDecoration(
								color: AppTheme.surface,
								borderRadius: BorderRadius.circular(20),
								border: Border.all(
									color: isEnCours
											? Colors.greenAccent.withValues(alpha: 0.5)
											: Colors.white.withValues(alpha: 0.5),
								),
								boxShadow: [
									BoxShadow(
										color: Colors.black.withValues(alpha: 0.5),
										blurRadius: 8,
										offset: const Offset(0, 3),
									),
								],
							),
							child: Row(
								children: [
									Container(
										width: 48,
										height: 48,
										decoration: BoxDecoration(
											color: isEnCours
													? Colors.greenAccent.withValues(alpha: 0.5)
													: Colors.white.withValues(alpha: 0.5),
											borderRadius: BorderRadius.circular(14),
										),
										child: Icon(
											Icons.directions_car_rounded,
											color: isEnCours ? Colors.greenAccent : Colors.white60,
											size: 24,
										),
									),
									const SizedBox(width: 14),
									Expanded(
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Text(
													rec.licensePlate,
													style: const TextStyle(
														color: Colors.white,
														fontSize: 16,
														fontWeight: FontWeight.bold,
														fontFamily: 'Inter',
														letterSpacing: 1.2,
													),
												),
												const SizedBox(height: 4),
												Text(
													rec.zone.isNotEmpty ? rec.zone : 'Parking',
													style: const TextStyle(
														color: AppTheme.textSecondary,
														fontSize: 13,
														fontFamily: 'Inter',
													),
												),
												const SizedBox(height: 2),
												Text(
													_formatDate(rec.entryTime),
													style: TextStyle(
														color: AppTheme.textSecondary.withValues(alpha: 0.5),
														fontSize: 11,
														fontFamily: 'Inter',
													),
												),
											],
										),
									),
									Column(
										crossAxisAlignment: CrossAxisAlignment.end,
										children: [
											Container(
												padding: const EdgeInsets.symmetric(
														horizontal: 10, vertical: 4),
												decoration: BoxDecoration(
													color: isEnCours
															? Colors.greenAccent.withValues(alpha: 0.5)
															: Colors.white.withValues(alpha: 0.5),
													borderRadius: BorderRadius.circular(10),
												),
												child: Text(
													isEnCours ? 'Actif' : 'Terminé',
													style: TextStyle(
														color: isEnCours
																? Colors.greenAccent
																: Colors.white60,
														fontSize: 11,
														fontWeight: FontWeight.bold,
														fontFamily: 'Inter',
													),
												),
											),
											const SizedBox(height: 6),
											Text(
												_formatDuration(rec.entryTime),
												style: const TextStyle(
													color: Colors.white,
													fontSize: 13,
													fontWeight: FontWeight.bold,
													fontFamily: 'Inter',
												),
											),
											const SizedBox(height: 2),
											Text(
												'~${_calculateEstimatedCost(rec.entryTime)} FCFA',
												style: const TextStyle(
													color: AppTheme.secondary,
													fontSize: 12,
													fontWeight: FontWeight.bold,
													fontFamily: 'Inter',
												),
											),
										],
									),
								],
							),
						),
					);
				},
			),
		);
	}
}
