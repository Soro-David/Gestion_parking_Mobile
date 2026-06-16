import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import 'package:parking_mobile/core/routes/route_names.dart';
import 'package:go_router/go_router.dart';

class AgentDashboardScreen extends StatelessWidget {
	const AgentDashboardScreen({super.key});

	// Données mockées des stationnements actifs
	static final List<Map<String, String>> _ticketsActifs = [
		{
			'parking': 'Parking Akwa Centre',
			'place': 'B-12',
			'plaque': 'LT-1234-AB',
			'duree': '02h 15min',
		},
		{
			'parking': 'Parking Bonanjo',
			'place': 'A-05',
			'plaque': 'CE-5678-CD',
			'duree': '01h 30min',
		},
		{
			'parking': 'Parking Bonapriso',
			'place': 'C-08',
			'plaque': 'LT-9012-EF',
			'duree': '03h 45min',
		},
	];

	@override
	Widget build(BuildContext context) {
		return SingleChildScrollView(
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					// ── Header avec avatar + recherche ──
					Container(
						padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
						decoration: const BoxDecoration(
							color: AppTheme.surface,
							borderRadius: BorderRadius.only(
								bottomLeft: Radius.circular(32),
								bottomRight: Radius.circular(32),
							),
						),
						child: Column(
							children: [
								Row(
									mainAxisAlignment: MainAxisAlignment.spaceBetween,
									children: [
										Row(
											children: [
												GestureDetector(
													onTap: () {
														context.push(AppRoutes.agentProfile);
													},
													child: Container(
														width: 48,
														height: 48,
														decoration: BoxDecoration(
															gradient: AppTheme.primaryGradient,
															shape: BoxShape.circle,
															border: Border.all(color: Colors.white24, width: 1.5),
														),
														child: const Center(
															child: Icon(Icons.person_rounded, color: Colors.white, size: 28),
														),
													),
												),
												const SizedBox(width: 14),
												const Column(
													crossAxisAlignment: CrossAxisAlignment.start,
													children: [
														Text('Bonjour 👋', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
														Text('Dognenin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
													],
												),
											],
										),
										IconButton(
											icon: const Badge(
												label: Text('1'),
												child: Icon(Icons.notifications_none_rounded, color: Colors.white),
											),
											onPressed: () {},
										),
									],
								),
								const SizedBox(height: 24),
								TextField(
									decoration: InputDecoration(
										filled: true,
										fillColor: AppTheme.background,
										prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary),
										hintText: 'Rechercher un parking, une zone...',
										hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
										border: OutlineInputBorder(
											borderRadius: BorderRadius.circular(16),
											borderSide: BorderSide.none,
										),
									),
								),
							],
						),
					),
					const SizedBox(height: 28),

					// ── Titre "Ticket Actif" + bouton "+" ──
					Padding(
						padding: const EdgeInsets.symmetric(horizontal: 24),
						child: Row(
							mainAxisAlignment: MainAxisAlignment.spaceBetween,
							children: [
								Row(
									children: [
										const Text(
											'Ticket Actif',
											style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
										),
										const SizedBox(width: 8),
										Container(
											padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
											decoration: BoxDecoration(
												color: Colors.greenAccent.withValues(alpha: 0.5),
												borderRadius: BorderRadius.circular(10),
											),
											child: Text(
												'${_ticketsActifs.length}',
												style: const TextStyle(
													color: Colors.greenAccent,
													fontSize: 13,
													fontWeight: FontWeight.bold,
												),
											),
										),
									],
								),
								GestureDetector(
									onTap: () {
										context.push(AppRoutes.agentParking);
									},
									child: Container(
										width: 36,
										height: 36,
										decoration: BoxDecoration(
											color: AppTheme.secondary.withValues(alpha: 0.5),
											borderRadius: BorderRadius.circular(10),
										),
										child: const Icon(
											Icons.add_rounded,
											color: AppTheme.secondary,
											size: 22,
										),
									),
								),
							],
						),
					),
					const SizedBox(height: 12),

					// ── Liste horizontale scrollable des tickets actifs ──
					SizedBox(
						height: 150,
						child: ListView.builder(
							scrollDirection: Axis.horizontal,
							padding: const EdgeInsets.symmetric(horizontal: 20),
							itemCount: _ticketsActifs.length,
							itemBuilder: (context, index) {
								final ticket = _ticketsActifs[index];
								return _buildTicketActifCard(ticket, index);
							},
						),
					),

					const SizedBox(height: 28),
					const Padding(
						padding: EdgeInsets.symmetric(horizontal: 20),
						child: Text('Services & Outils', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
					),
					const SizedBox(height: 15),
					Padding(
						padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
						child: GridView.count(
							padding: EdgeInsets.zero,
							shrinkWrap: true,
							physics: const NeverScrollableScrollPhysics(),
							crossAxisCount: 2,
							childAspectRatio: 1.5,
							crossAxisSpacing: 12,
							mainAxisSpacing: 12,
							children: [
								_buildServiceCard(icon: Icons.local_parking_rounded, title: 'Places Libres', color: Colors.indigo[400]!, infoText: '12 places libres'),
								_buildServiceCard(icon: Icons.account_balance_wallet_rounded, title: 'Portefeuille', color: Colors.amber[600]!, infoText: '5 400 FCFA'),
								_buildServiceCard(icon: Icons.receipt_long_rounded, title: 'Mes Factures', color: Colors.teal[400]!, infoText: '4 payees'),
								_buildServiceCard(icon: Icons.map_rounded, title: 'Zones Tarifs', color: Colors.blue[400]!, infoText: '3 zones proches'),
							],
						),
					),
					const SizedBox(height: 90),
				],
			),
		);
	}

