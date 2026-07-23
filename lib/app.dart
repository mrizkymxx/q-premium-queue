import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme_config.dart';
import 'providers/queue_provider.dart';
import 'screens/login_screen.dart';
import 'screens/operator_dashboard_screen.dart';
import 'screens/public_monitor_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/mobile_registration_screen.dart';
import 'screens/mobile_ticket_screen.dart';

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
        home: const LoginScreen(),
        routes: {
          '/dashboard': (_) => const OperatorDashboardScreen(),
          '/monitor': (_) => const PublicMonitorScreen(),
          '/register': (_) => const RegistrationScreen(),
        },
        onGenerateRoute: (settings) {
          final uri = Uri.parse(settings.name ?? '');
          
          if (uri.path == '/mobile-register') {
            return MaterialPageRoute(
              builder: (_) => const MobileRegistrationScreen(),
            );
          }
          
          if (uri.path == '/ticket') {
            final id = uri.queryParameters['id'] ?? '';
            return MaterialPageRoute(
              builder: (_) => MobileTicketScreen(ticketId: id),
            );
          }
          
          return null;
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
