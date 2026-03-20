part of 'finance_bloc.dart';

sealed class FinanceEvent extends Equatable {
  const FinanceEvent();

  @override
  List<Object?> get props => [];
}

final class FinanceLoadRequested extends FinanceEvent {
  const FinanceLoadRequested({required this.teamId});

  final String teamId;

  @override
  List<Object?> get props => [teamId];
}

final class ContributionCreateRequested extends FinanceEvent {
  const ContributionCreateRequested({
    required this.teamId,
    required this.seasonYear,
    required this.amountCents,
    required this.description,
    required this.dueDate,
  });

  final String teamId;
  final int seasonYear;
  final int amountCents;
  final String description;
  final DateTime dueDate;

  @override
  List<Object?> get props => [
        teamId,
        seasonYear,
        amountCents,
        description,
        dueDate,
      ];
}

final class PaymentStatusChanged extends FinanceEvent {
  const PaymentStatusChanged({
    required this.paymentId,
    required this.status,
  });

  final String paymentId;
  final String status;

  @override
  List<Object?> get props => [paymentId, status];
}

final class PaymentsLoadRequested extends FinanceEvent {
  const PaymentsLoadRequested({required this.contributionId});

  final String contributionId;

  @override
  List<Object?> get props => [contributionId];
}
