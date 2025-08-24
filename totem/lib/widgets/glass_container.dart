import 'package:flutter/material.dart';
import 'dart:ui';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;
  final Color? color;
  final double blur;

  const GlassContainer({
    Key? key,
    required this.child,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(12.0),
    this.color,
    this.blur = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1.0,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
