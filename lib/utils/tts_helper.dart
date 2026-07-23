// Text-to-speech helper for queue announcements.
//
// On **web** this delegates to the Web Speech API via
// [tts_helper_web.dart]; on **native** platforms it is a no-op stub
// ([tts_helper_stub.dart]).
//
// ## Usage
//
// ```dart
// TTSHelper.announce('A', 42);
// TTSHelper.announce('B', 7, counter: 2);
// // later ...
// TTSHelper.cancel();
// ```
library;
export 'tts_helper_stub.dart' if (dart.library.html) 'tts_helper_web.dart';
