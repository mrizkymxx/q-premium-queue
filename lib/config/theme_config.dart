import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryColor = Color(0xFF007AFF);

  static const CupertinoThemeData cupertinoTheme = CupertinoThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    barBackgroundColor: Color.fromRGBO(255, 255, 255, 0.72),
    textTheme: CupertinoTextThemeData(
      primaryColor: primaryColor,
      textStyle: TextStyle(fontFamily: '.SF Pro'),
    ),
  );

  static BoxDecoration glassDecoration({
    double blurSigma = 20,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(16)),
    Color color = Colors.white,
  }) {
    return BoxDecoration(
      borderRadius: borderRadius,
      color: color.withValues(alpha: 0.72),
    );
  }

  static BorderRadius squircleRadius(double size) {
    return BorderRadius.circular(size);
  }
}
