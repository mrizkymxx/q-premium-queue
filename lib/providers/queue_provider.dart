import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:q_premium/config/supabase_config.dart';
import 'package:q_premium/models/queue_transaction.dart';
import 'package:q_premium/utils/tts_helper.dart';

/// Manages queue state and exposes a reactive API for the UI layer.
///
/// Listens to realtime changes from the `queue_transactions` table via a
/// Supabase stream subscription and provides convenient mutation methods
/// (register, call next, complete, skip).
///
/// ## State
///
/// | Getter           | Type                        | Description                              |
/// |------------------|-----------------------------|------------------------------------------|
/// | `transactions`   | `List<QueueTransaction>`    | Transaksi hari ini dari realtime stream. |
/// | `currentCalling` | `QueueTransaction?`         | Satu entri dengan status `calling`.      |
/// | `waitingList`    | `List<QueueTransaction>`    | Subset `transactions` dengan `waiting`.  |
/// | `canCallNext`    | `bool`                      | `true` saat tidak ada yang `calling`.    |
/// | `isLoading`      | `bool`                      | `true` selama proses register/call-next. |
/// | `error`          | `String?`                   | Pesan error terakhir, dikosongkan saat sukses. |
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

  /// Statistik hari ini
  int get totalToday => _transactions.length;
  int get completedToday =>
      _transactions.where((t) => t.status == QueueStatus.completed).length;
  int get skippedToday =>
      _transactions.where((t) => t.status == QueueStatus.skipped).length;
  int get servedToday => completedToday + skippedToday;

  /// Hanya entri yang masih menunggu.
  List<QueueTransaction> get waitingList =>
      _transactions.where((t) => t.status == QueueStatus.waiting).toList();

  /// Apakah pelanggan berikutnya bisa dipanggil.
  bool get canCallNext =>
      _transactions.every((t) => t.status != QueueStatus.calling);

  // ---------------------------------------------------------------------------
  // Realtime subscription
  // ---------------------------------------------------------------------------

  /// Memulai (atau memulai ulang) realtime subscription.
  ///
  /// Hanya menampilkan data hari ini dengan filter client-side.
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
    // Filter hanya transaksi hari ini (mulai tengah malam lokal)
    final todayStart = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    _transactions = data
        .map((json) => QueueTransaction.fromJson(json))
        .where((t) =>
            t.createdAt.isAfter(todayStart) ||
            t.createdAt.isAtSameMomentAs(todayStart))
        .toList();

    _currentCalling = _resolveCurrentCalling();
    _error = null;
    notifyListeners();
  }

  void _onStreamError(Object error) {
    _error = 'Koneksi bermasalah: ${error.toString()}';
    notifyListeners();
  }

  QueueTransaction? _resolveCurrentCalling() {
    for (final t in _transactions) {
      if (t.status == QueueStatus.calling) return t;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Mutations
  // ---------------------------------------------------------------------------

  /// Mendaftarkan pelanggan baru ke antrian.
  ///
  /// Mengembalikan [QueueTransaction] yang dibuat, atau `null` jika gagal.
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
        _error = 'Tidak ada data yang dikembalikan setelah pendaftaran.';
        return null;
      }

      return QueueTransaction.fromJson(raw.first as Map<String, dynamic>);
    } catch (e) {
      _error = 'Gagal mendaftar: ${e.toString()}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Memanggil pelanggan berikutnya yang sedang menunggu ke loket.
  ///
  /// Juga memicu pengumuman suara (TTS) setelah berhasil.
  Future<QueueTransaction?> callNext() async {
    if (!canCallNext) {
      _error = 'Tidak dapat memanggil — masih ada pelanggan yang sedang dilayani.';
      notifyListeners();
      return null;
    }

    final waitingEntries =
        _transactions.where((t) => t.status == QueueStatus.waiting);

    if (waitingEntries.isEmpty) {
      _error = 'Tidak ada antrian yang menunggu.';
      notifyListeners();
      return null;
    }

    // Cari entri dengan nomor antrian terkecil.
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
        _error = 'Tidak ada data yang dikembalikan setelah update.';
        return null;
      }

      final called =
          QueueTransaction.fromJson(raw.first as Map<String, dynamic>);

      // Umumkan melalui Text-to-Speech
      TTSHelper.announce(called.queuePrefix, called.queueNumber, counter: 1);

      return called;
    } catch (e) {
      _error = 'Gagal memanggil antrian: ${e.toString()}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Menyelesaikan transaksi yang sedang dipanggil.
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
      TTSHelper.cancel();
    } catch (e) {
      _error = 'Gagal menyelesaikan antrian: ${e.toString()}';
    }
    notifyListeners();
  }

  /// Melewati transaksi yang sedang dipanggil.
  Future<void> skipCurrent(String id) async {
    _error = null;
    try {
      await SupabaseConfig.client
          .from('queue_transactions')
          .update({'status': 'skipped'})
          .eq('id', id);
      TTSHelper.cancel();
    } catch (e) {
      _error = 'Gagal melewati antrian: ${e.toString()}';
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
