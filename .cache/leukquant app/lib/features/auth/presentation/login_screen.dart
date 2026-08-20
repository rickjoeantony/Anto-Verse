// lib/features/auth/presentation/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/leukquant_logo.dart';
import '../../../core/widgets/shimmer_button.dart';
import '../providers/auth_state_provider.dart';

/// Modernized Login Screen with real middle-man-3 staging API authentication.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref.read(authProvider.notifier).signIn(
            _emailController.text.trim(),
            _passwordController.text,
          );
      if (success && mounted) {
        context.go('/overview');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: AmbientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top bar with Theme Switcher
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(
                        isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                        color: colors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Official Logo
                  const LeukQuantLogo(height: 48)
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 400.ms),
                  const SizedBox(height: 16),

                  Text(
                    'Welcome back',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                      letterSpacing: -0.4,
                      fontSize: 22,
                    ),
                  ).animate().fadeIn(duration: 350.ms, delay: 80.ms),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to access your organisation’s security workspace.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 350.ms, delay: 120.ms),
                  const SizedBox(height: 24),

                  // Sign-in Card
                  Container(
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.12)
                            : Colors.white.withOpacity(0.9),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black54
                              : const Color(0x122563EB),
                          blurRadius: 36,
                          spreadRadius: -4,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Error Alert Banner
                          if (authState.errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colors.critical.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: colors.critical.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline_rounded, size: 18, color: colors.critical),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      authState.errorMessage!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: colors.critical,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(duration: 250.ms).shake(duration: 300.ms),
                            const SizedBox(height: 16),
                          ],

                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Work Email',
                              hintText: 'name@organisation.com',
                              prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty || !val.contains('@')) {
                                return 'Please enter a valid work email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          ShimmerButton(
                            height: 50,
                            borderRadius: BorderRadius.circular(14),
                            onPressed: authState.isAuthenticating ? null : _handleSignIn,
                            child: authState.isAuthenticating
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Sign In',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14.5,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 160.ms).slideY(begin: 0.08, end: 0, duration: 400.ms),
                  const SizedBox(height: 24),

                  Text(
                    AppConstants.copyright,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
