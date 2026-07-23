import 'package:flutter/material.dart';
import 'squircle_card.dart';

class CallingCard extends StatelessWidget {
  final int? queueNumber;
  final String? queuePrefix;
  final String? customerName;

  const CallingCard({
    super.key,
    this.queueNumber,
    this.queuePrefix,
    this.customerName,
  });

  @override
  Widget build(BuildContext context) {
    if (queueNumber == null && queuePrefix == null && customerName == null) {
      return SquircleCard(
        child: Container(
          height: 160,
          alignment: Alignment.center,
          child: Text(
            'Belum Ada Antrian',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return SquircleCard(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF22C55E), Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$queuePrefix-${queueNumber!}',
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (customerName != null)
                    Text(
                      customerName!,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
