import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/theme_config.dart';
import '../providers/queue_provider.dart';
import '../widgets/glass_nav_bar.dart';
import '../widgets/calling_card.dart';
import '../widgets/haptic_button.dart';
import '../widgets/queue_tile.dart';
import '../widgets/stat_chip.dart';
import 'public_monitor_screen.dart';
import 'registration_screen.dart';

class OperatorDashboardScreen extends StatefulWidget {
  const OperatorDashboardScreen({super.key});

  @override
  State<OperatorDashboardScreen> createState() =>
      _OperatorDashboardScreenState();
}

class _OperatorDashboardScreenState extends State<OperatorDashboardScreen> {
  bool _confirmSkip = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QueueProvider>().startRealtimeSubscription();
    });
  }

  void _navigateToMonitor() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PublicMonitorScreen()),
    );
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegistrationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Consumer<QueueProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              GlassNavBar(
                title: 'Q-PREMIUM',
                actions: [
                  NavBarIconButton(
                    icon: Icons.tv_outlined,
                    tooltip: 'Layar Monitor',
                    onPressed: _navigateToMonitor,
                  ),
                  NavBarIconButton(
                    icon: Icons.person_add_outlined,
                    tooltip: 'Daftarkan Antrian',
                    onPressed: _navigateToRegister,
                  ),
                ],
              ),
              if (provider.error != null)
                _ErrorBanner(message: provider.error!),
              Expanded(
                child: provider.isLoading &&
                        provider.currentCalling == null &&
                        provider.waitingList.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.gold,
                          strokeWidth: 2,
                        ),
                      )
                    : _buildContent(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(QueueProvider provider) {
    return CustomScrollView(
      slivers: [
        // Stats Row
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                final todayChip = StatChip(
                  label: 'Hari Ini',
                  value: '${provider.totalToday}',
                  icon: Icons.calendar_today_outlined,
                  accentColor: AppTheme.gold,
                );
                final waitChip = StatChip(
                  label: 'Menunggu',
                  value: '${provider.waitingList.length}',
                  icon: Icons.hourglass_empty_outlined,
                  accentColor: AppTheme.warning,
                );
                final servedChip = StatChip(
                  label: 'Selesai',
                  value: '${provider.servedToday}',
                  icon: Icons.check_circle_outline,
                  accentColor: AppTheme.success,
                );

                if (isMobile) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: todayChip),
                          const SizedBox(width: 10),
                          Expanded(child: waitChip),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: servedChip),
                        ],
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: todayChip),
                    const SizedBox(width: 10),
                    Expanded(child: waitChip),
                    const SizedBox(width: 10),
                    Expanded(child: servedChip),
                  ],
                );
              },
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 100.ms)
            .slideY(begin: 0.15, end: 0, duration: 400.ms, delay: 100.ms),
          ),
        ),

        // Calling Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: CallingCard(
              queueNumber: provider.currentCalling?.queueNumber,
              queuePrefix: provider.currentCalling?.queuePrefix,
              customerName: provider.currentCalling?.customerName,
            ),
          )
          .animate()
          .fadeIn(duration: 400.ms, delay: 200.ms)
          .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 200.ms),
        ),

        // Action Buttons
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _buildActionButtons(provider),
          )
          .animate()
          .fadeIn(duration: 400.ms, delay: 300.ms),
        ),

        // Waiting List Section
        if (provider.waitingList.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppTheme.gold,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Daftar Tunggu',
                    style: AppTheme.titleMedium(),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${provider.waitingList.length}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.gold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final t = provider.waitingList[index];
                return QueueTile(
                  queueNumber: t.queueNumber,
                  queuePrefix: t.queuePrefix,
                  customerName: t.customerName,
                  status: t.status,
                )
                .animate()
                .fadeIn(
                  delay: Duration(milliseconds: 350 + index * 50),
                  duration: 300.ms,
                )
                .slideX(
                  begin: 0.05,
                  end: 0,
                  delay: Duration(milliseconds: 350 + index * 50),
                  duration: 300.ms,
                );
              },
              childCount: provider.waitingList.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],

        // Empty state
        if (provider.waitingList.isEmpty && provider.currentCalling == null)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inbox_outlined,
                    size: 48,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Antrian Kosong',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pelanggan dapat mendaftar melalui\nlayar Registrasi.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppTheme.textMuted,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
              .animate()
              .fadeIn(duration: 500.ms, delay: 400.ms),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(QueueProvider provider) {
    final hasCalling = provider.currentCalling != null;
    final canCall = provider.canCallNext && provider.waitingList.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        final skipBtn = HapticButton(
          label: _confirmSkip ? 'Yakin Lewati?' : 'Lewati',
          icon: _confirmSkip ? Icons.warning_outlined : Icons.skip_next,
          variant: ButtonVariant.ghost,
          onPressed: () {
            if (!_confirmSkip) {
              setState(() => _confirmSkip = true);
              Future.delayed(const Duration(seconds: 3), () {
                if (mounted) setState(() => _confirmSkip = false);
              });
            } else {
              provider.skipCurrent(provider.currentCalling!.id);
              setState(() => _confirmSkip = false);
            }
          },
        );

        final completeBtn = HapticButton(
          label: 'Selesai',
          icon: Icons.check_rounded,
          variant: ButtonVariant.success,
          onPressed: () =>
              provider.completeCurrent(provider.currentCalling!.id),
        );

        final callBtn = HapticButton(
          label: 'Panggil Berikutnya',
          icon: Icons.play_arrow_rounded,
          variant: ButtonVariant.primary,
          size: ButtonSize.large,
          isLoading: provider.isLoading,
          onPressed: canCall ? () => provider.callNext() : null,
        );

        if (isMobile && hasCalling) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: skipBtn),
                  const SizedBox(width: 10),
                  Expanded(child: completeBtn),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: callBtn,
              ),
            ],
          );
        }

        return Row(
          children: [
            if (hasCalling) ...[
              Expanded(child: skipBtn),
              const SizedBox(width: 10),
              Expanded(child: completeBtn),
              const SizedBox(width: 10),
            ],
            Expanded(
              flex: hasCalling ? 2 : 1,
              child: callBtn,
            ),
          ],
        );
      },
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppTheme.dangerDim,
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.danger, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppTheme.danger,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
