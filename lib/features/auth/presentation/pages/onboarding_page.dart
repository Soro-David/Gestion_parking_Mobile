import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../network/routes/route_names.dart';
import 'package:go_router/go_router.dart';

  class OnboardingScreen extends StatefulWidget {
    const OnboardingScreen({super.key});

    @override
    State<OnboardingScreen> createState() => _OnboardingScreenState();
  }

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // Custom animations for slide elements
  double _scrollPercent = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.position.haveDimensions) {
        setState(() {
          _scrollPercent = _pageController.page ?? 0.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _nextPage() {
    if (_currentIndex < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.darkGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header bar with Logo and Passer Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand Logo
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              'P',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Plateau Parking',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    // Skip button
                    if (_currentIndex < 2)
                      TextButton(
                        onPressed: _navigateToLogin,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white.withValues(alpha: 0.5),
                        ),
                        child: Row(
                          children: const [
                            Text(
                              'Passer',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(Icons.chevron_right_rounded, size: 18),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Page View for Onboarding Slides
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  children: [
                    _buildOnboardingPage(
                      title: 'Trouver une Place',
                      description:
                          'Recherchez et géolocalisez instantanément les places de stationnement disponibles autour de vous en temps réel.',
                      painter: RadarPainter(scrollPercent: _scrollPercent, pageIndex: 0),
                      context: context,
                    ),
                    _buildOnboardingPage(
                      title: 'Accès Intelligent',
                      description:
                          'Scannez le QR Code de votre ticket ou utilisez l\'OCR de plaque pour ouvrir automatiquement la barrière d\'entrée.',
                      painter: GatePainter(scrollPercent: _scrollPercent, pageIndex: 1),
                      context: context,
                    ),
                    _buildOnboardingPage(
                      title: 'Paiement & Suivi',
                      description:
                          'Réglez vos frais de stationnement en un clic via Mobile Money et prolongez votre session à distance en temps réel.',
                      painter: PaymentPainter(scrollPercent: _scrollPercent, pageIndex: 2),
                      context: context,
                    ),
                  ],
                ),
              ),

              // Footer indicators and button
              Padding(
                padding: const EdgeInsets.all(28.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Slide Indicators (Morphing dots)
                    Row(
                      children: List.generate(3, (index) {
                        final isActive = _currentIndex == index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 8),
                          height: 8,
                          width: isActive ? 24 : 8,
                          decoration: BoxDecoration(
                            color: isActive ? AppTheme.secondary : Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: AppTheme.secondary.withValues(alpha: 0.5),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : [],
                          ),
                        );
                      }),
                    ),

                    // Next/Start Button
                    _currentIndex == 2
                        ? Container(
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(alpha: 0.5),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _navigateToLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(0, 255, 254, 254),
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    'Commencer',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, size: 20),
                                ],
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: _nextPage,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Circular loading/progress ring around button
                                SizedBox(
                                  width: 68,
                                  height: 68,
                                  child: CircularProgressIndicator(
                                    value: (_currentIndex + 1) / 3,
                                    backgroundColor: Colors.white.withValues(alpha: 0.5),
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.secondary),
                                    strokeWidth: 3.5,
                                  ),
                                ),
                                // Inner FAB style button
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage({
    required String title,
    required String description,
    required CustomPainter painter,
    required BuildContext context,
  }) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Graphic container
          Expanded(
            flex: 6,
            child: Center(
              child: SizedBox(
                width: size.width * 0.75,
                height: size.width * 0.75,
                child: CustomPaint(
                  painter: painter,
                ),
              ),
            ),
          ),
          
          // Text Details
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 15,
                        color: AppTheme.textSecondary,
                        height: 1.6,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// SCREEN 1: Radar Search Painter (Radar / Map PIN / Car)
// ----------------------------------------------------
class RadarPainter extends CustomPainter {
  final double scrollPercent;
  final int pageIndex;

  RadarPainter({required this.scrollPercent, required this.pageIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Calculate sub-animations based on current scroll position
    final pageOffset = (scrollPercent - pageIndex).abs();
    final animFactor = (1.0 - pageOffset).clamp(0.0, 1.0);

    // 1. Draw glowing radar pulse rings
    for (int i = 1; i <= 3; i++) {
      final ringRadius = maxRadius * (i / 3) * (0.8 + 0.2 * animFactor);
      final ringPaint = Paint()
        ..color = AppTheme.secondary.withValues(alpha: 0.5 * animFactor)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(center, ringRadius, ringPaint);
    }

    // 2. Draw radar target grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    canvas.drawLine(Offset(center.dx - maxRadius, center.dy), Offset(center.dx + maxRadius, center.dy), gridPaint);
    canvas.drawLine(Offset(center.dx, center.dy - maxRadius), Offset(center.dx, center.dy + maxRadius), gridPaint);

    // 3. Draw radar scanner hand (sweep line)
    final sweepAngle = animFactor * 2.3 * math.pi;
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          AppTheme.secondary.withValues(alpha: 0.5),
          AppTheme.secondary.withValues(alpha: 0.5),
          AppTheme.secondary,
        ],
        stops: const [0.0, 0.5, 0.8, 1.0],
        transform: GradientRotation(sweepAngle - 0.5),
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius))
      ..style = PaintingStyle.fill;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: maxRadius * 0.9),
      sweepAngle - 0.5,
      0.5,
      true,
      sweepPaint,
    );

    // 4. Draw static "P" map marker pin (with pulse glow)
    final pinCenter = Offset(center.dx + maxRadius * 0.45 * animFactor, center.dy - maxRadius * 0.35);
    
    final pinGlow = Paint()
      ..color = AppTheme.accent.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pinCenter, 22, pinGlow);

    final pinPaint = Paint()
      ..color = AppTheme.accent
      ..style = PaintingStyle.fill;
    
    // Draw tear-drop GPS pin
    final path = Path()
      ..moveTo(pinCenter.dx, pinCenter.dy + 12)
      ..cubicTo(pinCenter.dx - 10, pinCenter.dy + 2, pinCenter.dx - 10, pinCenter.dy - 10, pinCenter.dx, pinCenter.dy - 10)
      ..cubicTo(pinCenter.dx + 10, pinCenter.dy - 10, pinCenter.dx + 10, pinCenter.dy + 2, pinCenter.dx, pinCenter.dy + 12)
      ..close();
    canvas.drawPath(path, pinPaint);

    // Pin interior text 'P'
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'P',
        style: TextStyle(
          color: AppTheme.background,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(pinCenter.dx - textPainter.width / 2, pinCenter.dy - textPainter.height / 2 - 2));

    // 5. Draw the searching car approaching
    final carCenter = Offset(center.dx - maxRadius * 0.3 * animFactor, center.dy + maxRadius * 0.25 * animFactor);
    final carGlow = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(carCenter, 26, carGlow);

    final carBase = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(carCenter, 18, carBase);

    // Draw little vehicle outline in center of that circle
    final carIconPaint = Paint()
      ..color = AppTheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    
    // Quick vector car schematic
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(carCenter.dx, carCenter.dy + 2), width: 18, height: 10),
        const Radius.circular(3),
      ),
      carIconPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(carCenter.dx - 6, carCenter.dy - 3)
        ..lineTo(carCenter.dx - 3, carCenter.dy - 7)
        ..lineTo(carCenter.dx + 3, carCenter.dy - 7)
        ..lineTo(carCenter.dx + 6, carCenter.dy - 3)
        ..close(),
      carIconPaint,
    );
  }

  @override
  bool shouldRepaint(covariant RadarPainter oldDelegate) {
    return oldDelegate.scrollPercent != scrollPercent;
  }
}

