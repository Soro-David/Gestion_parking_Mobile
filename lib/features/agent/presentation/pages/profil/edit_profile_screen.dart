import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parking_mobile/core/theme/app_theme.dart';
import 'package:parking_mobile/features/auth/presentation/providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
	const EditProfileScreen({super.key});

	@override
	State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
	final _formKey = GlobalKey<FormState>();
	final _nomController = TextEditingController();
	final _prenomController = TextEditingController();
	final _emailController = TextEditingController();
	final _phoneController = TextEditingController();
	final _adresseController = TextEditingController();

	bool _isLoading = true;
	String? _errorMessage;
	String _headerName = '';
	String _headerRole = 'Agent Parking';

	@override
	void initState() {
		super.initState();
		_loadProfile();
	}

	Future<void> _loadProfile() async {
		try {
			final profileData = await AuthProvider.repository.getProfile();
			final user = profileData['user'] as Map<String, dynamic>?;
			if (user != null) {
				_nomController.text = user['name'] ?? '';
				_prenomController.text = user['first_name'] ?? '';
				_emailController.text = user['email'] ?? '';
				_phoneController.text = user['phone'] ?? '';
				_adresseController.text = '';

				_headerName = '${user['first_name'] ?? ''} ${user['name'] ?? ''}'.trim();
				if (_headerName.isEmpty) {
					_headerName = user['name'] ?? 'Agent';
				}
				final roleStr = user['role'] ?? 'attendant';
				_headerRole = roleStr == 'attendant' || roleStr == 'agent' ? 'Agent Parking' : 'Caissier de Service';
			}
			setState(() {
				_isLoading = false;
			});
		} catch (e) {
			setState(() {
				_errorMessage = e.toString().replaceAll('Exception: ', '');
				_isLoading = false;
			});
		}
	}

	@override
	void dispose() {
		_nomController.dispose();
		_prenomController.dispose();
		_emailController.dispose();
		_phoneController.dispose();
		_adresseController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: AppTheme.background,
			appBar: AppBar(
				toolbarHeight: 80,
				leading: IconButton(
					icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
					onPressed: () => context.pop(),
				),
				title: const Text(
					'Modifier le profil',
					style: TextStyle(
						fontFamily: 'Inter',
						fontSize: 22,
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
			body: _isLoading
					? const Center(
							child: CircularProgressIndicator(
								color: AppTheme.secondary,
							),
						)
					: _errorMessage != null
							? Center(
									child: Padding(
										padding: const EdgeInsets.all(24.0),
										child: Column(
											mainAxisAlignment: MainAxisAlignment.center,
											children: [
												const Icon(
													Icons.error_outline_rounded,
													color: Colors.redAccent,
													size: 48,
												),
												const SizedBox(height: 16),
												Text(
													_errorMessage!,
													textAlign: TextAlign.center,
													style: const TextStyle(
														color: Colors.white,
														fontSize: 16,
														fontFamily: 'Inter',
													),
												),
												const SizedBox(height: 24),
												ElevatedButton.icon(
													onPressed: () {
														setState(() {
															_isLoading = true;
															_errorMessage = null;
														});
														_loadProfile();
													},
													icon: const Icon(Icons.refresh_rounded),
													label: const Text('Réessayer'),
													style: ElevatedButton.styleFrom(
														backgroundColor: AppTheme.secondary,
														foregroundColor: Colors.white,
														shape: RoundedRectangleBorder(
															borderRadius: BorderRadius.circular(12),
														),
														padding: const EdgeInsets.symmetric(
															horizontal: 24,
															vertical: 12,
														),
													),
												),
											],
										),
									),
								)
							: SingleChildScrollView(
									child: Form(
										key: _formKey,
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.stretch,
											children: [
												Padding(
													padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
													child: Container(
														padding: const EdgeInsets.all(20),
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
																Stack(
																	alignment: Alignment.bottomRight,
																	children: [
																		Container(
																			width: 100,
																			height: 100,
																			decoration: BoxDecoration(
																				shape: BoxShape.circle,
																				gradient: const LinearGradient(
																					colors: [AppTheme.primary, AppTheme.secondary],
																					begin: Alignment.topLeft,
																					end: Alignment.bottomRight,
																				),
																				boxShadow: [
																					BoxShadow(
																						color: AppTheme.secondary.withValues(alpha: 0.35),
																						blurRadius: 20,
																						offset: const Offset(0, 8),
																					),
																				],
																			),
																			child: const Icon(
																				Icons.person_rounded,
																				color: Colors.white,
																				size: 50,
																			),
																		),
																		GestureDetector(
																			onTap: () {},
																			child: Container(
																				width: 34,
																				height: 34,
																				decoration: BoxDecoration(
																					color: AppTheme.secondary,
																					shape: BoxShape.circle,
																					border: Border.all(
																						color: AppTheme.surface,
																						width: 3,
																					),
																					boxShadow: [
																						BoxShadow(
																							color: AppTheme.secondary.withValues(alpha: 0.4),
																							blurRadius: 8,
																							offset: const Offset(0, 2),
																						),
																					],
																				),
																				child: const Icon(
																					Icons.camera_alt_rounded,
																					color: Colors.white,
																					size: 16,
																				),
																			),
																		),
																	],
																),
																const SizedBox(height: 10),
																Text(
																	_headerName,
																	style: const TextStyle(
																		color: Colors.white,
																		fontSize: 20,
																		fontWeight: FontWeight.bold,
																		fontFamily: 'Inter',
																	),
																),
																const SizedBox(height: 4),
																Text(
																	_headerRole,
																	style: const TextStyle(
																		color: AppTheme.textSecondary,
																		fontSize: 14,
																	),
																),
																const SizedBox(height: 24),
																Container(
																	height: 1,
																	color: Colors.white.withValues(alpha: 0.06),
																),
																const SizedBox(height: 24),
																_buildField(
																	label: 'Nom',
																	controller: _nomController,
																	icon: Icons.person_outline_rounded,
																	isRequired: true,
																),
																const SizedBox(height: 18),
																_buildField(
																	label: 'Prénom',
																	controller: _prenomController,
																	icon: Icons.person_outline_rounded,
																	isRequired: true,
																),
																const SizedBox(height: 18),
																_buildField(
																	label: 'Adresse email',
																	controller: _emailController,
																	icon: Icons.email_outlined,
																	keyboardType: TextInputType.emailAddress,
																	isRequired: true,
																),
																const SizedBox(height: 18),
																_buildField(
																	label: 'Numéro de téléphone',
																	controller: _phoneController,
																	icon: Icons.phone_outlined,
																	keyboardType: TextInputType.phone,
																),
																const SizedBox(height: 18),
																_buildField(
																	label: 'Adresse',
																	controller: _adresseController,
																	icon: Icons.location_on_outlined,
																),
															],
														),
													),
												),
												const SizedBox(height: 32),
												Padding(
													padding: const EdgeInsets.symmetric(horizontal: 20),
													child: GestureDetector(
														onTap: () {
															if (_formKey.currentState!.validate()) {
																ScaffoldMessenger.of(context).showSnackBar(
																	SnackBar(
																		content: const Row(
																			children: [
																				Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
																				SizedBox(width: 10),
																				Text('Profil mis à jour avec succès !'),
																			],
																		),
																		backgroundColor: Colors.green.shade600,
																		behavior: SnackBarBehavior.floating,
																		shape: RoundedRectangleBorder(
																			borderRadius: BorderRadius.circular(12),
																		),
																		margin: const EdgeInsets.all(16),
																	),
																);
																context.pop();
															}
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
																	Icon(Icons.save_rounded, color: Colors.white, size: 20),
																	SizedBox(width: 10),
																	Text(
																		'Enregistrer les modifications',
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
												),
												const SizedBox(height: 90),
											],
										),
									),
								),
		);
	}

	Widget _buildField({
		required String label,
		required TextEditingController controller,
		required IconData icon,
		TextInputType keyboardType = TextInputType.text,
		bool isRequired = false,
	}) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Row(
					children: [
						Text(
							label,
							style: const TextStyle(
								color: AppTheme.textSecondary,
								fontSize: 13,
								fontWeight: FontWeight.w600,
								fontFamily: 'Inter',
							),
						),
						if (isRequired) const Text(' *', style: TextStyle(color: Colors.redAccent)),
					],
				),
				const SizedBox(height: 8),
				TextFormField(
					controller: controller,
					keyboardType: keyboardType,
					style: const TextStyle(color: Colors.white),
					validator: isRequired
							? (v) => (v == null || v.isEmpty) ? 'Ce champ est requis' : null
							: null,
					decoration: InputDecoration(
						filled: true,
						fillColor: AppTheme.surface,
						prefixIcon: Icon(icon, color: AppTheme.textSecondary),
						border: OutlineInputBorder(
							borderRadius: BorderRadius.circular(12),
							borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
						),
					),
				),
			],
		);
	}
}
