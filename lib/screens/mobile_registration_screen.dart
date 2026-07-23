import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/theme_config.dart';
import '../providers/queue_provider.dart';
import '../widgets/glass_nav_bar.dart';
import '../widgets/haptic_button.dart';

class MobileRegistrationScreen extends StatefulWidget {
  const MobileRegistrationScreen({super.key});

  @override
  State<MobileRegistrationScreen> createState() => _MobileRegistrationScreenState();
}

class _MobileRegistrationScreenState extends State<MobileRegistrationScreen> {
  final _nameController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();

    if (name.length < 2) {
      setState(() => _errorText = 'Nama minimal 2 karakter.');
      return;
    }
    if (name.length > 100) {
      setState(() => _errorText = 'Nama maksimal 100 karakter.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    final provider = context.read<QueueProvider>();
    final ticket = await provider.registerQueue(name);

    if (!mounted) return;

    if (ticket != null) {
      setState(() {
        _isSubmitting = false;
        _nameController.clear();
      });
      
      // Navigate to personal ticket screen
      Navigator.of(context).pushReplacementNamed('/ticket?id=${ticket.id}');
    } else {
      setState(() {
        _isSubmitting = false;
        _errorText = provider.error ?? 'Gagal mendaftar antrian.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Column(
        children: [
          const GlassNavBar(
            title: 'Pendaftaran Antrian',
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.gold.withValues(alpha: 0.08),
                          border: Border.all(
                            color: AppTheme.gold.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.smartphone_outlined,
                          size: 36,
                          color: AppTheme.gold,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .scaleXY(begin: 0.8, end: 1.0, duration: 500.ms, curve: Curves.easeOutBack),

                      const SizedBox(height: 28),

                      Text(
                        'Ambil Nomor Antrian',
                        style: AppTheme.headlineMedium(),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 100.ms),

                      const SizedBox(height: 6),

                      Text(
                        'Masukkan nama lengkap Anda',
                        style: AppTheme.bodyMedium(),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 150.ms),

                      const SizedBox(height: 28),

                      TextField(
                        controller: _nameController,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                        maxLength: 100,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          hintText: 'Nama lengkap Anda',
                          counterText: '',
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: AppTheme.textMuted,
                            size: 22,
                          ),
                        ),
                        onSubmitted: (_) => _submit(),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 200.ms)
                      .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: 200.ms),

                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        child: _errorText != null
                            ? Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline,
                                        color: AppTheme.danger, size: 16),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        _errorText!,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 13,
                                          color: AppTheme.danger,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 28),

                      SizedBox(
                        width: double.infinity,
                        child: HapticButton(
                          label: 'Dapatkan Tiket',
                          icon: Icons.confirmation_number_outlined,
                          variant: ButtonVariant.primary,
                          size: ButtonSize.large,
                          isLoading: _isSubmitting,
                          onPressed: _submit,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 300.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
