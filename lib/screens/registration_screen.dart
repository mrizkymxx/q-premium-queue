import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../config/theme_config.dart';
import '../widgets/glass_nav_bar.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  Timer? _timer;
  late String _qrUrl;

  @override
  void initState() {
    super.initState();
    _updateQrCode();
    // Update QR code every 15 seconds
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      _updateQrCode();
    });
  }

  void _updateQrCode() {
    setState(() {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _qrUrl = '${Uri.base.origin}/mobile-register?t=$timestamp';
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Column(
        children: [
          GlassNavBar(
            title: 'Kiosk Pendaftaran',
            leading: Navigator.canPop(context)
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        color: AppTheme.textSecondary, size: 18),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                : null,
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'AMBIL ANTRIAN',
                      style: AppTheme.headlineLarge(color: AppTheme.gold),
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
                    
                    const SizedBox(height: 12),
                    
                    Text(
                      'Scan QR Code di bawah ini menggunakan kamera HP Anda\nuntuk mengambil nomor antrian.',
                      textAlign: TextAlign.center,
                      style: AppTheme.bodyLarge(),
                    ).animate().fadeIn(delay: 100.ms),
                    
                    const SizedBox(height: 48),
                    
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: AppTheme.goldGlow(intensity: 0.8),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: QrImageView(
                          key: ValueKey(_qrUrl),
                          data: _qrUrl,
                          version: QrVersions.auto,
                          size: 300.0,
                          backgroundColor: Colors.white,
                          errorCorrectionLevel: QrErrorCorrectLevel.Q,
                        ),
                      ),
                    ).animate().scale(delay: 300.ms, duration: 600.ms, curve: Curves.easeOutBack),
                    
                    const SizedBox(height: 48),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.security, color: AppTheme.success, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'QR Code diamankan dan diperbarui setiap 15 detik.',
                            style: AppTheme.bodyMedium(),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 600.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
