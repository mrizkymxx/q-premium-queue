import 'package:flutter/material.dart';
import '../config/theme_config.dart';

/// A premium statistics chip for the operator dashboard.
class StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  const StatChip({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.accentColor = AppTheme.gold,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: accentColor),
                const SizedBox(width: 6),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: accentColor,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
