import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import 'package:parking_mobile/core/routes/route_names.dart';
import 'package:go_router/go_router.dart';
import 'package:parking_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:parking_mobile/features/agent/presentation/providers/agent_stat_provider.dart';
import 'package:parking_mobile/shared/domain/entities/user.dart';
import 'package:parking_mobile/shared/domain/entities/parking_entry.dart';
import 'package:parking_mobile/features/agent/presentation/providers/agent_stationnement_provider.dart';

class AgentDashboardScreen extends StatefulWidget {
	const AgentDashboardScreen({super.key});

	@override
	State<AgentDashboardScreen> createState() => _AgentDashboardScreenState();
}

class _AgentDashboardScreenState extends State<AgentDashboardScreen> {
	String _userName = 'Dognenin';
	String? _avatarUrl;
	String _totalEncaisser = '... FCFA';
	String _stationnements = '...';
	String _encaisseNonVerse = '... FCFA';
	String _dette = '... FCFA';
	List<ParkingEntry> _activeParkings = [];
	bool _isLoadingParkings = true;

	@override
	void initState() {
		super.initState();
		_loadProfile();
		_loadStats();
		_loadActiveParkings();
	}

	Future<void> _loadStats() async {
		try {
			final stats = await AgentStatProvider.repository.getStats();

			if (mounted) {
				setState(() {
					_totalEncaisser = '${stats.totalEncaisser.toStringAsFixed(0)} FCFA';
					_stationnements = '${stats.stationnements}';
					_encaisseNonVerse = '${stats.encaisseNonVerse.toStringAsFixed(0)} FCFA';
					_dette = '${stats.dette.toStringAsFixed(0)} FCFA';
				});
			}
		} catch (e) {
			debugPrint('Error loading stats: $e');
		}
	}

	Future<void> _loadProfile() async {
		try {
			final profileData = await AuthProvider.repository.getProfile();
			final user = profileData['user'] as Map<String, dynamic>?;
			if (user != null && mounted) {
				setState(() {
					final firstName = user['first_name'] ?? '';
					final lastName = user['name'] ?? '';
					_userName = '$firstName $lastName'.trim();
					if (_userName.isEmpty) {
						_userName = user['name'] ?? 'Agent';
					}
					_avatarUrl = User.sanitizeAvatarUrl(user['avatar_url'] as String?);
				});
			}
		} catch (e) {
			debugPrint('Error loading profile: $e');
		}
	}

	int _estimatedCost(DateTime entryTime) {
		final diff = DateTime.now().difference(entryTime);
		final hours = (diff.inMinutes / 60.0).ceil();
		final cost = hours * 500;
		return cost > 0 ? cost : 500;
	}

	Future<void> _loadActiveParkings() async {
		setState(() {
			_isLoadingParkings = true;
		});
		try {
			final parkings = await AgentStationnementProvider.repository.getStationnementsEnCours();
			if (mounted) {
				setState(() {
					_activeParkings = parkings;
					_isLoadingParkings = false;
				});
			}
		} catch (e) {
			debugPrint('Error loading active parkings: $e');
			if (mounted) {
				setState(() {
					_isLoadingParkings = false;
				});
			}
		}
	}

	Future<void> _handleRefresh() async {
		await Future.wait([
			_loadProfile(),
			_loadStats(),
			_loadActiveParkings(),
		]);
	}


