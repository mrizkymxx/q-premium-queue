import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/queue_provider.dart';
import '../widgets/glass_nav_bar.dart';
import '../widgets/calling_card.dart';
import '../widgets/haptic_button.dart';
import '../widgets/queue_tile.dart';

class OperatorDashboardScreen extends StatefulWidget {
  const OperatorDashboardScreen({super.key});

  @override
  State<OperatorDashboardScreen> createState() =>
      _OperatorDashboardScreenState();
}

class _OperatorDashboardScreenState extends State<OperatorDashboardScreen> {
  bool _confirmSkip = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QueueProvider>().startRealtimeSubscription();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QueueProvider>(
      builder: (context, provider, _) {
        return CupertinoPageScaffold(
          child: SafeArea(
            child: Column(
              children: [
                const GlassNavBar(title: 'Q-PREMIUM Operator'),
                if (provider.error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: Colors.red.shade50,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.error!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: provider.isLoading &&
                          provider.currentCalling == null &&
                          provider.waitingList.isEmpty
                      ? const Center(child: CupertinoActivityIndicator())
                      : _buildContent(provider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(QueueProvider provider) {
    final hasCalling = provider.currentCalling != null;
    final hasWaiting = provider.waitingList.isNotEmpty;

    if (!hasCalling && !hasWaiting) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CallingCard(
            queueNumber: provider.currentCalling?.queueNumber,
            queuePrefix: provider.currentCalling?.queuePrefix,
            customerName: provider.currentCalling?.customerName,
          ),
          const SizedBox(height: 16),
          _buildActionButtons(provider),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'Belum ada antrian.\nPelanggan dapat mendaftar melalui layar Registrasi.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: CallingCard(
            queueNumber: provider.currentCalling?.queueNumber,
            queuePrefix: provider.currentCalling?.queuePrefix,
            customerName: provider.currentCalling?.customerName,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildActionButtons(provider),
        ),
        if (hasWaiting) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Daftar Tunggu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: provider.waitingList.length,
              itemBuilder: (context, index) {
                final t = provider.waitingList[index];
                return QueueTile(
                  queueNumber: t.queueNumber,
                  queuePrefix: t.queuePrefix,
                  customerName: t.customerName,
                  status: t.status,
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(QueueProvider provider) {
    final hasCalling = provider.currentCalling != null;
    final canCall = provider.canCallNext && provider.waitingList.isNotEmpty;

    return Row(
      children: [
        if (hasCalling) ...[
          Expanded(
            child: HapticButton(
              label: _confirmSkip ? 'Yakin Lewati?' : 'Lewati',
              color: Colors.grey,
              onPressed: () {
                if (!_confirmSkip) {
                  setState(() => _confirmSkip = true);
                  Future.delayed(const Duration(seconds: 3), () {
                    if (mounted) setState(() => _confirmSkip = false);
                  });
                } else {
                  provider.skipCurrent(provider.currentCalling!.id);
                  setState(() => _confirmSkip = false);
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: HapticButton(
              label: 'Selesai',
              icon: Icons.check,
              color: const Color(0xFF3B82F6),
              onPressed: () =>
                  provider.completeCurrent(provider.currentCalling!.id),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          flex: hasCalling ? 2 : 1,
          child: HapticButton(
            label: 'Panggil Berikutnya',
            icon: Icons.play_arrow,
            color: const Color(0xFF22C55E),
            size: ButtonSize.large,
            onPressed: canCall ? () => provider.callNext() : null,
          ),
        ),
      ],
    );
  }
}
