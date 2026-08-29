// lib/core/widgets/glass/liquid_glass_app_bar.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

/// iOS-inspired Liquid Glass App Bar with dynamic frosted blur on scroll,
/// specular edge highlights, and high-contrast Plus Jakarta Sans typography.
class LiquidGlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool isScrolled;
  final bool showBack;
  final VoidCallback? onBack;
  final double intensity;
  final double cornerRadius;

  const LiquidGlassAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.isScrolled = false,
    this.showBack = false,
    this.onBack,
    this.intensity = 1.0,
    this.cornerRadius = 0.0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4.0);

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final blurSigma = isScrolled ? 24.0 : 0.0;
    final backgroundColor = isScrolled
        ? colors.glassStrongFill
        : Colors.transparent;

    final borderBottomColor = isScrolled
        ? colors.glassBorder
        : Colors.transparent;

    return RepaintBoundary(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurSigma,
            sigmaY: blurSigma,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: borderBottomColor,
                  width: 1.0,
                ),
              ),
              boxShadow: isScrolled
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.25 : 0.04,
                        ),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: SafeArea(
              bottom: false,
              child: Container(
                height: kToolbarHeight,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    if (showBack)
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: colors.textPrimary,
                        ),
                        onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                      )
                    else if (leading != null)
                      leading!,
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: isScrolled ? 16.5 : 19.5,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                              letterSpacing: -0.4,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle != null && !isScrolled)
                            Text(
                              subtitle!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: colors.textSecondary,
                                letterSpacing: -0.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    if (actions != null) ...actions!,
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
