import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'config/supabase_config.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    usePathUrlStrategy();
    await initializeDateFormatting('id', null);
    await SupabaseConfig.initialize();
    runApp(const QPremiumApp());
  } catch (e, stackTrace) {
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Text(
              "FATAL ERROR ON STARTUP:\n$e\n\n$stackTrace",
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ),
      ),
    ));
  }
}
