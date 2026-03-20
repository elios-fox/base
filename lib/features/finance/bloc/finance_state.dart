part of 'finance_bloc.dart';

enum FinanceStatus { initial, loading, loaded, failure }

final class FinanceState extends Equatable {
  const FinanceState({
    this.status = FinanceStatus.initial,
    this.contributions = const [],
    this.payments = const [],
  });

  final FinanceStatus status;
  final List<Contribution> contributions;
  final List<Payment> payments;

  FinanceState copyWith({
    FinanceStatus? status,
    List<Contribution>? contributions,
    List<Payment>? payments,
  }) {
    return FinanceState(
      status: status ?? this.status,
      contributions: contributions ?? this.contributions,
      payments: payments ?? this.payments,
    );
  }

  @override
  List<Object?> get props => [status, contributions, payments];
}
