// lib/core/widgets/ios26_switch.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// iOS 26-style premium toggle switch.
///
/// Replicates the distinctive iOS 26 design language:
/// - OFF: light grey pill with inner white oval thumb with deep inset shadow
/// - ON:  vivid green pill with right-side white oval thumb with inner shadow
/// - Smooth spring-curve animated slide with scale micro-animation
/// - Haptic feedback on toggle
class Ios26Switch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final double scale;

  const Ios26Switch({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.scale = 1.0,
  });

  @override
  State<Ios26Switch> createState() => _Ios26SwitchState();
}

class _Ios26SwitchState extends State<Ios26Switch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Switch dimensions (iPhone-accurate at 1x)
  static const double _trackW = 72.0;
  static const double _trackH = 44.0;
  static const double _thumbW = 36.0;
  static const double _thumbH = 36.0;
  static const double _padding = 4.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: widget.value ? 1.0 : 0.0,
    );

    _slideAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInBack,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 70),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(Ios26Switch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onChanged == null) return;
    HapticFeedback.mediumImpact();
    widget.onChanged!(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final Color activeColor = widget.activeColor ?? const Color(0xFF34C759); // iOS green default

    return GestureDetector(
      onTap: _handleTap,
      child: Transform.scale(
        scale: widget.scale,
        child: SizedBox(
          width: _trackW,
          height: _trackH,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _slideAnimation.value;
              final trackColor = Color.lerp(
                const Color(0xFFE0E0E0),
                activeColor,
                t,
              )!;
              const maxSlide = _trackW - _thumbW - _padding * 2;

              return Stack(
                children: [
                  // Track with inner shadow groove effect
                  Container(
                    width: _trackW,
                    height: _trackH,
                    decoration: BoxDecoration(
                      color: trackColor,
                      borderRadius: BorderRadius.circular(_trackH / 2),
                      boxShadow: [
                        // Outer glow when ON
                        if (t > 0.5)
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.35 * t),
                            blurRadius: 12,
                            spreadRadius: 0,
                          ),
                        // Inset-style bottom shadow for OFF state depth
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12 * (1 - t)),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    // Inner shadow on track (for depth/groove)
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(_trackH / 2),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: t < 0.5
                                ? [
                                    Colors.black.withValues(alpha: 0.06),
                                    Colors.transparent,
                                  ]
                                : [
                                    activeColor.withValues(alpha: 0.0),
                                    activeColor.withValues(alpha: 0.0),
                                  ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Thumb (oval white pill with deep shadow)
                  Positioned(
                    top: _padding,
                    left: _padding + t * maxSlide,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: _thumbW,
                        height: _thumbH,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(_thumbH / 2),
                          boxShadow: [
                            // Primary drop shadow
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.22),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                              spreadRadius: 0,
                            ),
                            // Ambient shadow
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.10),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                            // Top specular highlight
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.9),
                              blurRadius: 2,
                              offset: const Offset(0, -1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
