import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static const String _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String _supabasePublishableKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Initializes the Supabase client using environment variables
  /// `SUPABASE_URL` and `SUPABASE_ANON_KEY`.
  ///
  /// Pass these via `--dart-define` during build/run, e.g.:
  /// `flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      publishableKey: _supabasePublishableKey,
    );
  }

  /// Returns the singleton Supabase client instance.
  static SupabaseClient get client => Supabase.instance.client;
}
