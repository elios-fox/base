import 'package:flutter/material.dart';

import '../../../core/models/payment.dart';

class PaymentTile extends StatelessWidget {
  const PaymentTile({
    super.key,
    required this.payment,
    this.displayName,
    this.onStatusChanged,
  });

  final Payment payment;
  final String? displayName;
  final void Function(String status)? onStatusChanged;

  Color _statusColor() {
    return switch (payment.status) {
      'paid' => const Color(0xFF4CAF50),
      'overdue' => const Color(0xFFF44336),
      _ => const Color(0xFFFF9800),
    };
  }

  String _statusLabel() {
    return switch (payment.status) {
      'paid' => 'Betaald',
      'overdue' => 'Te laat',
      _ => 'Open',
    };
  }

  IconData _statusIcon() {
    return switch (payment.status) {
      'paid' => Icons.check_circle,
      'overdue' => Icons.warning_rounded,
      _ => Icons.schedule,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(_statusIcon(), color: color, size: 20),
      ),
      title: Text(displayName ?? payment.userUid),
      subtitle: Text(
        '\u20AC ${payment.amountEuros.toStringAsFixed(2)}',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: Chip(
        label: Text(
          _statusLabel(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        backgroundColor: color.withValues(alpha: 0.12),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
      onTap: onStatusChanged != null && !payment.isPaid
          ? () => _showStatusMenu(context)
          : null,
    );
  }

  void _showStatusMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Status wijzigen',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
              title: const Text('Betaald'),
              onTap: () {
                Navigator.of(ctx).pop();
                onStatusChanged?.call('paid');
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.warning_rounded, color: Color(0xFFF44336)),
              title: const Text('Te laat'),
              onTap: () {
                Navigator.of(ctx).pop();
                onStatusChanged?.call('overdue');
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule, color: Color(0xFFFF9800)),
              title: const Text('Open'),
              onTap: () {
                Navigator.of(ctx).pop();
                onStatusChanged?.call('open');
              },
            ),
          ],
        ),
      ),
    );
  }
}
