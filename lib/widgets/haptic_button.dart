import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

enum ButtonSize { regular, large }

class HapticButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final VoidCallback? onPressed;
  final ButtonSize size;

  const HapticButton({
    super.key,
    required this.label,
    this.icon,
    required this.color,
    this.onPressed,
    this.size = ButtonSize.regular,
  });

  @override
  Widget build(BuildContext context) {
    final double height = size == ButtonSize.large ? 56 : 44;
    final double fontSize = size == ButtonSize.large ? 18 : 15;

    return SizedBox(
      height: height,
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        onPressed: onPressed == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onPressed!();
              },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: fontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
