import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme_config.dart';

// ignore: library_private_types_in_public_api (these are intentionally public)
enum ButtonSize { regular, large }
enum ButtonVariant { primary, success, danger, ghost }

/// Premium haptic button with gradient fills, press animation, and loading state.
class HapticButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final ButtonVariant variant;
  final VoidCallback? onPressed;
  final ButtonSize size;
  final bool isLoading;

  const HapticButton({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.variant = ButtonVariant.primary,
    this.onPressed,
    this.size = ButtonSize.regular,
    this.isLoading = false,
  });

  @override
  State<HapticButton> createState() => _HapticButtonState();
}

class _HapticButtonState extends State<HapticButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  (Gradient?, Color) _resolveStyle() {
    if (widget.color != null) {
      return (
        LinearGradient(
          colors: [widget.color!, widget.color!.withValues(alpha: 0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        Colors.white,
      );
    }
    return switch (widget.variant) {
      ButtonVariant.primary => (AppTheme.goldGradient, AppTheme.darkBg),
      ButtonVariant.success => (AppTheme.successGradient, Colors.white),
      ButtonVariant.danger => (
          const LinearGradient(
            colors: [AppTheme.danger, Color(0xFFE0302A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          Colors.white,
        ),
      ButtonVariant.ghost => (null, AppTheme.textSecondary),
    };
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.size == ButtonSize.large ? 56.0 : 46.0;
    final fontSize = widget.size == ButtonSize.large ? 17.0 : 14.0;
    final isDisabled = widget.onPressed == null || widget.isLoading;
    final (gradient, textColor) = _resolveStyle();

    return GestureDetector(
      onTapDown: isDisabled
          ? null
          : (_) {
              HapticFeedback.lightImpact();
              _pressCtrl.forward();
            },
      onTapUp: isDisabled
          ? null
          : (_) {
              _pressCtrl.reverse();
              widget.onPressed?.call();
            },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedOpacity(
          opacity: isDisabled ? 0.45 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              gradient: gradient,
              color: gradient == null ? AppTheme.cardColor : null,
              borderRadius: BorderRadius.circular(14),
              border: widget.variant == ButtonVariant.ghost
                  ? Border.all(color: AppTheme.borderColor, width: 0.5)
                  : null,
              boxShadow: isDisabled
                  ? null
                  : gradient != null
                      ? [
                          BoxShadow(
                            color: (widget.color ??
                                    (widget.variant == ButtonVariant.primary
                                        ? AppTheme.gold
                                        : AppTheme.success))
                                .withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
            ),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: textColor,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, color: textColor, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.label,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: fontSize,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
