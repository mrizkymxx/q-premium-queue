import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/theme_config.dart';
import '../models/queue_transaction.dart';
import '../providers/queue_provider.dart';
import '../widgets/glass_nav_bar.dart';
import '../utils/date_helper.dart';

class MobileTicketScreen extends StatefulWidget {
  final String ticketId;

  const MobileTicketScreen({super.key, required this.ticketId});

  @override
  State<MobileTicketScreen> createState() => _MobileTicketScreenState();
}

class _MobileTicketScreenState extends State<MobileTicketScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QueueProvider>().syncData();
      context.read<QueueProvider>().startRealtimeSubscription();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Consumer<QueueProvider>(
        builder: (context, provider, child) {
          final ticketIndex = provider.transactions.indexWhere((t) => t.id == widget.ticketId);
          
          if (ticketIndex == -1) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.gold),
            );
          }

          final ticket = provider.transactions[ticketIndex];
          
          if (ticket.status == QueueStatus.calling) {
            return _buildCallingState(ticket);
          } else if (ticket.status == QueueStatus.completed) {
            return _buildCompletedState();
          } else if (ticket.status == QueueStatus.skipped) {
            return _buildSkippedState();
          }

          int queueAhead = provider.waitingList.indexWhere((t) => t.id == ticket.id);
          if (queueAhead == -1) queueAhead = 0;

          return Column(
            children: [
              const GlassNavBar(title: 'Tiket Antrian Digital'),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _MobileTicketCard(
                      ticket: ticket,
                      queueAhead: queueAhead,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCallingState(QueueTransaction ticket) {
    return Container(
      width: double.infinity,
      color: AppTheme.gold.withValues(alpha: 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.notifications_active,
            size: 120,
            color: AppTheme.gold,
          )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scaleXY(begin: 0.9, end: 1.1, duration: 600.ms)
          .shake(hz: 3, duration: 600.ms),
          
          const SizedBox(height: 40),
          
          Text(
            'GILIRAN ANDA!',
            style: AppTheme.headlineLarge(color: AppTheme.gold),
          ).animate().fadeIn().slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 16),
          
          Text(
            'Nomor: ${ticket.displayNumber}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
            ),
          ).animate().fadeIn(delay: 200.ms).scaleXY(begin: 0.8, end: 1),
          
          const SizedBox(height: 32),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Text(
              'Silakan segera menuju ke Loket Pelayanan',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildCompletedState() {
    return Container(
      width: double.infinity,
      color: AppTheme.darkBg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.success.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 80,
              color: AppTheme.success,
            ),
          ).animate().scaleXY(begin: 0, end: 1, duration: 600.ms, curve: Curves.easeOutBack),
          
          const SizedBox(height: 32),
          
          Text(
            'Pelayanan Selesai',
            style: AppTheme.headlineMedium(color: AppTheme.success),
          ).animate().fadeIn(delay: 300.ms),
          
          const SizedBox(height: 16),
          
          const Text(
            'Terima kasih telah berkunjung\ndan menggunakan layanan kami.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }

  Widget _buildSkippedState() {
    return Container(
      width: double.infinity,
      color: AppTheme.darkBg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.danger.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.cancel_outlined,
              size: 80,
              color: AppTheme.danger,
            ),
          ).animate().scaleXY(begin: 0, end: 1, duration: 600.ms, curve: Curves.easeOutBack),
          
          const SizedBox(height: 32),
          
          Text(
            'Antrian Terlewati',
            style: AppTheme.headlineMedium(color: AppTheme.danger),
          ).animate().fadeIn(delay: 300.ms),
          
          const SizedBox(height: 16),
          
          const Text(
            'Mohon maaf, giliran Anda telah terlewat.\nSilakan mengambil nomor antrian baru.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }
}

class _MobileTicketCard extends StatelessWidget {
  final QueueTransaction ticket;
  final int queueAhead;

  const _MobileTicketCard({
    required this.ticket,
    required this.queueAhead,
  });

  @override
  Widget build(BuildContext context) {
    String statusMessage;
    Color statusColor;

    if (queueAhead == 0) {
      statusMessage = 'GILIRAN ANDA BERIKUTNYA';
      statusColor = AppTheme.goldLight;
    } else {
      statusMessage = '$queueAhead ANTRIAN DI DEPAN ANDA';
      statusColor = AppTheme.textSecondary;
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: AppTheme.darkCardGradient,
              border: Border.all(
                color: statusColor.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.15),
                  blurRadius: 30,
                  spreadRadius: 0,
                )
              ],
            ),
            child: Column(
              children: [
                // Header strip
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(23)),
                    color: statusColor.withValues(alpha: 0.1),
                    border: Border(
                      bottom: BorderSide(
                        color: statusColor.withValues(alpha: 0.2),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.circle, size: 8, color: statusColor),
                      const SizedBox(width: 8),
                      Text(
                        'LIVE TRACKING',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),

                // Ticket number
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    children: [
                      Text(
                        ticket.displayNumber,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 80,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                          letterSpacing: -3,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppTheme.gold.withValues(alpha: 0.4),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        ticket.customerName.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Terdaftar: ${formatDateTime(ticket.createdAt)}',
                        style: AppTheme.bodyMedium(),
                      ),
                    ],
                  ),
                ),

                // Alert Box
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    statusMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          )
          .animate()
          .fadeIn(duration: 500.ms)
          .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }
}
