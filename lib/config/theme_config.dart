import 'package:flutter/material.dart';

/// Q-PREMIUM Design System
///
/// Dark premium theme: deep charcoal (#0D0D0F) + gold accent (#D4AF6A).
/// Inter font loaded via CDN in web/index.html.
class AppTheme {
  AppTheme._();

  // ── Color Tokens ─────────────────────────────────────────────
  static const Color darkBg       = Color(0xFF0D0D0F);
  static const Color surfaceColor = Color(0xFF161618);
  static const Color cardColor    = Color(0xFF1C1C1E);
  static const Color borderColor  = Color(0xFF2C2C2E);

  static const Color gold         = Color(0xFFD4AF6A);
  static const Color goldLight    = Color(0xFFF0D49A);
  static const Color goldDark     = Color(0xFFA88A4A);

  static const Color success      = Color(0xFF30D158);
  static const Color successDim   = Color(0xFF0F2A18);
  static const Color danger       = Color(0xFFFF453A);
  static const Color dangerDim    = Color(0xFF2A0F0F);
  static const Color warning      = Color(0xFFFFD60A);
  static const Color warningDim   = Color(0xFF2A2000);

  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textMuted     = Color(0xFF48484A);

  // ── Gradients ─────────────────────────────────────────────────
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4AF6A), Color(0xFFF0D49A), Color(0xFFD4AF6A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF30D158), Color(0xFF00B341)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1A1A1C), Color(0xFF232325)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Shadows ───────────────────────────────────────────────────
  static List<BoxShadow> goldGlow({double intensity = 1.0}) => [
    BoxShadow(
      color: gold.withValues(alpha: 0.20 * intensity),
      blurRadius: 24 * intensity,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: gold.withValues(alpha: 0.08 * intensity),
      blurRadius: 48 * intensity,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> successGlow({double intensity = 1.0}) => [
    BoxShadow(
      color: success.withValues(alpha: 0.25 * intensity),
      blurRadius: 20 * intensity,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  // ── Typography (Inter via CDN) ────────────────────────────────
  static const String _font = 'Inter';

  static TextStyle displayHero({Color color = textPrimary}) => TextStyle(
    fontFamily: _font, fontSize: 100, fontWeight: FontWeight.w900,
    color: color, letterSpacing: -4, height: 1,
  );

  static TextStyle displayLarge({Color color = textPrimary}) => TextStyle(
    fontFamily: _font, fontSize: 64, fontWeight: FontWeight.w900,
    color: color, letterSpacing: -2, height: 1,
  );

  static TextStyle headlineLarge({Color color = textPrimary}) => TextStyle(
    fontFamily: _font, fontSize: 28, fontWeight: FontWeight.w700,
    color: color, letterSpacing: -0.5,
  );

  static TextStyle headlineMedium({Color color = textPrimary}) => TextStyle(
    fontFamily: _font, fontSize: 20, fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle titleLarge({Color color = textPrimary}) => TextStyle(
    fontFamily: _font, fontSize: 18, fontWeight: FontWeight.w700,
    color: color, letterSpacing: 0.3,
  );

  static TextStyle titleMedium({Color color = textPrimary}) => TextStyle(
    fontFamily: _font, fontSize: 16, fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle bodyLarge({Color color = textPrimary}) => TextStyle(
    fontFamily: _font, fontSize: 16, fontWeight: FontWeight.w400,
    color: color,
  );

  static TextStyle bodyMedium({Color color = textSecondary}) => TextStyle(
    fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w400,
    color: color,
  );

  static TextStyle labelSmall({Color color = textSecondary}) => TextStyle(
    fontFamily: _font, fontSize: 11, fontWeight: FontWeight.w600,
    color: color, letterSpacing: 1.5,
  );

  // ── Material Theme ────────────────────────────────────────────
  static ThemeData get materialTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      fontFamily: _font,
      colorScheme: const ColorScheme.dark(
        primary: gold,
        secondary: goldLight,
        surface: surfaceColor,
        error: danger,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderColor, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderColor, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: gold, width: 1.0),
        ),
        hintStyle: const TextStyle(
          fontFamily: _font, fontSize: 16,
          color: textMuted, fontWeight: FontWeight.w400,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      ),
      dividerColor: borderColor,
    );
  }

  // ── Decorations ───────────────────────────────────────────────
  static BoxDecoration get cardDecoration => const BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.all(Radius.circular(20)),
    border: Border.fromBorderSide(BorderSide(color: borderColor, width: 0.5)),
    boxShadow: cardShadow,
  );

  static BoxDecoration glassDecoration({
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(16)),
  }) {
    return BoxDecoration(
      borderRadius: borderRadius,
      color: Colors.white.withValues(alpha: 0.05),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.08),
        width: 0.5,
      ),
    );
  }
}
