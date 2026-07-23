import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';

/// Native platform implementation of [TTSHelper].
///
/// Uses [flutter_tts] to announce queue numbers in Indonesian.
/// This file is used on Android, iOS, Windows, macOS, etc.
class TTSHelper {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isInitialized = false;

  static Future<void> _initTts() async {
    if (_isInitialized) return;
    await _flutterTts.setLanguage("id-ID");
    await _flutterTts.setSpeechRate(0.85); // Adjust rate to match web
    await _flutterTts.setVolume(1.0);
    _isInitialized = true;
  }

  /// Announces [queueNumber] with the given [prefix] at [counter].
  /// Repeats 3 times to match the web behavior.
  static Future<void> announce(String prefix, int queueNumber, {int counter = 1}) async {
    await _initTts();
    final text = 'Nomor $prefix-$queueNumber silakan menuju loket $counter';

    _flutterTts.speak(text);

    Future.delayed(const Duration(seconds: 4), () {
      _flutterTts.speak(text);
    });
    Future.delayed(const Duration(seconds: 8), () {
      _flutterTts.speak(text);
    });
  }

  /// Immediately cancels any queued or in-progress speech.
  static void cancel() {
    _flutterTts.stop();
  }
}
