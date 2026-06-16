import 'package:flutter/material.dart';
import 'package:parking_mobile/core/theme/app_theme.dart';
import 'package:parking_mobile/core/routes/route_names.dart';
import 'package:go_router/go_router.dart';

class AgentParkingScreen extends StatefulWidget {
	const AgentParkingScreen({super.key});

	@override
	State<AgentParkingScreen> createState() => _AgentParkingScreenState();
}

class _AgentParkingScreenState extends State<AgentParkingScreen> {
	final List<Map<String, dynamic>> _stationnements = [
		{
			'plaque': 'LT-1234-AB',
			'zone': 'Parking Akwa Centre',
			'place': 'B-12',
			'heureEntree': '08:30',
			'heureSortie': null,
			'duree': '02h 15min',
			'montant': '1 500 FCFA',
			'statut': 'actif',
			'date': '29 Mai 2026',
		},
	];

	String _searchQuery = '';

	@override
	Widget build(BuildContext context) {
		final filteredStationnements = _stationnements.where((s) {
			return s['plaque'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
		}).toList();

		return Scaffold(
			backgroundColor: AppTheme.background,
			appBar: AppBar(
				toolbarHeight: 80,
				title: const Text(
					'Mon Parking',
					style: TextStyle(
						fontFamily: 'Inter',
						fontSize: 24,
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
					Padding(
						padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
						child: TextField(
							onChanged: (value) {
								setState(() {
									_searchQuery = value;
								});
							},
							style: const TextStyle(color: Colors.white),
							decoration: InputDecoration(
								filled: true,
								fillColor: AppTheme.surface,
								prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary),
								hintText: 'Rechercher par immatriculation...',
								hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
								border: OutlineInputBorder(
									borderRadius: BorderRadius.circular(16),
									borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
								),
								enabledBorder: OutlineInputBorder(
									borderRadius: BorderRadius.circular(16),
									borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
								),
								focusedBorder: OutlineInputBorder(
									borderRadius: BorderRadius.circular(16),
									borderSide: const BorderSide(color: AppTheme.secondary, width: 1.5),
								),
							),
						),
					),
					Expanded(
						child: filteredStationnements.isEmpty
								? Center(
										child: Column(
											mainAxisAlignment: MainAxisAlignment.center,
											children: [
												Icon(Icons.local_parking_rounded, size: 64, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
												const SizedBox(height: 16),
												const Text(
													'Aucun véhicule trouvé',
													style: TextStyle(
														color: AppTheme.textSecondary,
														fontSize: 16,
														fontFamily: 'Inter',
													),
												),
											],
										),
									)
								: ListView.builder(
										padding: const EdgeInsets.fromLTRB(20, 10, 20, 108),
										itemCount: filteredStationnements.length,
										itemBuilder: (context, index) {
											return _buildStationnementItem(context, filteredStationnements[index]);
										},
									),
					),
				],
			),
		);
	}

	Widget _buildStationnementItem(BuildContext context, Map<String, dynamic> data) {
		return Padding(
			padding: const EdgeInsets.only(bottom: 12),
			child: GestureDetector(
				onTap: () {
					context.push(AppRoutes.agentParkingDetail, extra: data);
				},
				child: Container(
					padding: const EdgeInsets.all(16),
					decoration: BoxDecoration(
						color: AppTheme.surface,
						borderRadius: BorderRadius.circular(20),
						border: Border.all(
							color: Colors.greenAccent.withValues(alpha: 0.15),
						),
						boxShadow: [
							BoxShadow(
								color: Colors.black.withValues(alpha: 0.06),
								blurRadius: 8,
								offset: const Offset(0, 3),
							),
						],
					),
					child: Row(
						children: [
							Container(
								width: 50,
								height: 50,
								decoration: BoxDecoration(
									color: Colors.greenAccent.withValues(alpha: 0.12),
									borderRadius: BorderRadius.circular(14),
								),
								child: const Icon(
									Icons.directions_car_rounded,
									color: Colors.greenAccent,
									size: 26,
								),
							),
							const SizedBox(width: 14),
							Expanded(
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text(
											data['plaque'],
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
											'${data['zone']} • ${data['place']}',
											style: const TextStyle(
												color: AppTheme.textSecondary,
												fontSize: 13,
											),
										),
										const SizedBox(height: 2),
										Text(
											data['date'],
											style: TextStyle(
												color: AppTheme.textSecondary.withValues(alpha: 0.7),
												fontSize: 11,
											),
										),
									],
								),
							),
							Column(
								crossAxisAlignment: CrossAxisAlignment.end,
								children: [
									Container(
										padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
										decoration: BoxDecoration(
											color: Colors.greenAccent.withValues(alpha: 0.12),
											borderRadius: BorderRadius.circular(10),
										),
										child: const Text(
											'Actif',
											style: TextStyle(
												color: Colors.greenAccent,
												fontSize: 11,
												fontWeight: FontWeight.bold,
											),
										),
									),
									const SizedBox(height: 6),
									Text(
										data['duree'],
										style: const TextStyle(
											color: Colors.white,
											fontSize: 14,
											fontWeight: FontWeight.w600,
										),
									),
									const SizedBox(height: 2),
									Text(
										data['montant'],
										style: const TextStyle(
											color: AppTheme.secondary,
											fontSize: 12,
											fontWeight: FontWeight.w500,
										),
									),
								],
							),
						],
					),
				),
			),
		);
	}
}
