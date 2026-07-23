import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/theme_config.dart';
import '../models/queue_transaction.dart';
import '../providers/queue_provider.dart';
import '../utils/date_helper.dart';

class PublicMonitorScreen extends StatefulWidget {
  const PublicMonitorScreen({super.key});

  @override
  State<PublicMonitorScreen> createState() => _PublicMonitorScreenState();
}

class _PublicMonitorScreenState extends State<PublicMonitorScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgCtrl;
  late Animation<double> _bgAnim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QueueProvider>().startRealtimeSubscription();
    });
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _bgAnim = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: AnimatedBuilder(
        animation: _bgAnim,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(
                  -0.4 + _bgAnim.value * 0.8,
                  -0.5 + _bgAnim.value * 0.3,
                ),
                radius: 1.6,
                colors: [
                  const Color(0xFF1A1600).withValues(
                      alpha: 0.6 + _bgAnim.value * 0.2),
                  AppTheme.darkBg,
                ],
              ),
            ),
            child: child,
          );
        },
        child: Consumer<QueueProvider>(
          builder: (context, provider, _) {
            final calling = provider.currentCalling;
            final nextFive = provider.waitingList.take(5).toList();

            return SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: Stack(
                      children: [
                        Center(child: _buildCallingDisplay(calling)),
                        Positioned(
                          bottom: 24,
                          right: 24,
                          child: _buildQueuePreview(nextFive),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withValues(alpha: 0.6),
        border: const Border(
          bottom: BorderSide(color: AppTheme.gold, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppTheme.gold,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.goldGlow(),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Q-PREMIUM',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const Spacer(),
          StreamBuilder<DateTime>(
            stream: Stream.periodic(
              const Duration(seconds: 1),
              (_) => DateTime.now(),
            ),
            builder: (context, snapshot) {
              return Text(
                formatTime(snapshot.data ?? DateTime.now()),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  color: AppTheme.textSecondary,
                  letterSpacing: 2,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCallingDisplay(QueueTransaction? calling) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 700),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween(begin: 0.75, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
      child: calling != null
          ? _ActiveDisplay(key: ValueKey(calling.id), calling: calling)
          : const _IdleDisplay(key: ValueKey('idle')),
    );
  }

  Widget _buildQueuePreview(List<QueueTransaction> nextFive) {
    if (nextFive.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'ANTRIAN SELANJUTNYA',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppTheme.textMuted,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          ...nextFive.map(
            (t) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppTheme.gold,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    t.displayNumber,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    )
    .animate()
    .fadeIn(duration: 400.ms)
    .slideX(begin: 0.1, end: 0, duration: 400.ms);
  }
}

// ── Active Display ────────────────────────────────────────────────────────────

class _ActiveDisplay extends StatefulWidget {
  final QueueTransaction calling;
  const _ActiveDisplay({super.key, required this.calling});

  @override
  State<_ActiveDisplay> createState() => _ActiveDisplayState();
}

class _ActiveDisplayState extends State<_ActiveDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'NOMOR ANTRIAN',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.gold,
            letterSpacing: 4,
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms),

        const SizedBox(height: 16),

        AnimatedBuilder(
          animation: _glowAnim,
          builder: (context, child) {
            return Text(
              widget.calling.displayNumber,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 160,
                fontWeight: FontWeight.w900,
                color: AppTheme.textPrimary,
                letterSpacing: -6,
                height: 1,
                shadows: [
                  Shadow(
                    color: AppTheme.gold
                        .withValues(alpha: 0.15 + _glowAnim.value * 0.25),
                    blurRadius: 30 + _glowAnim.value * 40,
                  ),
                  Shadow(
                    color: Colors.white
                        .withValues(alpha: 0.05 + _glowAnim.value * 0.1),
                    blurRadius: 60,
                  ),
                ],
              ),
            );
          },
        )
        .animate()
        .fadeIn(duration: 500.ms)
        .scaleXY(begin: 0.85, end: 1.0, duration: 500.ms, curve: Curves.easeOutBack),

        const SizedBox(height: 20),

        Text(
          widget.calling.customerName.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: AppTheme.textSecondary,
            letterSpacing: 4,
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms, delay: 200.ms),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.gold.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppTheme.gold.withValues(alpha: 0.25),
              width: 0.5,
            ),
          ),
          child: const Text(
            'Silakan menuju Loket 1',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.gold,
              letterSpacing: 0.5,
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms, delay: 300.ms),
      ],
    );
  }
}

// ── Idle Display ──────────────────────────────────────────────────────────────

class _IdleDisplay extends StatelessWidget {
  const _IdleDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '—',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 160,
            fontWeight: FontWeight.w100,
            color: AppTheme.textMuted,
            height: 1,
          ),
        ),
        SizedBox(height: 24),
        Text(
          'Menunggu Antrian',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w300,
            color: AppTheme.textMuted,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }
}
