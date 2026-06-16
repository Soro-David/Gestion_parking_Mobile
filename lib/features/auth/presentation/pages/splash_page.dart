import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:parking_mobile/core/routes/route_names.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Rotation animation for the car
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    // 2. Fade in for branding and logos
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();

    // 3. Pulsing effect for the center 'P' logo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 4. Navigate to Onboarding after 4.5 seconds
    Future.delayed(const Duration(milliseconds: 4500), () {
      if (mounted) {
        context.go(AppRoutes.onboarding);
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.darkGradient,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Animated vehicle rotating in a circle
              SizedBox(
                width: size.width * 0.7,
                height: size.width * 0.7,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer pulsing radial glow
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: size.width * 0.52,
                        height: size.width * 0.52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.5),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Custom painter to draw the glowing trail path
                    AnimatedBuilder(
                      animation: _rotationController,
                      builder: (context, child) {
                        return CustomPaint(
                          size: Size(size.width * 0.6, size.width * 0.6),
                          painter: CircularTrackPainter(
                            rotationValue: _rotationController.value,
                            themeColor: AppTheme.secondary,
                          ),
                        );
                      },
                    ),

                    // Central glowing "P" Parking Logo
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
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
                    ),

                    // Rotating Vehicle
                    AnimatedBuilder(
                      animation: _rotationController,
                      builder: (context, child) {
                        final angle = _rotationController.value * 2 * math.pi;
                        final radius = size.width * 0.3; // Half of track size
                        
                        // Calculate x, y coordinates along the circle circumference
                        final x = radius * math.cos(angle - math.pi / 2);
                        final y = radius * math.sin(angle - math.pi / 2);

                        return Transform.translate(
                          offset: Offset(x, y),
                          // Rotate the vehicle itself to face the direction of travel (tangent to circle)
                          child: Transform.rotate(
                            angle: angle,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primary.withValues(alpha: 0.5),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(
                                  color: AppTheme.secondary,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.directions_car_filled_rounded,
                                color: AppTheme.primary,
                                size: 24,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              // Title and Subtitle with elegant fade in
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Plateau',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          ' Parking',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.blue[400],
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'GESTION DE PARKING INTELLIGENTE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.5),
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // Bottom Loading indicator
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                        strokeWidth: 3,
                        backgroundColor: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chargement de l\'application...',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.5),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Painter to draw the beautiful dash circular track and the glowing trailing path of the car
class CircularTrackPainter extends CustomPainter {
  final double rotationValue;
  final Color themeColor;

  CircularTrackPainter({
    required this.rotationValue,
    required this.themeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Draw static background circular dotted path
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    canvas.drawCircle(center, radius, trackPaint);

    // 2. Draw glowing trailing arc behind the car (the car rotates from -pi/2 + angle)
    final double carAngle = (rotationValue * 2 * math.pi) - math.pi / 2;
    const double trailLength = math.pi * 0.7; // length of the trail (about 120 degrees)
    final double startAngle = carAngle - trailLength;

    // Use a multi-stop shader/gradient for the trail to fade out smoothly
    final rect = Rect.fromCircle(center: center, radius: radius);
    final trailGradient = SweepGradient(
      colors: [
        Colors.transparent,
        themeColor.withValues(alpha: 0.5),
        themeColor.withValues(alpha: 0.5),
        themeColor,
      ],
      stops: const [0.0, 0.4, 0.75, 1.0],
      transform: GradientRotation(startAngle),
    );

    final trailPaint = Paint()
      ..shader = trailGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    // Draw the trailing arc
    canvas.drawArc(
      rect,
      startAngle,
      trailLength,
      false,
      trailPaint,
    );

    // 3. Draw mini energy particles/spots along the track for enhanced visuals
    final particlePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    
    // Draw small static markers at cardinal points
    for (int i = 0; i < 4; i++) {
      final markerAngle = (i * math.pi / 2);
      final markerX = center.dx + radius * math.cos(markerAngle);
      final markerY = center.dy + radius * math.sin(markerAngle);
      canvas.drawCircle(Offset(markerX, markerY), 2.5, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CircularTrackPainter oldDelegate) {
    return oldDelegate.rotationValue != rotationValue;
  }
}
