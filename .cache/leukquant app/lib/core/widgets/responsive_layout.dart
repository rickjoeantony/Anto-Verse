// lib/core/widgets/responsive_layout.dart

import 'package:flutter/material.dart';

/// Screen size category breakpoints.
enum ScreenCategory {
  phoneSmall,    // < 360px
  phoneStandard, // 360 - 599px
  tablet,        // 600 - 899px
  desktopWide,   // >= 900px
}

/// Adaptive layout builder for responsive phone, tablet, and landscape layouts.
class ResponsiveLayout extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenCategory category, BoxConstraints constraints) builder;

  const ResponsiveLayout({
    super.key,
    required this.builder,
  });

  static ScreenCategory getCategory(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return ScreenCategory.phoneSmall;
    if (width < 600) return ScreenCategory.phoneStandard;
    if (width < 900) return ScreenCategory.tablet;
    return ScreenCategory.desktopWide;
  }

  static bool isTabletOrWide(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final category = constraints.maxWidth < 360
            ? ScreenCategory.phoneSmall
            : constraints.maxWidth < 600
                ? ScreenCategory.phoneStandard
                : constraints.maxWidth < 900
                    ? ScreenCategory.tablet
                    : ScreenCategory.desktopWide;

        return builder(context, category, constraints);
      },
    );
  }
}