// ----------------------------------------------------
// SCREEN 2: Gate & Barrier Painter (Barrier / SCAN Frame)
// ----------------------------------------------------
class GatePainter extends CustomPainter {
  final double scrollPercent;
  final int pageIndex;

  GatePainter({required this.scrollPercent, required this.pageIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final width = size.width;
    final height = size.height;

    // Calculate sub-animations based on current scroll position
    final pageOffset = (scrollPercent - pageIndex).abs();
    final animFactor = (1.0 - pageOffset).clamp(0.0, 1.0);

    // 1. Draw glowing scanner window grid (QR code scanning area)
    final scanRect = Rect.fromCenter(center: Offset(center.dx, center.dy - 20), width: width * 0.55, height: width * 0.55);
    
    final scannerBg = Paint()
      ..color = AppTheme.surface.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(20)), scannerBg);

    final scannerBorder = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(20)), scannerBorder);

    // 2. Draw active scanning laser line
    final double laserY = scanRect.top + (scanRect.height * (0.2 + 0.6 * math.sin(animFactor * math.pi)));
    final laserPaint = Paint()
      ..color = AppTheme.secondary
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;
    
    final laserGlow = Paint()
      ..color = AppTheme.secondary.withValues(alpha: 0.5)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(scanRect.left + 15, laserY), Offset(scanRect.right - 15, laserY), laserGlow);
    canvas.drawLine(Offset(scanRect.left + 15, laserY), Offset(scanRect.right - 15, laserY), laserPaint);

    // 3. Draw neon green corners/brackets for scanner
    final bracketPaint = Paint()
      ..color = AppTheme.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final double bracketLength = 20.0;
    
    // Top-Left corner
    canvas.drawPath(Path()..moveTo(scanRect.left, scanRect.top + bracketLength)..lineTo(scanRect.left, scanRect.top)..lineTo(scanRect.left + bracketLength, scanRect.top), bracketPaint);
    // Top-Right corner
    canvas.drawPath(Path()..moveTo(scanRect.right, scanRect.top + bracketLength)..lineTo(scanRect.right, scanRect.top)..lineTo(scanRect.right - bracketLength, scanRect.top), bracketPaint);
    // Bottom-Left corner
    canvas.drawPath(Path()..moveTo(scanRect.left, scanRect.bottom - bracketLength)..lineTo(scanRect.left, scanRect.bottom)..lineTo(scanRect.left + bracketLength, scanRect.bottom), bracketPaint);
    // Bottom-Right corner
    canvas.drawPath(Path()..moveTo(scanRect.right, scanRect.bottom - bracketLength)..lineTo(scanRect.right, scanRect.bottom)..lineTo(scanRect.right - bracketLength, scanRect.bottom), bracketPaint);

    // 4. Draw QR Code schematic inside the scanner
    final qrPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw QR outer finder patterns
    final fp1 = Rect.fromLTWH(scanRect.left + 25, scanRect.top + 25, 25, 25);
    final fp2 = Rect.fromLTWH(scanRect.right - 50, scanRect.top + 25, 25, 25);
    final fp3 = Rect.fromLTWH(scanRect.left + 25, scanRect.bottom - 50, 25, 25);
    
    canvas.drawRect(fp1, qrPaint);
    canvas.drawRect(fp2, qrPaint);
    canvas.drawRect(fp3, qrPaint);

    // Draw little core blocks inside finder patterns
    final qrCorePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(scanRect.left + 30, scanRect.top + 30, 15, 15), qrCorePaint);
    canvas.drawRect(Rect.fromLTWH(scanRect.right - 45, scanRect.top + 30, 15, 15), qrCorePaint);
    canvas.drawRect(Rect.fromLTWH(scanRect.left + 30, scanRect.bottom - 45, 15, 15), qrCorePaint);

    // Draw some random digital bits
    final bitPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.left + 65, scanRect.top + 35)
        ..lineTo(scanRect.left + 85, scanRect.top + 35)
        ..lineTo(scanRect.left + 85, scanRect.top + 55)
        ..moveTo(scanRect.right - 70, scanRect.bottom - 40)
        ..lineTo(scanRect.right - 70, scanRect.bottom - 25)
        ..lineTo(scanRect.right - 90, scanRect.bottom - 25),
      bitPaint,
    );

    // 5. Draw the raising barrier/gate on the side
    final gatePivot = Offset(center.dx - width * 0.32, center.dy + height * 0.22);
    final gateBasePaint = Paint()
      ..color = Colors.grey[700]!
      ..style = PaintingStyle.fill;
    
    // Draw gate post
    canvas.drawRect(Rect.fromCenter(center: gatePivot, width: 22, height: 44), gateBasePaint);

    // Draw the gate barrier arm rotating upwards based on scroll progress
    final double barrierAngle = -math.pi / 6 - (math.pi / 3 * animFactor); // goes up (from angle -30 to -90)
    final barrierPaint = Paint()
      ..color = AppTheme.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final barrierLength = width * 0.45;
    final barrierEnd = Offset(
      gatePivot.dx + barrierLength * math.cos(barrierAngle),
      gatePivot.dy + barrierLength * math.sin(barrierAngle),
    );
    canvas.drawLine(gatePivot, barrierEnd, barrierPaint);

    // Draw red/white warning lines on the barrier arm
    final warningPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.square;
    
    for (double i = 0.2; i <= 0.8; i += 0.2) {
      final wStart = Offset(
        gatePivot.dx + (barrierLength * i) * math.cos(barrierAngle),
        gatePivot.dy + (barrierLength * i) * math.sin(barrierAngle),
      );
      final wEnd = Offset(
        gatePivot.dx + (barrierLength * (i + 0.1)) * math.cos(barrierAngle),
        gatePivot.dy + (barrierLength * (i + 0.1)) * math.sin(barrierAngle),
      );
      canvas.drawLine(wStart, wEnd, warningPaint);
    }
  }

  @override
  bool shouldRepaint(covariant GatePainter oldDelegate) {
    return oldDelegate.scrollPercent != scrollPercent;
  }
}

