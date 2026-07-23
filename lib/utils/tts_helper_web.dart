import 'dart:async';
import 'package:web/web.dart' as web;

/// Web platform implementation of [TTSHelper].
///
/// Uses the Web Speech API (window.speechSynthesis) to announce queue
/// numbers in Indonesian. This file is only compiled when targeting web.
class TTSHelper {
  /// Announces [queueNumber] with the given [prefix] at [counter].
  static void announce(String prefix, int queueNumber, {int counter = 1}) {
    final text = 'Nomor $prefix-$queueNumber silakan menuju loket $counter';
    final utterance = web.SpeechSynthesisUtterance(text)
      ..lang = 'id-ID'
      ..rate = 0.85;

    web.window.speechSynthesis.speak(utterance);

    Future.delayed(const Duration(seconds: 4), () {
      web.window.speechSynthesis.speak(utterance);
    });
    Future.delayed(const Duration(seconds: 8), () {
      web.window.speechSynthesis.speak(utterance);
    });
  }

  /// Immediately cancels any queued or in-progress speech.
  static void cancel() {
    web.window.speechSynthesis.cancel();
  }
}
