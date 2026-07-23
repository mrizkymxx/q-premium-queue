import 'dart:ui' show Color;

/// The lifecycle states a queue entry can be in.
enum QueueStatus {
  waiting,
  calling,
  completed,
  skipped,
}

/// Represents a single transaction / ticket in the queue system.
class QueueTransaction {
  final String id;
  final DateTime createdAt;
  final String customerName;
  final int queueNumber;
  final String queuePrefix;
  final QueueStatus status;
  final DateTime? calledAt;
  final DateTime? completedAt;
  final String source;

  QueueTransaction({
    required this.id,
    required this.createdAt,
    required this.customerName,
    required this.queueNumber,
    this.queuePrefix = 'A',
    required this.status,
    this.calledAt,
    this.completedAt,
    this.source = 'web',
  });

  /// Creates a [QueueTransaction] from a Supabase / JSON response map.
  factory QueueTransaction.fromJson(Map<String, dynamic> json) {
    return QueueTransaction(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      customerName: json['customer_name'] as String,
      queueNumber: json['queue_number'] as int,
      queuePrefix: json['queue_prefix'] as String? ?? 'A',
      status: QueueStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => QueueStatus.waiting,
      ),
      calledAt: json['called_at'] != null
          ? DateTime.parse(json['called_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      source: json['source'] as String? ?? 'web',
    );
  }

  /// Serializes this instance to a JSON-compatible map (snake_case keys).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'customer_name': customerName,
      'queue_number': queueNumber,
      'queue_prefix': queuePrefix,
      'status': status.name,
      'called_at': calledAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'source': source,
    };
  }

  /// Human-readable ticket identifier with zero-padding, e.g. "A-042".
  String get displayNumber =>
      '$queuePrefix-${queueNumber.toString().padLeft(3, '0')}';

  /// Semantic color associated with the current [status].
  Color get statusColor {
    switch (status) {
      case QueueStatus.waiting:
        return const Color(0xFFFFD60A);
      case QueueStatus.calling:
        return const Color(0xFF30D158);
      case QueueStatus.completed:
        return const Color(0xFF8E8E93);
      case QueueStatus.skipped:
        return const Color(0xFF48484A);
    }
  }
}