	@override
	Widget build(BuildContext context) {
		return Column(
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
													onTap: () async {
														await context.push(AppRoutes.agentProfile);
														_loadProfile();
													},
													child: Container(
														width: 48,
														height: 48,
														decoration: BoxDecoration(
															gradient: AppTheme.primaryGradient,
															shape: BoxShape.circle,
															border: Border.all(color: Colors.white24, width: 1.5),
															image: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
																	? DecorationImage(
																			image: NetworkImage(_avatarUrl!),
																			fit: BoxFit.cover,
																		)
																	: null,
														),
														child: (_avatarUrl == null || _avatarUrl!.isEmpty)
																? const Center(
																		child: Icon(Icons.person_rounded, color: Colors.white, size: 28),
																	)
																: null,
													),
												),
												const SizedBox(width: 14),
												Column(
													crossAxisAlignment: CrossAxisAlignment.start,
													children: [
														const Text('Bonjour 👋', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
														Text(_userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
				Expanded(
					child: RefreshIndicator(
						onRefresh: _handleRefresh,
						color: AppTheme.primary,
						child: SingleChildScrollView(
							physics: const AlwaysScrollableScrollPhysics(),
							child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
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
												'${_activeParkings.length > 3 ? 3 : _activeParkings.length}',
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
					if (_isLoadingParkings)
						const SizedBox(
							height: 150,
							child: Center(child: CircularProgressIndicator()),
						)
					else if (_activeParkings.isEmpty)
						const SizedBox(
							height: 150,
							child: Center(
								child: Text('Aucun ticket actif', style: TextStyle(color: Colors.grey)),
							),
						)
					else
						SizedBox(
							height: 150,
							child: ListView.builder(
								scrollDirection: Axis.horizontal,
								padding: const EdgeInsets.symmetric(horizontal: 20),
								itemCount: _activeParkings.length > 3 ? 3 : _activeParkings.length,
								itemBuilder: (context, index) {
									final ticket = _activeParkings[index];
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
							childAspectRatio: 1.45,
							crossAxisSpacing: 12,
							mainAxisSpacing: 12,
							children: [
								_buildServiceCard(
									icon: Icons.payments_rounded,
									title: 'Total Encaissé',
									color: const Color(0xFF00E5FF),
									infoText: _totalEncaisser,
								),
								_buildServiceCard(
									icon: Icons.receipt_long_rounded,
									title: 'Stationnements',
									color: const Color(0xFFE040FB),
									infoText: _stationnements,
								),
								_buildServiceCard(
									icon: Icons.pending_actions_rounded,
									title: 'Encaissé non versé',
									color: Colors.amber[600]!,
									infoText: _encaisseNonVerse,
								),
								_buildServiceCard(
									icon: Icons.history_edu_rounded,
									title: 'Dette',
									color: Colors.greenAccent,
									infoText: _dette,
								),
							],
						),
					),
					const SizedBox(height: 120),
							],
						),
					),
						),
					),
				],
		);
	}

	Widget _buildTicketActifCard(ParkingEntry ticket, int index) {
		// Couleurs différentes pour chaque card
		final List<List<Color>> gradients = [
			[const Color(0xFF143F85), const Color(0xFF0D47A1)],
			[const Color(0xFF1B3D74), const Color(0xFF0D47A1)],
			[const Color(0xFF2E1E5B), const Color(0xFF0D47A1)],
		];
		final gradient = gradients[index % gradients.length];

		return GestureDetector(
			onTap: () {
				context.push(AppRoutes.agentStationnementDetail, extra: ticket);
			},
			child: Container(
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
									ticket.ticketNumber,
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
								'Zone ${ticket.zone}',
								style: const TextStyle(color: Colors.white70, fontSize: 13),
							),
							const SizedBox(width: 12),
							const Icon(Icons.directions_car_rounded, color: Colors.white54, size: 16),
							const SizedBox(width: 6),
							Text(
								ticket.licensePlate,
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
										'${ticket.entryTime.hour.toString().padLeft(2, '0')}:${ticket.entryTime.minute.toString().padLeft(2, '0')}',
										style: const TextStyle(
											color: Colors.white,
											fontSize: 18,
											fontWeight: FontWeight.bold,
											fontFamily: 'Inter',
										),
									),
								],
							),
							Text(
								'~ ${_estimatedCost(ticket.entryTime)} FCFA',
								style: const TextStyle(
									color: Colors.greenAccent,
									fontSize: 14,
									fontWeight: FontWeight.bold,
									fontFamily: 'Inter',
								),
							),
						],
					),
				],
			),
		));
	}

	Widget _buildServiceCard({
		required IconData icon,
		required String title,
		required Color color,
		required String infoText,
	}) {
		return Container(
			padding: const EdgeInsets.all(18),
			decoration: BoxDecoration(
				color: AppTheme.surface,
				borderRadius: BorderRadius.circular(20),
				border: Border.all(color: Colors.white24, width: 1),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: [
							Expanded(
								child: Text(
									title,
									style: const TextStyle(
										color: AppTheme.textSecondary,
										fontSize: 12,
										fontWeight: FontWeight.bold,
										fontFamily: 'Inter',
									),
									maxLines: 1,
									overflow: TextOverflow.ellipsis,
								),
							),
							const SizedBox(width: 8),
							Icon(icon, color: color, size: 20),
						],
					),
					const SizedBox(height: 12),
					FittedBox(
						fit: BoxFit.scaleDown,
						child: Text(
							infoText,
							style: const TextStyle(
								color: Colors.white,
								fontSize: 16,
								fontWeight: FontWeight.bold,
								fontFamily: 'Inter',
							),
						),
					),
				],
			),
		);
	}
}
