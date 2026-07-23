import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';

class GlassNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const GlassNavBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: preferredSize.height,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            border: Border(
              bottom: BorderSide(
                color: CupertinoTheme.of(context)
                    .primaryColor
                    .withValues(alpha: 0.12),
                width: 0.5,
              ),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}
