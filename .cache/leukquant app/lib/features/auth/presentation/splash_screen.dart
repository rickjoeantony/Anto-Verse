import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/floating_3d_wrapper.dart';
import '../../../core/widgets/leukquant_logo.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../providers/auth_state_provider.dart';

/// Splash screen displaying official LeukQuant logo and smooth transition.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _fadeController.forward();

    // Check existing session on startup
    _checkInitialAuth();
  }

  Future<void> _checkInitialAuth() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final hasCompletedOnboarding = ref.read(onboardingProvider);
    if (!hasCompletedOnboarding) {
      context.go('/onboarding');
      return;
    }

    // Attempt silent session recovery via stored refresh token/cookie
    final isSessionRestored = await ref.read(authProvider.notifier).tryRestoreSession();
    if (!mounted) return;

    if (isSessionRestored) {
      context.go('/overview');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: AmbientBackground(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    const Floating3DWrapper(
                      floatDistance: 8.0,
                      child: LeukQuantLogo(height: 54),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      AppConstants.appSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.brandSecondary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        fontSize: 13.5,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(colors.brandPrimary),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Initializing workspace...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
