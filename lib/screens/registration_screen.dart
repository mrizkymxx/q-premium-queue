import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../config/theme_config.dart';
import '../widgets/glass_nav_bar.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Generate the URL dynamically based on the current host
    final String qrUrl = '${Uri.base.origin}/mobile-register';

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
                      child: QrImageView(
                        data: qrUrl,
                        version: QrVersions.auto,
                        size: 300.0,
                        backgroundColor: Colors.white,
                        errorCorrectionLevel: QrErrorCorrectLevel.Q,
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
                          const Icon(Icons.info_outline, color: AppTheme.textSecondary, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'Anda akan menerima tiket digital di HP Anda.',
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
