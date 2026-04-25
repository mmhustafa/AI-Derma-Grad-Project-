// lib/presentation/screens/05_analyzing/analyzing_screen.dart

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../config/routes/app_router.dart';

class AnalyzingScreen extends StatefulWidget {
  const AnalyzingScreen({super.key});

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // محاكاة عملية التحليل
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        context.go(AppRouter.aiResult);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F9FF),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background Pattern
            Positioned.fill(
              child: Opacity(
                opacity: 0.03,
                child: CustomPaint(
                  painter: _DotPatternPainter(),
                ),
              ),
            ),

            // Main Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Circles
                  FadeIn(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer ring
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 0.95 + (_controller.value * 0.1),
                              child: Opacity(
                                opacity: 0.8 - (_controller.value * 0.4),
                                child: Container(
                                  width: 128,
                                  height: 128,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primaryContainer,
                                      width: 4,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // Middle ring
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _controller.value * 6.28,
                              child: Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primaryContainer
                                        .withOpacity(0.4),
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // Center icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.06),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.biotech_rounded,
                            size: 40,
                            color: AppColors.primaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Title
                  FadeInDown(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      'Thinking...',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Subtitle
                  FadeInDown(
                    delay: const Duration(milliseconds: 400),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Text(
                        'Please wait while our Al-Derma neural engine analyzes your data for clinical insights.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Tag
                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    child: Text(
                      'AL-DERMA NEURAL ENGINE',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.outline.withOpacity(0.6),
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Quote
            Positioned(
              bottom: 64,
              left: 0,
              right: 0,
              child: FadeInUp(
                delay: const Duration(milliseconds: 800),
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 1,
                      color: AppColors.outlineVariant.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Text(
                        '"Accuracy is the bridge between data and care."',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                            (index) => AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            final delay = index * 0.33;
                            final value =
                            (_controller.value - delay).clamp(0.0, 1.0);
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer.withOpacity(
                                  0.3 + (value * 0.7),
                                ),
                                shape: BoxShape.circle,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Top Branding
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: FadeIn(
                      child: Text(
                        'CLINICAL SANCTUARY',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary.withOpacity(0.4),
                          letterSpacing: 4,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Dot Pattern Painter
class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    const spacing = 24.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}