import 'package:flutter/material.dart';
import '../config/theme_config.dart';

/// Premium calling card with animated gold glow when a customer is active.
class CallingCard extends StatelessWidget {
  final int? queueNumber;
  final String? queuePrefix;
  final String? customerName;

  const CallingCard({
    super.key,
    this.queueNumber,
    this.queuePrefix,
    this.customerName,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = queueNumber != null;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween(begin: 0.96, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
      child: hasData
          ? _ActiveCallingCard(
              key: ValueKey('$queuePrefix-$queueNumber'),
              queueNumber: queueNumber!,
              queuePrefix: queuePrefix ?? 'A',
              customerName: customerName,
            )
          : const _EmptyCallingCard(key: ValueKey('empty')),
    );
  }
}

// ── Active State ──────────────────────────────────────────────────────────────

class _ActiveCallingCard extends StatefulWidget {
  final int queueNumber;
  final String queuePrefix;
  final String? customerName;

  const _ActiveCallingCard({
    super.key,
    required this.queueNumber,
    required this.queuePrefix,
    this.customerName,
  });

  @override
  State<_ActiveCallingCard> createState() => _ActiveCallingCardState();
}

class _ActiveCallingCardState extends State<_ActiveCallingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    _glowAnim = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayNumber =
        '${widget.queuePrefix}-${widget.queueNumber.toString().padLeft(3, '0')}';

    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, child) {
        return Container(
          height: 210,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: AppTheme.darkCardGradient,
            border: Border.all(
              color: AppTheme.gold
                  .withValues(alpha: 0.3 + _glowAnim.value * 0.45),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.gold
                    .withValues(alpha: 0.04 + _glowAnim.value * 0.18),
                blurRadius: 20 + _glowAnim.value * 28,
                spreadRadius: _glowAnim.value * 6,
              ),
            ],
          ),
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Gold shimmer line at top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppTheme.gold.withValues(alpha: 0.9),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // "Sedang Dipanggil" label
            Positioned(
              top: 18,
              left: 20,
              child: Text(
                'SEDANG DIPANGGIL',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.gold.withValues(alpha: 0.7),
                  letterSpacing: 2.5,
                ),
              ),
            ),
            // Pulsing status dot
            Positioned(
              top: 16,
              right: 16,
              child: AnimatedBuilder(
                animation: _glowAnim,
                builder: (context, _) {
                  return Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppTheme.success,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.success.withValues(
                              alpha: 0.3 + _glowAnim.value * 0.5),
                          blurRadius: 4 + _glowAnim.value * 10,
                          spreadRadius: _glowAnim.value * 3,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    displayNumber,
                    style: AppTheme.displayLarge(),
                  ),
                  const SizedBox(height: 10),
                  if (widget.customerName != null)
                    Text(
                      widget.customerName!.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                        letterSpacing: 2.0,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    '— Loket 1 —',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.gold.withValues(alpha: 0.65),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyCallingCard extends StatelessWidget {
  const _EmptyCallingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppTheme.surfaceColor,
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.queue_outlined,
              size: 36,
              color: AppTheme.textMuted,
            ),
            const SizedBox(height: 14),
            const Text(
              'Belum Ada Antrian Aktif',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tekan "Panggil Berikutnya" untuk memulai',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
