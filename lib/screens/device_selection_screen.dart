import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme_config.dart';

class DeviceSelectionScreen extends StatelessWidget {
  const DeviceSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo / Title
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.gold.withValues(alpha: 0.1),
                  border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.settings_suggest, size: 36, color: AppTheme.gold),
              ).animate().fadeIn(duration: 500.ms).scaleXY(begin: 0.8),
              
              const SizedBox(height: 24),
              Text(
                'Setup Perangkat',
                style: AppTheme.headlineLarge(),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 8),
              Text(
                'Pilih peran untuk layar atau perangkat ini.',
                style: AppTheme.bodyMedium(),
              ).animate().fadeIn(delay: 200.ms),
              
              const SizedBox(height: 48),
              
              Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: const [
                  _DeviceCard(
                    title: 'Kiosk Pendaftaran',
                    description: 'Layar mandiri bagi pengunjung untuk mengambil nomor antrian.',
                    icon: Icons.confirmation_number_outlined,
                    route: '/register',
                    delay: 300,
                  ),
                  _DeviceCard(
                    title: 'Dashboard Operator',
                    description: 'Untuk petugas loket dalam memanggil dan mengelola antrian.',
                    icon: Icons.computer_outlined,
                    route: '/dashboard',
                    delay: 400,
                  ),
                  _DeviceCard(
                    title: 'Layar Monitor',
                    description: 'Tampilan TV ruang tunggu dengan panggilan suara (TTS).',
                    icon: Icons.tv_outlined,
                    route: '/monitor',
                    delay: 500,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeviceCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final String route;
  final int delay;

  const _DeviceCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    required this.delay,
  });

  @override
  State<_DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<_DeviceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(widget.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          width: 320,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: _isHovered ? AppTheme.surfaceColor : AppTheme.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isHovered ? AppTheme.gold : AppTheme.borderColor,
              width: _isHovered ? 1.5 : 1.0,
            ),
            boxShadow: _isHovered ? AppTheme.goldGlow(intensity: 0.4) : AppTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(widget.icon, color: AppTheme.gold, size: 36),
              ),
              const SizedBox(height: 24),
              Text(
                widget.title,
                style: AppTheme.titleLarge(),
              ),
              const SizedBox(height: 12),
              Text(
                widget.description,
                style: AppTheme.bodyMedium(),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Text(
                    'Pilih Peran',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _isHovered ? AppTheme.gold : AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: _isHovered ? AppTheme.gold : AppTheme.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms, delay: widget.delay.ms).slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOut),
      ),
    );
  }
}
