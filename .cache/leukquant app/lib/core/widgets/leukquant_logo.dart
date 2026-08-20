import 'package:flutter/material.dart';

/// Official LeukQuant Logo Widget rendering logo-full.png with fallback support.
class LeukQuantLogo extends StatelessWidget {
  final double size;
  final double? height;
  final bool showText;
  final bool showSubtitle;

  const LeukQuantLogo({
    super.key,
    this.size = 40,
    this.height,
    this.showText = false,
    this.showSubtitle = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? size;

    return Image.asset(
      'assets/images/logo-full.png',
      height: effectiveHeight,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // High-fidelity fallback vector shield if asset is loading
        return SizedBox(
          width: size,
          height: effectiveHeight,
          child: CustomPaint(
            painter: _FallbackLogoPainter(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      },
    );
  }
}

class _FallbackLogoPainter extends CustomPainter {
  final Color color;

  _FallbackLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.5, 4)
      ..lineTo(size.width - 4, size.height * 0.28)
      ..lineTo(size.width - 4, size.height * 0.65)
      ..cubicTo(size.width - 4, size.height * 0.88, size.width * 0.5, size.height - 2, size.width * 0.5, size.height - 2)
      ..cubicTo(size.width * 0.5, size.height - 2, 4, size.height * 0.88, 4, size.height * 0.65)
      ..lineTo(4, size.height * 0.28)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FallbackLogoPainter oldDelegate) => false;
}
