import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../bloc/finance_bloc.dart';
import '../widgets/contribution_card.dart';

class FinanceView extends StatelessWidget {
  const FinanceView({super.key, required this.teamId});

  final String teamId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Financien')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/finance/create?teamId=$teamId'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<FinanceBloc, FinanceState>(
        builder: (context, state) {
          return switch (state.status) {
            FinanceStatus.initial ||
            FinanceStatus.loading =>
              const LoadingIndicator(),
            FinanceStatus.failure => ErrorView(
                message: 'Kon contributies niet laden.',
                onRetry: () => context
                    .read<FinanceBloc>()
                    .add(FinanceLoadRequested(teamId: teamId)),
              ),
            FinanceStatus.loaded => state.contributions.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Nog geen contributies.\nMaak er een aan!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.contributions.length,
                    itemBuilder: (context, index) {
                      final contribution = state.contributions[index];
                      // Filter payments die bij deze contributie horen
                      final relatedPayments = state.payments
                          .where(
                              (p) => p.contributionId == contribution.id)
                          .toList();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ContributionCard(
                          contribution: contribution,
                          payments: relatedPayments,
                        ),
                      );
                    },
                  ),
          };
        },
      ),
    );
  }
}
