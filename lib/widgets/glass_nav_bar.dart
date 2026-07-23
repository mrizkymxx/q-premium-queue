import 'package:flutter/material.dart';
import 'dart:ui';
import '../config/theme_config.dart';

/// Premium dark glassmorphism navigation bar with gold accent.
class GlassNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  const GlassNavBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          height: preferredSize.height,
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor.withValues(alpha: 0.92),
            border: const Border(
              bottom: BorderSide(color: AppTheme.gold, width: 0.5),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  if (leading != null) ...[leading!, const SizedBox(width: 12)],
                  // Gold dot + brand title
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _GoldDot(),
                      const SizedBox(width: 10),
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (actions != null) ...actions!,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

class _GoldDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: AppTheme.gold,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.gold.withValues(alpha: 0.7),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

/// Icon button styled for the premium dark navbar.
class NavBarIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const NavBarIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          margin: const EdgeInsets.only(left: 8),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.borderColor, width: 0.5),
          ),
          child: Icon(icon, color: AppTheme.textSecondary, size: 20),
        ),
      ),
    );
  }
}
