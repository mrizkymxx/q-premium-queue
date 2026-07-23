import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme_config.dart';
import 'device_selection_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isError = false;
  
  final String _correctPassword = 'rizkyganteng';

  @override
  void initState() {
    super.initState();
    _checkActiveTicket();
  }

  void _checkActiveTicket() async {
    final prefs = await SharedPreferences.getInstance();
    final activeId = prefs.getString('active_ticket_id');
    if (activeId != null && mounted) {
      Navigator.of(context).pushReplacementNamed('/ticket?id=$activeId');
    }
  }

  void _handleLogin() {
    if (_passwordController.text == _correctPassword) {
      setState(() => _isError = false);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DeviceSelectionScreen()),
      );
    } else {
      setState(() => _isError = true);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: AppTheme.glassDecoration(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      size: 48,
                      color: AppTheme.gold,
                    ),
                  ).animate().scaleXY(begin: 0.8, end: 1, duration: 600.ms, curve: Curves.easeOutBack),
                  
                  const SizedBox(height: 32),
                  
                  Text(
                    'Q-PREMIUM',
                    style: AppTheme.headlineMedium(),
                  ).animate().fadeIn(delay: 200.ms),
                  
                  const SizedBox(height: 8),
                  
                  const Text(
                    'Masukkan kata sandi untuk\nmengakses Panel Operator',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  
                  const SizedBox(height: 40),
                  
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontFamily: 'Inter',
                      fontSize: 16,
                    ),
                    onSubmitted: (_) => _handleLogin(),
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi',
                      labelStyle: const TextStyle(color: AppTheme.textMuted),
                      prefixIcon: const Icon(Icons.key, color: AppTheme.gold),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _isError ? AppTheme.danger : AppTheme.gold.withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _isError ? AppTheme.danger : AppTheme.gold,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: AppTheme.surfaceColor,
                      errorText: _isError ? 'Kata sandi tidak valid' : null,
                      errorStyle: const TextStyle(color: AppTheme.danger),
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0, duration: 400.ms),
                  
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.gold,
                        foregroundColor: AppTheme.darkBg,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'MASUK',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0, duration: 400.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
