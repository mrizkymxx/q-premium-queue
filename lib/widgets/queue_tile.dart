import 'package:flutter/material.dart';
import '../models/queue_transaction.dart';

class QueueTile extends StatelessWidget {
  final int? queueNumber;
  final String? queuePrefix;
  final String? customerName;
  final QueueStatus? status;
  final bool isCurrent;

  const QueueTile({
    super.key,
    this.queueNumber,
    this.queuePrefix,
    this.customerName,
    this.status,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayNumber =
        '${queuePrefix ?? 'A'}-${queueNumber?.toString().padLeft(3, '0') ?? '---'}';

    final statusLabels = {
      QueueStatus.waiting: 'Menunggu',
      QueueStatus.calling: 'Dipanggil',
      QueueStatus.completed: 'Selesai',
      QueueStatus.skipped: 'Dilewati',
    };

    final effectiveStatus = status ?? QueueStatus.waiting;

    Color statusColor;
    switch (effectiveStatus) {
      case QueueStatus.waiting:
        statusColor = const Color(0xFFEAB308);
      case QueueStatus.calling:
        statusColor = const Color(0xFF22C55E);
      case QueueStatus.completed:
        statusColor = const Color(0xFF9CA3AF);
      case QueueStatus.skipped:
        statusColor = const Color(0xFF6B7280);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isCurrent
            ? const Color(0xFF22C55E).withValues(alpha: 0.1)
            : Colors.white,
        border: isCurrent
            ? Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.3))
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              displayNumber,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                customerName ?? '',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              statusLabels[effectiveStatus] ?? '',
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
