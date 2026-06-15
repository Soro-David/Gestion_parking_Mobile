import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../network/routes/route_names.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../../shared/models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscureText = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _loginSuccess = false;
  
  // Animation controllers for orbs and slide transitions
  late AnimationController _orbController;
  
  // Focus nodes to trigger border glow animations
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    // Rebuild on focus change to update input glows
    _emailFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _orbController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text;
        
        final userModel = await AuthProvider.repository.login(email, password);

        if (!mounted) return;

        if (userModel.role == UserRole.agent) {
          context.go(AppRoutes.agentHome);
        } else if (userModel.role == UserRole.caissier) {
          context.go(AppRoutes.caissierHome);
        } else {
          throw Exception('Rôle non reconnu.');
        }

        setState(() {
          _isLoading = false;
          _loginSuccess = true;
        });

        // Beautiful success overlay before switching page
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (!mounted) return;
          
        });
      } catch (e) {
        if (!mounted) return;
        
        setState(() {
          _isLoading = false;
          _loginSuccess = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.surface,
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
              style: const TextStyle(color: Colors.white),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Premium Dark Background Gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppTheme.darkGradient,
            ),
          ),

          // 2. Animated Custom Paint for Background Glowing Orbs
          AnimatedBuilder(
            animation: _orbController,
            builder: (context, child) {
              return CustomPaint(
                size: size,
                painter: BackgroundOrbPainter(
                  animationValue: _orbController.value,
                  primaryColor: AppTheme.primary,
                  secondaryColor: AppTheme.secondary,
                  accentColor: AppTheme.accent,
                ),
              );
            },
          ),

          // 3. Scrollable Login Content (Prevents overflow with keyboard)
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Brand Identity / Logo
                    _buildLogoHeader(),
                    
                    const SizedBox(height: 30),

                    // Glassmorphic Login Form Container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28.0),
                      decoration: BoxDecoration(
                        color: AppTheme.surface.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 25,
                            spreadRadius: 5,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Connexion',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Accédez à votre espace de stationnement',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Email input field
                            _buildInputLabel('ADRESSE EMAIL'),
                            const SizedBox(height: 8),
                            _buildEmailField(),

                            const SizedBox(height: 20),

                            // Password input field
                            _buildInputLabel('MOT DE PASSE'),
                            const SizedBox(height: 8),
                            _buildPasswordField(),

                            const SizedBox(height: 16),

                            // Remember Me & Forgot Password Row
                            _buildOptionsRow(),

                            const SizedBox(height: 28),

                            // Submit Button
                            _buildLoginButton(size),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    // Register link for rich experience
                    _buildRegisterFooter(),
                  ],
                ),
              ),
            ),
          ),

          // 4. Loading / Success HUD Overlay
          if (_isLoading || _loginSuccess) _buildStatusOverlay(size),
        ],
      ),
    );
  }

  Widget _buildLogoHeader() {
    return Column(
      children: [
        // Pulsing circular logo
        Container(
          width: 75,
          height: 75,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.5),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: const Center(
            child: Text(
              'P',
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontFamily: 'Roboto',
                letterSpacing: -1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Plateau',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              ' Parking',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.blue[400],
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'GESTION DE PARKING INTELLIGENTE',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.5),
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildInputLabel(String labelText) {
    return Text(
      labelText,
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.bold,
        color: Colors.white.withValues(alpha: 0.5),
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildEmailField() {
    final isFocused = _emailFocus.hasFocus;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFocused ? AppTheme.secondary : Colors.white.withValues(alpha: 0.5),
          width: isFocused ? 1.8 : 1.0,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: AppTheme.secondary.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              ]
            : [],
      ),
      child: TextFormField(
        controller: _emailController,
        focusNode: _emailFocus,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.mail_outline_rounded,
            color: isFocused ? AppTheme.secondary : Colors.white.withValues(alpha: 0.5),
            size: 22,
          ),
          suffixIcon: _emailController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded, color: Colors.white.withValues(alpha: 0.5), size: 18),
                  onPressed: () {
                    setState(() {
                      _emailController.clear();
                    });
                  },
                )
              : null,
          hintText: 'adresse@exemple.com',
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
        onChanged: (val) => setState(() {}),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Veuillez saisir votre email';
          }
          final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!emailRegExp.hasMatch(value.trim())) {
            return 'Veuillez entrer une adresse email valide';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    final isFocused = _passwordFocus.hasFocus;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFocused ? AppTheme.secondary : Colors.white.withValues(alpha: 0.5),
          width: isFocused ? 1.8 : 1.0,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: AppTheme.secondary.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              ]
            : [],
      ),
      child: TextFormField(
        controller: _passwordController,
        focusNode: _passwordFocus,
        obscureText: _obscureText,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.lock_outlined,
            color: isFocused ? AppTheme.secondary : Colors.white.withValues(alpha: 0.5),
            size: 22,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: isFocused ? AppTheme.secondary : Colors.white.withValues(alpha: 0.5),
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
          hintText: '••••••••',
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
        onChanged: (val) => setState(() {}),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Veuillez saisir votre mot de passe';
          }
          if (value.trim().length < 6) {
            return 'Le mot de passe doit contenir au moins 6 caractères';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildOptionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Se souvenir de moi
        GestureDetector(
          onTap: () {
            setState(() {
              _rememberMe = !_rememberMe;
            });
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: _rememberMe ? AppTheme.secondary : Colors.white.withValues(alpha: 0.5),
                  border: Border.all(
                    color: _rememberMe ? AppTheme.secondary : Colors.white.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: _rememberMe
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                'Se souvenir de moi',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
        // Mot de passe oublié ?
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppTheme.surface,
                content: Row(
                  children: const [
                    Icon(Icons.info_outline_rounded, color: AppTheme.accent),
                    SizedBox(width: 12),
                    Text(
                      'Option de récupération envoyée par email.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: AppTheme.secondary,
          ),
          child: const Text(
            'Mot de passe oublié ?',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(Size size) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.5),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Se connecter',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 10),
            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Vous n'avez pas de compte ? ",
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
        ),
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppTheme.surface,
                content: const Text(
                  'La création de compte est gérée par l\'administrateur.',
                  style: TextStyle(color: Colors.white),
                ),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
          child: const Text(
            "S'inscrire",
            style: TextStyle(
              color: AppTheme.secondary,
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusOverlay(Size size) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withValues(alpha: 0.5),
      child: BackdropFilter(
        filter: ColorFilter.mode(Colors.black.withValues(alpha: 0.5), BlendMode.dstATop),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _isLoading
                ? _buildLoader()
                : _buildSuccessOverlay(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return Container(
      key: const ValueKey('loader'),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 45,
            height: 45,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondary),
              strokeWidth: 3.5,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Authentification en cours...',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    return Container(
      key: const ValueKey('success'),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.green[400]!.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.green[400]!.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.green[400]!.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.check_circle_rounded,
                color: Colors.green[400],
                size: 55,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Connexion Réussie !',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ravi de vous revoir sur ParkSmart.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter to draw elegant slow-moving background glow orbs for high-end look
class BackgroundOrbPainter extends CustomPainter {
  final double animationValue;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;

  BackgroundOrbPainter({
    required this.animationValue,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Orb 1: Pulsing glow at the top right
    final double orb1Angle = animationValue * 2 * math.pi;
    final double orb1X = w * 0.8 + 30 * math.cos(orb1Angle);
    final double orb1Y = h * 0.15 + 40 * math.sin(orb1Angle);
    final double orb1Radius = w * 0.45 + 15 * math.sin(orb1Angle * 2);

    final Paint orb1Paint = Paint()
      ..color = primaryColor.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);
    canvas.drawCircle(Offset(orb1X, orb1Y), orb1Radius, orb1Paint);

    // Orb 2: Pulsing glow at the bottom left
    final double orb2Angle = (animationValue + 0.5) * 2 * math.pi;
    final double orb2X = w * 0.15 + 40 * math.cos(orb2Angle);
    final double orb2Y = h * 0.8 + 30 * math.sin(orb2Angle);
    final double orb2Radius = w * 0.5 + 20 * math.cos(orb2Angle * 2);

    final Paint orb2Paint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
    canvas.drawCircle(Offset(orb2X, orb2Y), orb2Radius, orb2Paint);

    // Orb 3: Golden/accent highlight in the center
    final double orb3Angle = -animationValue * 2 * math.pi;
    final double orb3X = w * 0.5 + 60 * math.cos(orb3Angle);
    final double orb3Y = h * 0.45 + 50 * math.sin(orb3Angle);
    final double orb3Radius = w * 0.25;

    final Paint orb3Paint = Paint()
      ..color = accentColor.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 45);
    canvas.drawCircle(Offset(orb3X, orb3Y), orb3Radius, orb3Paint);
  }

  @override
  bool shouldRepaint(covariant BackgroundOrbPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
