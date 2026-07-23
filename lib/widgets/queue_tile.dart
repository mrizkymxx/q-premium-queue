import 'package:flutter/material.dart';
import '../config/theme_config.dart';
import '../models/queue_transaction.dart';

/// Premium dark queue tile with status chip and consistent number format.
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
    final effectiveStatus = status ?? QueueStatus.waiting;

    final (statusLabel, statusColor, statusBg) = switch (effectiveStatus) {
      QueueStatus.waiting =>
        ('Menunggu', AppTheme.warning, AppTheme.warningDim),
      QueueStatus.calling =>
        ('Dipanggil', AppTheme.success, AppTheme.successDim),
      QueueStatus.completed =>
        ('Selesai', AppTheme.textSecondary, AppTheme.cardColor),
      QueueStatus.skipped =>
        ('Dilewati', AppTheme.textMuted, AppTheme.surfaceColor),
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isCurrent ? AppTheme.successDim : AppTheme.cardColor,
        border: Border.all(
          color: isCurrent
              ? AppTheme.success.withValues(alpha: 0.3)
              : AppTheme.borderColor,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: effectiveStatus == QueueStatus.waiting ||
                      effectiveStatus == QueueStatus.calling
                  ? [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.4),
                        blurRadius: 6,
                      )
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          Text(
            displayNumber,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              customerName ?? '',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppTheme.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
