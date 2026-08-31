// lib/features/onboarding/presentation/onboarding_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/floating_3d_wrapper.dart';
import '../../../core/widgets/glass/glass_card.dart';
import '../../../core/widgets/leukquant_logo.dart';
import '../../../core/widgets/lockscreen_setup_dialog.dart';
import '../../../core/widgets/onboarding_illustrations.dart';
import '../providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'stage': 'OBSERVE',
      'title': 'See suspicious activity early',
      'description':
          'Ghost-Net observes interaction with controlled decoy services before attackers reach real systems.',
      'imagePath': 'assets/images/onboard_observe_3d.jpg',
      'fallback': const ObserveIllustration(size: 160),
    },
    {
      'stage': 'UNDERSTAND',
      'title': 'Understand every security event',
      'description':
          'Turn complex security signals into clear timelines, severity, and recommended actions.',
      'imagePath': 'assets/images/onboard_understand_3d.jpg',
      'fallback': const UnderstandIllustration(size: 160),
    },
    {
      'stage': 'ACT',
      'title': 'Act with confidence',
      'description':
          'Receive verified incident updates and keep your organisation informed.',
      'imagePath': 'assets/images/onboard_act_3d.jpg',
      'fallback': const ActIllustration(size: 160),
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    // Show mandatory Lock-Screen & Alert Permissions Dialog before entering Login
    await LockScreenSetupDialog.show(
      context,
      onComplete: () async {
        await ref.read(onboardingProvider.notifier).completeOnboarding();
        if (mounted) {
          context.go('/login');
        }
      },
    );
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final progress = (_currentPage + 1) / _pages.length;

    return Scaffold(
      backgroundColor: colors.background,
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top Header with Official Logo & SKIP
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const LeukQuantLogo(height: 30),
                    TextButton(
                      onPressed: _finishOnboarding,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                      child: Text(
                        'SKIP',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colors.brandPrimary,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Floating Glass Illustration Card Carousel
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    final imagePath = page['imagePath'] as String;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                      child: GlassCard(
                        borderRadius: 32.0,
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                                child: IntrinsicHeight(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Floating Vector Illustration
                                      SizedBox(
                                        height: math.min(constraints.maxHeight * 0.45, 170.0),
                                        child: Floating3DWrapper(
                                          floatDistance: 4.0,
                                          duration: const Duration(milliseconds: 2600),
                                          child: Center(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(20),
                                              child: Image.asset(
                                                imagePath,
                                                fit: BoxFit.contain,
                                                errorBuilder: (context, error, stackTrace) =>
                                                    page['fallback'] as Widget,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Stage Category Pill
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                                        decoration: BoxDecoration(
                                          color: colors.brandPrimary.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: colors.brandPrimary.withValues(alpha: 0.25),
                                          ),
                                        ),
                                        child: Text(
                                          page['stage'] as String,
                                          style: TextStyle(
                                            color: colors.brandPrimary,
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // Title
                                      Text(
                                        page['title'] as String,
                                        style: theme.textTheme.headlineMedium?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: colors.textPrimary,
                                          fontSize: 20,
                                          letterSpacing: -0.4,
                                          height: 1.25,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),

                                      // Description
                                      Text(
                                        page['description'] as String,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: colors.textSecondary,
                                          fontSize: 13,
                                          height: 1.45,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom Pagination & Circular Action Button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    if (_currentPage > 0)
                      IconButton(
                        onPressed: _prevPage,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                        color: colors.textSecondary,
                        tooltip: 'Previous',
                      )
                    else
                      const SizedBox(width: 48),

                    // Glass Active Pill Pagination Dots
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(_pages.length, (index) {
                        final isActive = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          width: isActive ? 24 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: isActive
                                ? colors.brandPrimary
                                : colors.border.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),

                    // Circular Progress Next Button
                    GestureDetector(
                      onTap: _nextPage,
                      child: SizedBox(
                        width: 52,
                        height: 52,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Progress Ring
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0.0, end: progress),
                              duration: const Duration(milliseconds: 350),
                              builder: (context, value, child) {
                                return CustomPaint(
                                  size: const Size(52, 52),
                                  painter: _ProgressRingPainter(
                                    progress: value,
                                    color: colors.brandPrimary,
                                    bgColor: colors.border.withValues(alpha: 0.3),
                                  ),
                                );
                              },
                            ),
                            // Inner Button Circle
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    colors.brandPrimary,
                                    colors.brandPrimaryDark,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.brandPrimary.withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _currentPage == _pages.length - 1
                                    ? Icons.check_rounded
                                    : Icons.arrow_forward_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
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
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color bgColor;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Background track
    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius, bgPaint);

    // Active arc
    final activePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
