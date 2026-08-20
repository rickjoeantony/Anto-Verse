// lib/core/animation/app_motion.dart

import 'package:flutter/material.dart';

/// Central motion tokens adhering to calm enterprise design principles.
class AppMotion {
  AppMotion._();

  // Durations
  static const Duration splash = Duration(milliseconds: 750);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration pageTransition = Duration(milliseconds: 240);
  static const Duration modalSpring = Duration(milliseconds: 320);

  // Stagger delays
  static const Duration staggerBase = Duration(milliseconds: 40);

  // Curves
  static const Curve standard = Curves.easeOutCubic;
  static const Curve smooth = Curves.easeInOutCubic;
  static const Curve enter = Curves.easeOutQuad;

  /// Helper to check if reduced motion is requested by OS accessibility settings
  static bool isReducedMotion(BuildContext context) {
    return MediaQuery.disableAnimationsOf(context);
  }

  /// Get effective duration respecting accessibility reduced motion
  static Duration duration(BuildContext context, Duration original) {
    return isReducedMotion(context) ? Duration.zero : original;
  }
}