// ----------------------------------------------------
// SCREEN 3: Payment & Timer Clock Painter
// ----------------------------------------------------
class PaymentPainter extends CustomPainter {
  final double scrollPercent;
  final int pageIndex;

  PaymentPainter({required this.scrollPercent, required this.pageIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final width = size.width;
    final height = size.height;

    // Calculate sub-animations based on current scroll position
    final pageOffset = (scrollPercent - pageIndex).abs();
    final animFactor = (1.0 - pageOffset).clamp(0.0, 1.0);

    // 1. Draw glowing digital wallet card
    final cardRect = Rect.fromCenter(center: Offset(center.dx - 15 * (1.0 - animFactor), center.dy - 25), width: width * 0.62, height: width * 0.4);
    
    final cardGlow = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawRRect(RRect.fromRectAndRadius(cardRect, const Radius.circular(16)), cardGlow);

    final cardPaint = Paint()
      ..shader = AppTheme.primaryGradient.createShader(cardRect)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(cardRect, const Radius.circular(16)), cardPaint);

    final cardBorder = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(RRect.fromRectAndRadius(cardRect, const Radius.circular(16)), cardBorder);

    // Draw card chip
    final chipRect = Rect.fromLTWH(cardRect.left + 22, cardRect.top + 22, 28, 20);
    final chipPaint = Paint()
      ..color = AppTheme.accent.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(chipRect, const Radius.circular(4)), chipPaint);