	Widget _buildTicketActifCard(Map<String, String> ticket, int index) {
		// Couleurs différentes pour chaque card
		final List<List<Color>> gradients = [
			[const Color(0xFF143F85), const Color(0xFF0D47A1)],
			[const Color(0xFF1B3D74), const Color(0xFF0D47A1)],
			[const Color(0xFF2E1E5B), const Color(0xFF0D47A1)],
		];
		final gradient = gradients[index % gradients.length];

		return Container(
			width: 260,
			margin: const EdgeInsets.only(right: 14),
			padding: const EdgeInsets.all(18),
			decoration: BoxDecoration(
				gradient: LinearGradient(
					colors: gradient,
					begin: Alignment.topLeft,
					end: Alignment.bottomRight,
				),
				borderRadius: BorderRadius.circular(22),
				boxShadow: [
					BoxShadow(
						color: gradient[0].withValues(alpha: 0.5),
						blurRadius: 12,
						offset: const Offset(0, 6),
					),
				],
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				children: [
					Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: [
							Expanded(
								child: Text(
									ticket['parking']!,
									style: const TextStyle(
										color: Colors.white,
										fontSize: 15,
										fontWeight: FontWeight.bold,
										fontFamily: 'Inter',
									),
									maxLines: 1,
									overflow: TextOverflow.ellipsis,
								),
							),
							Container(
								padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
								decoration: BoxDecoration(
									color: Colors.greenAccent.withValues(alpha: 0.5),
									borderRadius: BorderRadius.circular(8),
								),
								child: Row(
									mainAxisSize: MainAxisSize.min,
									children: [
										Container(
											width: 6,
											height: 6,
											decoration: const BoxDecoration(
												color: Colors.greenAccent,
												shape: BoxShape.circle,
											),
										),
										const SizedBox(width: 4),
										const Text(
											'Actif',
											style: TextStyle(
												color: Colors.greenAccent,
												fontSize: 11,
												fontWeight: FontWeight.bold,
											),
										),
									],
								),
							),
						],
					),
					Row(
						children: [
							const Icon(Icons.event_seat_rounded, color: Colors.white54, size: 16),
							const SizedBox(width: 6),
							Text(
								'Place ${ticket['place']}',
								style: const TextStyle(color: Colors.white70, fontSize: 13),
							),
							const SizedBox(width: 12),
							const Icon(Icons.directions_car_rounded, color: Colors.white54, size: 16),
							const SizedBox(width: 6),
							Text(
								ticket['plaque']!,
								style: const TextStyle(
									color: Colors.white70,
									fontSize: 13,
									letterSpacing: 0.8,
								),
							),
						],
					),
					Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: [
							Row(
								children: [
									const Icon(Icons.timer_rounded, color: Colors.white70, size: 18),
									const SizedBox(width: 6),
									Text(
										ticket['duree']!,
										style: const TextStyle(
											color: Colors.white,
											fontSize: 18,
											fontWeight: FontWeight.bold,
											fontFamily: 'Inter',
										),
									),
								],
							),
							const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16),
						],
					),
				],
			),
		);
	}

	Widget _buildServiceCard({
		required IconData icon,
		required String title,
		required Color color,
		required String infoText,
	}) {
		return Container(
			padding: const EdgeInsets.all(16),
			decoration: BoxDecoration(
				color: AppTheme.surface,
				borderRadius: BorderRadius.circular(20),
				border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				children: [
					Container(
						padding: const EdgeInsets.all(8),
						decoration: BoxDecoration(
							color: color.withValues(alpha: 0.5),
							borderRadius: BorderRadius.circular(12),
						),
						child: Icon(icon, color: color, size: 22),
					),
					Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Text(
								title,
								style: const TextStyle(
									fontSize: 14,
									fontWeight: FontWeight.bold,
									color: Colors.white,
								),
							),
							const SizedBox(height: 2),
							Text(
								infoText,
								style: const TextStyle(
									fontSize: 11,
									color: AppTheme.textSecondary,
								),
							),
						],
					),
				],
			),
		);
	}
}
