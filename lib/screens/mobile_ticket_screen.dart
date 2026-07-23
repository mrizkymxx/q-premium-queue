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
      context.read<QueueProvider>().startRealtimeSubscription();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Column(
        children: [
          const GlassNavBar(title: 'Tiket Antrian Digital'),
          Expanded(
            child: Consumer<QueueProvider>(
              builder: (context, provider, child) {
                // Find the ticket
                final ticketIndex = provider.transactions.indexWhere((t) => t.id == widget.ticketId);
                
                if (ticketIndex == -1) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.gold),
                  );
                }

                final ticket = provider.transactions[ticketIndex];
                
                // Calculate queue ahead
                int queueAhead = 0;
                if (ticket.status == QueueStatus.waiting) {
                  queueAhead = provider.waitingList.indexWhere((t) => t.id == ticket.id);
                  if (queueAhead == -1) queueAhead = 0; // fallback
                }

                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _MobileTicketCard(
                      ticket: ticket,
                      queueAhead: queueAhead,
                    ),
                  ),
                );
              },
            ),
          ),
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

    if (ticket.status == QueueStatus.completed) {
      statusMessage = 'SELESAI DILAYANI';
      statusColor = AppTheme.success;
    } else if (ticket.status == QueueStatus.skipped) {
      statusMessage = 'NOMOR DILEWATI';
      statusColor = AppTheme.danger;
    } else if (ticket.status == QueueStatus.calling) {
      statusMessage = 'GILIRAN ANDA SEKARANG!';
      statusColor = AppTheme.gold;
    } else {
      if (queueAhead == 0) {
        statusMessage = 'GILIRAN ANDA BERIKUTNYA';
        statusColor = AppTheme.goldLight;
      } else {
        statusMessage = '$queueAhead ANTRIAN DI DEPAN ANDA';
        statusColor = AppTheme.textSecondary;
      }
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
                ).animate(target: ticket.status == QueueStatus.calling ? 1 : 0)
                 .shimmer(duration: 2.seconds, color: AppTheme.textPrimary.withValues(alpha: 0.3)),
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
