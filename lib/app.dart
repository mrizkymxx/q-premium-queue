import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme_config.dart';
import 'providers/queue_provider.dart';
import 'screens/device_selection_screen.dart';
import 'screens/operator_dashboard_screen.dart';
import 'screens/public_monitor_screen.dart';
import 'screens/registration_screen.dart';

class QPremiumApp extends StatelessWidget {
  const QPremiumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QueueProvider()),
      ],
      child: MaterialApp(
        title: 'Q-PREMIUM — Sistem Antrian Digital',
        theme: AppTheme.materialTheme,
        home: const DeviceSelectionScreen(),
        routes: {
          '/dashboard': (_) => const OperatorDashboardScreen(),
          '/monitor': (_) => const PublicMonitorScreen(),
          '/register': (_) => const RegistrationScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
