// lib/core/widgets/shimmer_skeleton.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Clean enterprise shimmer skeleton loader.
class ShimmerSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final Widget? child;

  const ShimmerSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.child,
  });

  @override
  State<ShimmerSkeleton> createState() => _ShimmerSkeletonState();
}

class _ShimmerSkeletonState extends State<ShimmerSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (MediaQuery.disableAnimationsOf(context)) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: colors.surfaceMuted,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + (_controller.value * 2.5), -0.3),
              end: Alignment(0.5 + (_controller.value * 2.5), 0.3),
              colors: [
                colors.surfaceMuted,
                isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.6),
                colors.surfaceMuted,
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Shimmer card for dashboard metrics
class MetricCardSkeleton extends StatelessWidget {
  const MetricCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShimmerSkeleton(
      height: 110,
      borderRadius: 24,
    );
  }
}

/// Shimmer card for line/bar charts
class ChartSkeleton extends StatelessWidget {
  final double height;

  const ChartSkeleton({super.key, this.height = 210});

  @override
  Widget build(BuildContext context) {
    return ShimmerSkeleton(
      height: height,
      borderRadius: 24,
    );
  }
}
