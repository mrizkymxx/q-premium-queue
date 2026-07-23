import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'config/supabase_config.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id', null);
  await SupabaseConfig.initialize();
  runApp(const QPremiumApp());
}