    // Draw generic card numbers and logo placeholder
    final textPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(cardRect.left + 22, cardRect.bottom - 44, width * 0.35, 6), textPaint);
    canvas.drawRect(Rect.fromLTWH(cardRect.left + 22, cardRect.bottom - 30, width * 0.2, 5), textPaint);

    // Master/Visa stylized circles
    canvas.drawCircle(Offset(cardRect.right - 35, cardRect.bottom - 30), 12, Paint()..color = Colors.white.withValues(alpha: 0.5)..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(cardRect.right - 25, cardRect.bottom - 30), 12, Paint()..color = AppTheme.accent.withValues(alpha: 0.5)..style = PaintingStyle.fill);

    // 2. Draw circular countdown clock (representing parking timer)
    final clockCenter = Offset(center.dx + width * 0.18, center.dy + height * 0.14);
    final clockRadius = width * 0.22;

    final clockGlow = Paint()
      ..color = AppTheme.accent.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(clockCenter, clockRadius, clockGlow);

    final clockBg = Paint()
      ..color = AppTheme.surface
      ..style = PaintingStyle.fill;
    canvas.drawCircle(clockCenter, clockRadius * 0.9, clockBg);

    final clockOutline = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(clockCenter, clockRadius * 0.9, clockOutline);

    // Draw active timer countdown stroke (golden arch)
    final double sweepAngle = 2 * math.pi * 0.65 * animFactor; // 65% time remaining
    final timerStroke = Paint()
      ..color = AppTheme.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: clockCenter, radius: clockRadius * 0.9),
      -math.pi / 2,
      sweepAngle,
      false,
      timerStroke,
    );

    // Draw clock hands
    final handsPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    
    // Hour hand
    canvas.drawLine(clockCenter, Offset(clockCenter.dx + clockRadius * 0.45 * math.cos(math.pi / 6), clockCenter.dy + clockRadius * 0.45 * math.sin(math.pi / 6)), handsPaint);
    // Minute hand (pointing up/angled)
    canvas.drawLine(clockCenter, Offset(clockCenter.dx + clockRadius * 0.6 * math.cos(-math.pi / 2.5), clockCenter.dy + clockRadius * 0.6 * math.sin(-math.pi / 2.5)), handsPaint);

    // Central pin of clock
    canvas.drawCircle(clockCenter, 4.0, Paint()..color = AppTheme.accent..style = PaintingStyle.fill);

    // 3. Floating checkmark for successful transaction/payment
    final checkCenter = Offset(center.dx - width * 0.2, center.dy + height * 0.12);
    final checkPaint = Paint()
      ..color = Colors.green[400]!
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(checkCenter, 20 * animFactor, Paint()..color = Colors.green[400]!.withValues(alpha: 0.5)..style = PaintingStyle.fill);
    canvas.drawCircle(checkCenter, 15 * animFactor, checkPaint);

    // Checkmark symbol vectors
    final checkMarkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    
    final checkPath = Path()
      ..moveTo(checkCenter.dx - 5 * animFactor, checkCenter.dy)
      ..lineTo(checkCenter.dx - 1 * animFactor, checkCenter.dy + 4 * animFactor)
      ..lineTo(checkCenter.dx + 6 * animFactor, checkCenter.dy - 3 * animFactor);
    canvas.drawPath(checkPath, checkMarkPaint);
  }

  @override
  bool shouldRepaint(covariant PaymentPainter oldDelegate) {
    return oldDelegate.scrollPercent != scrollPercent;
  }
}
