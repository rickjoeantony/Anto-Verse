// lib/features/auth/presentation/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/glass/liquid_glass_card.dart';
import '../../../core/widgets/glass/liquid_glass_button.dart';
import '../../../core/widgets/leukquant_logo.dart';
import '../providers/auth_state_provider.dart';

/// Liquid Glass login screen with secure credential handling and clear errors.
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
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final success = await ref.read(authProvider.notifier).signIn(
          email,
          password,
        );

    if (success && mounted) {
      context.go('/overview');
    }
  }

  Future<void> _retrySignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) return;

    final success = await ref.read(authProvider.notifier).signIn(
          email,
          password,
        );

    if (success && mounted) {
      context.go('/overview');
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
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Theme Switcher Row
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0x33FFFFFF) : const Color(0x0D000000),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.glassBorder,
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                          color: colors.textPrimary,
                          size: 18,
                        ),
                        onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Logo + Brand
                  const LeukQuantLogo(height: 48),
                  const SizedBox(height: 12),
                  Text(
                    'LeukQuant',
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Next-Gen Active Cyber Defense',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // Environment Indicator Pill
                  if (!AppConfig.isProduction) ...[
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppConfig.isLocal
                            ? colors.warning.withValues(alpha: 0.15)
                            : colors.brandPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppConfig.isLocal
                              ? colors.warning.withValues(alpha: 0.35)
                              : colors.brandPrimary.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        AppConfig.isLocal ? 'DEV/LOCAL BACKEND' : 'STAGING',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppConfig.isLocal ? colors.warning : colors.brandPrimary,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Unconfigured Warning Notice
                  if (!AppConfig.isConfigured) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: colors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.warning.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 18, color: colors.warning),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              AppConfig.notConfiguredNotice,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: colors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Liquid Glass Login Card
                  LiquidGlassCard(
                    cornerRadius: 32,
                    padding: const EdgeInsets.all(26),
                    isStrongGlass: true,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Welcome back',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colors.textPrimary,
                              fontSize: 20,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sign in to access your organisation’s security workspace.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.textSecondary,
                              fontSize: 12.5,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Error Banner
                          if (authState.errorMessage != null) ...[
                            _buildErrorBanner(authState, colors),
                            const SizedBox(height: 16),
                          ],

                          // Email Input
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Work Email',
                              hintText: 'name@organisation.com',
                              prefixIcon: Icon(
                                Icons.mail_outline_rounded,
                                size: 18,
                                color: colors.textSecondary,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0x22FFFFFF)
                                  : const Color(0x0A000000),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: colors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: colors.border.withValues(alpha: 0.6),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: colors.brandPrimary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty || !val.contains('@')) {
                                return 'Please enter a valid work email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Password Input
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter password',
                              prefixIcon: Icon(
                                Icons.lock_outline_rounded,
                                size: 18,
                                color: colors.textSecondary,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 18,
                                  color: colors.textSecondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0x22FFFFFF)
                                  : const Color(0x0A000000),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: colors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: colors.border.withValues(alpha: 0.6),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: colors.brandPrimary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 22),

                          // Sign In Liquid Glass Button
                          LiquidGlassButton(
                            height: 48,
                            cornerRadius: 16,
                            onPressed: (authState.isAuthenticating || authState.isRateLimited)
                                ? null
                                : _handleSignIn,
                            child: authState.isAuthenticating
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        authState.isRateLimited
                                            ? 'Please wait (${authState.rateLimitCooldownSeconds}s)'
                                            : 'Sign In',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14.5,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.arrow_forward_rounded, size: 16),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Secure Enterprise Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 14,
                        color: colors.textSecondary.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Protected by LeukQuant AI Security Core',
                        style: TextStyle(
                          color: colors.textSecondary.withValues(alpha: 0.7),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppConstants.copyright,
                    style: TextStyle(
                      color: colors.textSecondary.withValues(alpha: 0.5),
                      fontSize: 10.5,
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

  Widget _buildErrorBanner(AuthState authState, AppColorScheme colors) {
    final isBackendError = authState.errorType == AuthErrorType.backendUnavailable;
    final bannerColor = isBackendError ? const Color(0xFFF59E0B) : colors.critical;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bannerColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isBackendError
                    ? Icons.cloud_off_rounded
                    : Icons.error_outline_rounded,
                size: 18,
                color: bannerColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  authState.errorMessage!,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: bannerColor,
                  ),
                ),
              ),
            ],
          ),
          if (isBackendError) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: authState.isAuthenticating ? null : _retrySignIn,
                icon: Icon(Icons.refresh_rounded, size: 16, color: bannerColor),
                label: Text(
                  'Retry Connection',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: bannerColor,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: bannerColor.withValues(alpha: 0.08),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
