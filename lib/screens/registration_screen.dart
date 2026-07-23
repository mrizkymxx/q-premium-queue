import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/theme_config.dart';
import '../models/queue_transaction.dart';
import '../providers/queue_provider.dart';
import '../services/queue_service.dart';
import '../widgets/glass_nav_bar.dart';
import '../widgets/haptic_button.dart';
import '../utils/date_helper.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _nameController = TextEditingController();
  final _queueService = QueueService();

  QueueTransaction? _lastTicket;
  int _queueAhead = 0;
  int _countdown = 12;
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
      int ahead = 0;
      try {
        ahead = await _queueService.getQueueAhead(ticket.queueNumber);
      } catch (_) {}

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        _lastTicket = ticket;
        _queueAhead = ahead;
        _nameController.clear();
        _countdown = 12;
      });

      _startCountdown();
    } else {
      setState(() {
        _isSubmitting = false;
        _errorText = provider.error ?? 'Gagal mendaftar antrian.';
      });
    }
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _countdown--);
      if (_countdown <= 0) {
        if (mounted) {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          } else {
            setState(() {
              _lastTicket = null;
              _countdown = 12;
            });
          }
        }
        return false;
      }
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Column(
        children: [
          GlassNavBar(
            title: _lastTicket != null ? 'Tiket Anda' : 'Ambil Antrian',
            leading: _lastTicket == null && Navigator.canPop(context)
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
                padding: const EdgeInsets.all(24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: _lastTicket != null
                      ? _TicketCard(
                          key: ValueKey(_lastTicket!.id),
                          ticket: _lastTicket!,
                          queueAhead: _queueAhead,
                          countdown: _countdown,
                        )
                      : _RegistrationForm(
                          key: const ValueKey('form'),
                          controller: _nameController,
                          errorText: _errorText,
                          isSubmitting: _isSubmitting,
                          onSubmit: _submit,
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

// ── Registration Form ─────────────────────────────────────────────────────────

class _RegistrationForm extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const _RegistrationForm({
    super.key,
    required this.controller,
    this.errorText,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
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
              Icons.confirmation_number_outlined,
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
            controller: controller,
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
            onSubmitted: (_) => onSubmit(),
          )
          .animate()
          .fadeIn(duration: 400.ms, delay: 200.ms)
          .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: 200.ms),

          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: errorText != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppTheme.danger, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          errorText!,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: AppTheme.danger,
                            fontWeight: FontWeight.w500,
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
              label: 'Ambil Antrian',
              icon: Icons.arrow_forward_rounded,
              variant: ButtonVariant.primary,
              size: ButtonSize.large,
              isLoading: isSubmitting,
              onPressed: onSubmit,
            ),
          )
          .animate()
          .fadeIn(duration: 400.ms, delay: 300.ms),
        ],
      ),
    );
  }
}

// ── Ticket Card ───────────────────────────────────────────────────────────────

class _TicketCard extends StatelessWidget {
  final QueueTransaction ticket;
  final int queueAhead;
  final int countdown;

  const _TicketCard({
    super.key,
    required this.ticket,
    required this.queueAhead,
    required this.countdown,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: AppTheme.darkCardGradient,
              border: Border.all(
                color: AppTheme.gold.withValues(alpha: 0.4),
                width: 1,
              ),
              boxShadow: AppTheme.goldGlow(intensity: 0.8),
            ),
            child: Column(
              children: [
                // Header strip
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 18),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(23)),
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.gold.withValues(alpha: 0.12),
                        AppTheme.gold.withValues(alpha: 0.04),
                      ],
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: AppTheme.gold.withValues(alpha: 0.2),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppTheme.gold,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Q-PREMIUM',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.gold,
                          letterSpacing: 2,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'TIKET DIGITAL',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Ticket number
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 28),
                  child: Column(
                    children: [
                      Text(
                        ticket.displayNumber,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 80,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                          letterSpacing: -3,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppTheme.gold.withValues(alpha: 0.4),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        ticket.customerName.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatDateTime(ticket.createdAt),
                        style: AppTheme.bodyMedium(),
                      ),
                    ],
                  ),
                ),

                // Dashed tear line
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: List.generate(
                      30,
                      (i) => Expanded(
                        child: Container(
                          height: 1,
                          color: i.isEven
                              ? AppTheme.borderColor
                              : Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ),

                // Footer info
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _InfoItem(
                          label: 'Antrian di Depan',
                          value: queueAhead == 0
                              ? 'Giliran Anda Segera'
                              : '$queueAhead antrian',
                          icon: Icons.people_outline,
                          color: queueAhead == 0
                              ? AppTheme.success
                              : AppTheme.gold,
                        ),
                      ),
                      Container(
                        width: 0.5,
                        height: 40,
                        color: AppTheme.borderColor,
                      ),
                      Expanded(
                        child: const _InfoItem(
                          label: 'Loket Layanan',
                          value: 'Loket 1',
                          icon: Icons.location_on_outlined,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
          .animate()
          .fadeIn(duration: 500.ms)
          .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),

          const SizedBox(height: 24),

          Text(
            'Harap tunggu hingga nomor Anda dipanggil.',
            style: AppTheme.bodyMedium(),
            textAlign: TextAlign.center,
          )
          .animate()
          .fadeIn(duration: 400.ms, delay: 200.ms),

          const SizedBox(height: 12),

          Text(
            'Halaman ini akan tertutup dalam $countdown detik...',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppTheme.textMuted,
            ),
            textAlign: TextAlign.center,
          )
          .animate()
          .fadeIn(duration: 400.ms, delay: 300.ms),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: color,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
