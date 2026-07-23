/// Stub implementation of [TTSHelper] for non-web platforms.
///
/// All calls are no-ops because the Web Speech API is not available
/// outside of a browser environment.
class TTSHelper {
  /// No-op on non-web platforms.
  static void announce(String prefix, int queueNumber, {int counter = 1}) {
    // The Web Speech API is unavailable outside the browser.
  }

  /// No-op on non-web platforms.
  static void cancel() {
    // The Web Speech API is unavailable outside the browser.
  }
}
