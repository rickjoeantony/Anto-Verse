import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Ultra-modern interactive button with animated light shimmer sweep and spring press feedback.
class ShimmerButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final Gradient? gradient;

  const ShimmerButton({
    super.key,
    required this.child,
    this.onPressed,
    this.width,
    this.height = 50,
    this.borderRadius,
    this.gradient,
  });

  @override
  State<ShimmerButton> createState() => _ShimmerButtonState();
}

class _ShimmerButtonState extends State<ShimmerButton> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final radius = widget.borderRadius ?? BorderRadius.circular(16);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: widget.gradient ??
                LinearGradient(
                  colors: [
                    colors.brandPrimary,
                    colors.brandPrimaryDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
            boxShadow: [
              BoxShadow(
                color: colors.brandPrimary.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Animated Shimmer Light Sweep
                AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    final progress = _shimmerController.value;
                    return Positioned.fill(
                      child: Transform.translate(
                        offset: Offset(progress * 300 - 150, 0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.0),
                                Colors.white.withOpacity(0.22),
                                Colors.white.withOpacity(0.0),
                              ],
                              stops: const [0.3, 0.5, 0.7],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: widget.child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
