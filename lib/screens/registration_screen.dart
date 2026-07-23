import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/queue_transaction.dart';
import '../providers/queue_provider.dart';
import '../widgets/glass_nav_bar.dart';
import '../widgets/haptic_button.dart';
import '../widgets/squircle_card.dart';
import '../utils/date_helper.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _nameController = TextEditingController();
  QueueTransaction? _lastTicket;
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
      setState(() => _errorText = 'Nama minimal 2 karakter');
      return;
    }
    if (name.length > 100) {
      setState(() => _errorText = 'Nama maksimal 100 karakter');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    final provider = context.read<QueueProvider>();
    final ticket = await provider.registerQueue(name);

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      if (ticket != null) {
        _lastTicket = ticket;
        _nameController.clear();
      } else {
        _errorText = provider.error ?? 'Gagal mendaftar';
      }
    });

    if (ticket != null && mounted) {
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QueueProvider>(
      builder: (context, provider, _) {
        return CupertinoPageScaffold(
          child: SafeArea(
            child: Column(
              children: [
                const GlassNavBar(title: 'Ambil Antrian'),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: _lastTicket != null
                          ? _buildTicketCard()
                          : _buildForm(),
                    ),
                  ),
                ),
                if (_isSubmitting)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CupertinoActivityIndicator(radius: 16),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          CupertinoIcons.ticket_fill,
          size: 64,
          color: Color(0xFF007AFF),
        ),
        const SizedBox(height: 24),
        const Text(
          'Masukkan nama Anda',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 24),
        CupertinoTextField(
          controller: _nameController,
          placeholder: 'Masukkan nama Anda',
          padding: const EdgeInsets.all(16),
          clearButtonMode: OverlayVisibilityMode.editing,
          maxLength: 100,
          style: const TextStyle(fontSize: 18),
        ),
        if (_errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            _errorText!,
            style: const TextStyle(color: Colors.red, fontSize: 14),
          ),
        ],
        const SizedBox(height: 32),
        _isSubmitting
            ? const CupertinoActivityIndicator(radius: 16)
            : HapticButton(
                label: 'Ambil Antrian',
                icon: CupertinoIcons.arrow_right_circle_fill,
                color: const Color(0xFF007AFF),
                size: ButtonSize.large,
                onPressed: _submit,
              ),
      ],
    );
  }

  Widget _buildTicketCard() {
    final ticket = _lastTicket!;
    return SquircleCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Tiket Digital',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Text(
            ticket.displayNumber,
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.w900,
              color: Color(0xFF007AFF),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ticket.customerName,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            formatDateTime(ticket.createdAt),
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          const Text(
            'Harap tunggu hingga nomor Anda dipanggil',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Estimasi: ${ticket.queueNumber} antrian di depan',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
