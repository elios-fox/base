import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/contribution.dart';
import '../../../core/models/payment.dart';
import '../bloc/finance_bloc.dart';
import 'payment_tile.dart';

class ContributionCard extends StatefulWidget {
  const ContributionCard({
    super.key,
    required this.contribution,
    this.payments = const [],
  });

  final Contribution contribution;
  final List<Payment> payments;

  @override
  State<ContributionCard> createState() => _ContributionCardState();
}

class _ContributionCardState extends State<ContributionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.contribution;
    final payments = widget.payments;
    final paidCount = payments.where((p) => p.isPaid).length;
    final total = payments.length;
    final progress = total > 0 ? paidCount / total : 0.0;

    final isOverdue = c.dueDate.isBefore(DateTime.now());

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() => _expanded = !_expanded);
          if (_expanded && payments.isEmpty) {
            context
                .read<FinanceBloc>()
                .add(PaymentsLoadRequested(contributionId: c.id));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: beschrijving + bedrag
              Row(
                children: [
                  Expanded(
                    child: Text(
                      c.description,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '\u20AC ${c.amountEuros.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Seizoen + deadline
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Seizoen ${c.seasonYear}/${c.seasonYear + 1}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.flag,
                    size: 14,
                    color: isOverdue
                        ? const Color(0xFFF44336)
                        : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Deadline: ${c.dueDate.day}-${c.dueDate.month}-${c.dueDate.year}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isOverdue
                          ? const Color(0xFFF44336)
                          : Colors.grey[600],
                      fontWeight:
                          isOverdue ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Voortgangsbalk
              if (total > 0) ...[
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress == 1.0
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFFF9800),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$paidCount/$total betaald',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],

              // Uitklapbare payments
              if (_expanded && payments.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Divider(),
                ...payments.map(
                  (payment) => PaymentTile(
                    payment: payment,
                    onStatusChanged: (status) {
                      context.read<FinanceBloc>().add(
                            PaymentStatusChanged(
                              paymentId: payment.id,
                              status: status,
                            ),
                          );
                    },
                  ),
                ),
              ],

              // Expand indicator
              Center(
                child: Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
