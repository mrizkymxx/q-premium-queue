import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/queue_transaction.dart';
import '../providers/queue_provider.dart';
import '../utils/date_helper.dart';

class PublicMonitorScreen extends StatelessWidget {
  const PublicMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Consumer<QueueProvider>(
          builder: (context, provider, _) {
            final calling = provider.currentCalling;
            final nextFive = provider.waitingList.take(5).toList();

            return Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Center(
                    child: _buildCallingDisplay(calling),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildQueuePreview(nextFive),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.08),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha:0.12),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Q-PREMIUM',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
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
                  color: Colors.white70,
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
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
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        );
      },
      child: calling != null
          ? Column(
              key: ValueKey(calling.id),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${calling.queuePrefix}-${calling.queueNumber}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 120,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Loket 1',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 24,
                  ),
                ),
              ],
            )
          : const Column(
              key: ValueKey('empty'),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '-',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 120,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Menunggu antrian',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildQueuePreview(List<QueueTransaction> nextFive) {
    if (nextFive.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(60, 0, 24, 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Antrian Selanjutnya',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          ...nextFive.map(
            (t) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                t.displayNumber,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
