import 'package:flutter/material.dart';
import '../config/theme_config.dart';

/// Premium dark card container with optional elevation shadow.
class SquircleCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double elevation;
  final Border? border;

  const SquircleCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.elevation = 0,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: color ?? AppTheme.cardColor,
        border: border ??
            Border.all(color: AppTheme.borderColor, width: 0.5),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 20 * elevation,
                  offset: Offset(0, 6 * elevation),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}
