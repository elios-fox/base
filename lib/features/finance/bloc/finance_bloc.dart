import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/contribution.dart';
import '../../../core/models/payment.dart';
import '../../../services/finance_service.dart';

part 'finance_event.dart';
part 'finance_state.dart';

class FinanceBloc extends Bloc<FinanceEvent, FinanceState> {
  FinanceBloc({required FinanceService financeService})
      : _financeService = financeService,
        super(const FinanceState()) {
    on<FinanceLoadRequested>(_onLoadRequested, transformer: restartable());
    on<ContributionCreateRequested>(_onContributionCreateRequested);
    on<PaymentStatusChanged>(_onPaymentStatusChanged);
    on<PaymentsLoadRequested>(_onPaymentsLoadRequested, transformer: restartable());
  }

  final FinanceService _financeService;

  Future<void> _onLoadRequested(
    FinanceLoadRequested event,
    Emitter<FinanceState> emit,
  ) {
    emit(state.copyWith(status: FinanceStatus.loading));
    return emit.forEach<List<Contribution>>(
      _financeService.getContributions(event.teamId),
      onData: (contributions) => state.copyWith(
        status: FinanceStatus.loaded,
        contributions: contributions,
      ),
      onError: (_, _) => state.copyWith(status: FinanceStatus.failure),
    );
  }

  Future<void> _onContributionCreateRequested(
    ContributionCreateRequested event,
    Emitter<FinanceState> emit,
  ) async {
    emit(state.copyWith(status: FinanceStatus.loading));
    try {
      await _financeService.createContribution(
        teamId: event.teamId,
        seasonYear: event.seasonYear,
        amountCents: event.amountCents,
        description: event.description,
        dueDate: event.dueDate,
      );
      emit(state.copyWith(status: FinanceStatus.loaded));
    } catch (_) {
      emit(state.copyWith(status: FinanceStatus.failure));
    }
  }

  Future<void> _onPaymentStatusChanged(
    PaymentStatusChanged event,
    Emitter<FinanceState> emit,
  ) async {
    try {
      await _financeService.updatePaymentStatus(
        event.paymentId,
        event.status,
      );
    } catch (_) {
      emit(state.copyWith(status: FinanceStatus.failure));
    }
  }

  Future<void> _onPaymentsLoadRequested(
    PaymentsLoadRequested event,
    Emitter<FinanceState> emit,
  ) {
    return emit.forEach<List<Payment>>(
      _financeService.getPayments(event.contributionId),
      onData: (payments) => state.copyWith(payments: payments),
      onError: (_, _) => state.copyWith(status: FinanceStatus.failure),
    );
  }
}
