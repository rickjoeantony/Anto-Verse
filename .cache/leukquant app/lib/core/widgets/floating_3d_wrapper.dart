import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Interactive 3D floating animation wrapper giving continuous smooth bobbing physics.
class Floating3DWrapper extends StatefulWidget {
  final Widget child;
  final double floatDistance;
  final Duration duration;

  const Floating3DWrapper({
    super.key,
    required this.child,
    this.floatDistance = 8.0,
    this.duration = const Duration(milliseconds: 2400),
  });

  @override
  State<Floating3DWrapper> createState() => _Floating3DWrapperState();
}

class _Floating3DWrapperState extends State<Floating3DWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: -widget.floatDistance,
      end: widget.floatDistance,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final val = _animation.value;
        return Transform.translate(
          offset: Offset(0, val),
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}
