import 'package:q_premium/config/supabase_config.dart';
import 'package:q_premium/models/queue_transaction.dart';

/// Data-access layer for queue-related Supabase queries and RPC calls.
///
/// Each method is a stateless fetch; stateful management and realtime
/// subscriptions live in [QueueProvider].
class QueueService {
  final _client = SupabaseConfig.client;

  /// Returns all queue transactions created since the start of today
  /// (local midnight), ordered by [queueNumber] ascending.
  ///
  /// Returns an empty list when today has no entries or when the
  /// query fails (exception propagates to the caller).
  Future<List<QueueTransaction>> getTodayQueue() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final response = await _client
        .from('queue_transactions')
        .select()
        .gte('created_at', todayStart.toIso8601String())
        .order('queue_number', ascending: true);

    final List<dynamic> rawList = response as List<dynamic>;
    return rawList
        .map((e) => QueueTransaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Calls the `get_queue_ahead_count` RPC to determine how many
  /// **waiting** transactions have a [queueNumber] lower than the given
  /// [targetNumber].
  ///
  /// Returns 0 when no waiting entries are ahead or when
  /// [targetNumber] is the lowest in the queue.
  Future<int> getQueueAhead(int targetNumber) async {
    final response = await _client.rpc('get_queue_ahead_count', params: {
      'target_number': targetNumber,
    });
    return response as int;
  }

  /// Calls the `get_current_calling` RPC and returns the single
  /// transaction that is currently in "calling" status, or `null` when
  /// no entry is being called.
  ///
  /// The RPC orders by `called_at DESC` and limits to 1, so this always
  /// returns the most recently called entry when multiple exist
  /// (should not happen under normal circumstances).
  Future<QueueTransaction?> getCurrentCalling() async {
    final response = await _client.rpc('get_current_calling');
    final List<dynamic> rawList = response as List<dynamic>;
    if (rawList.isEmpty) return null;
    return QueueTransaction.fromJson(rawList.first as Map<String, dynamic>);
  }
}
