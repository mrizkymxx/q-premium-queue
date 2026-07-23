import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:q_premium/config/supabase_config.dart';
import 'package:q_premium/models/queue_transaction.dart';

/// Manages queue state and exposes a reactive API for the UI layer.
///
/// Listens to realtime changes from the `queue_transactions` table via a
/// Supabase stream subscription and provides convenient mutation methods
/// (register, call next, complete, skip).
///
/// ## State
///
/// | Getter         | Type                        | Description                              |
/// |----------------|-----------------------------|------------------------------------------|
/// | `transactions` | `List<QueueTransaction>`    | All transactions visible to the stream.  |
/// | `currentCalling` | `QueueTransaction?`      | The single entry being called, if any.   |
/// | `waitingList`  | `List<QueueTransaction>`    | Subset of `transactions` with `waiting`. |
/// | `canCallNext`  | `bool`                      | `true` when **no** entry is `calling`.   |
/// | `isLoading`    | `bool`                      | `true` during register / call-next.      |
/// | `error`        | `String?`                   | Last error message, cleared on success.  |
class QueueProvider extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // Fields
  // ---------------------------------------------------------------------------

  List<QueueTransaction> _transactions = [];
  QueueTransaction? _currentCalling;
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;
  bool _isLoading = false;
  String? _error;

  // ---------------------------------------------------------------------------
  // Public getters
  // ---------------------------------------------------------------------------

  List<QueueTransaction> get transactions => List.unmodifiable(_transactions);
  QueueTransaction? get currentCalling => _currentCalling;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Returns only the entries that are still waiting.
  List<QueueTransaction> get waitingList =>
      _transactions.where((t) => t.status == QueueStatus.waiting).toList();

  /// Whether a new customer can be called right now.
  ///
  /// This is `true` when **every** entry has a status other than `calling`.
  /// When someone is already being called, the front-desk should not summon
  /// another until the current one is completed or skipped.
  bool get canCallNext =>
      _transactions.every((t) => t.status != QueueStatus.calling);

  // ---------------------------------------------------------------------------
  // Realtime subscription
  // ---------------------------------------------------------------------------

  /// Starts (or restarts) the realtime subscription.
  ///
  /// The stream emits the full current data set immediately upon
  /// subscription, then reflects any INSERT / UPDATE / DELETE in
  /// near-real-time.  On every emission:
  ///
  ///  1. `_transactions` is replaced with deserialised entries.
  ///  2. `_currentCalling` is derived from the local list (no extra RPC).
  ///  3. `_error` is cleared.
  ///  4. Listeners are notified.
  ///
  /// If the stream encounters an error, `_error` is set and listeners
  /// are notified.  The subscription stays alive and may recover on the
  /// next emission.
  void startRealtimeSubscription() {
    _subscription?.cancel();

    _subscription = SupabaseConfig.client
        .from('queue_transactions')
        .stream(primaryKey: ['id'])
        .order('queue_number', ascending: true)
        .listen(
          _onStreamData,
          onError: _onStreamError,
        );
  }

  void _onStreamData(List<Map<String, dynamic>> data) {
    _transactions = data
        .map((json) => QueueTransaction.fromJson(json))
        .toList();

    _currentCalling = _resolveCurrentCalling();
    _error = null;
    notifyListeners();
  }

  void _onStreamError(Object error) {
    _error = error.toString();
    notifyListeners();
  }

  /// Returns the single transaction with `calling` status, or `null`.
  QueueTransaction? _resolveCurrentCalling() {
    for (final t in _transactions) {
      if (t.status == QueueStatus.calling) return t;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Mutations
  // ---------------------------------------------------------------------------

  /// Registers a new customer in the queue.
  ///
  /// The [name] is sent to the `queue_transactions` table.  The
  /// `queue_number` is auto-assigned by a database trigger.
  ///
  /// Returns the created [QueueTransaction] on success, or `null` on
  /// failure (in which case [error] is populated).
  ///
  /// Sets [isLoading] to `true` for the duration of the request.
  Future<QueueTransaction?> registerQueue(String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await SupabaseConfig.client
          .from('queue_transactions')
          .insert({'customer_name': name})
          .select();

      final List<dynamic> raw = response as List<dynamic>;
      if (raw.isEmpty) {
        _error = 'No data returned after insert.';
        return null;
      }

      return QueueTransaction.fromJson(raw.first as Map<String, dynamic>);
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Calls the next waiting customer to the counter.
  ///
  /// **Precondition:** [canCallNext] must be `true` (no one else is
  /// currently being called).  If the precondition is not met, `null` is
  /// returned immediately and [error] is set.
  ///
  /// Finds the waiting entry with the lowest [queueNumber], updates its
  /// `status` to `calling` and its `called_at` to the current server
  /// moment, then returns the updated [QueueTransaction].
  ///
  /// Sets [isLoading] to `true` for the duration of the request.
  Future<QueueTransaction?> callNext() async {
    if (!canCallNext) {
      _error = 'Cannot call next — another customer is currently being served.';
      notifyListeners();
      return null;
    }

    final waitingEntries =
        _transactions.where((t) => t.status == QueueStatus.waiting);

    if (waitingEntries.isEmpty) {
      _error = 'No waiting customers to call.';
      notifyListeners();
      return null;
    }

    // Find the entry with the lowest queue number.
    QueueTransaction firstWaiting = waitingEntries.first;
    for (final t in waitingEntries) {
      if (t.queueNumber < firstWaiting.queueNumber) {
        firstWaiting = t;
      }
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await SupabaseConfig.client
          .from('queue_transactions')
          .update({
            'status': 'calling',
            'called_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', firstWaiting.id)
          .select();

      final List<dynamic> raw = response as List<dynamic>;
      if (raw.isEmpty) {
        _error = 'No data returned after update.';
        return null;
      }

      return QueueTransaction.fromJson(raw.first as Map<String, dynamic>);
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Completes the currently called transaction identified by [id].
  ///
  /// Sets `status` to `completed` and `completed_at` to the current
  /// server moment via the database trigger.  Errors are silently
  /// captured into [error].
  Future<void> completeCurrent(String id) async {
    _error = null;
    try {
      await SupabaseConfig.client
          .from('queue_transactions')
          .update({
            'status': 'completed',
            'completed_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  /// Skips the currently called transaction identified by [id].
  ///
  /// Sets `status` to `skipped`.  No timestamp is recorded.  Errors
  /// are silently captured into [error].
  Future<void> skipCurrent(String id) async {
    _error = null;
    try {
      await SupabaseConfig.client
          .from('queue_transactions')
          .update({'status': 'skipped'})
          .eq('id', id);
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
