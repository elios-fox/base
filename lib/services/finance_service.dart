import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/models/contribution.dart';
import '../core/models/payment.dart';

/// Abstracte interface voor de financiën-service.
abstract class FinanceService {
  Stream<List<Contribution>> getContributions(String teamId);
  Future<Contribution> createContribution({
    required String teamId,
    required int seasonYear,
    required int amountCents,
    required String description,
    required DateTime dueDate,
  });
  Stream<List<Payment>> getPayments(String contributionId);
  Stream<List<Payment>> getMyPayments(String userId);
  Future<void> updatePaymentStatus(String paymentId, String status);
  Future<void> markAsPaid(String paymentId);
  void dispose();
}

class SupaFinanceService implements FinanceService {
  SupaFinanceService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  // ── Contributions ──────────────────────────────────────────

  @override
  Stream<List<Contribution>> getContributions(String teamId) {
    final controller = StreamController<List<Contribution>>.broadcast();

    // Initiële data laden
    _fetchContributions(teamId).then(controller.add);

    // Realtime luisteren
    final channel = _client
        .channel('contributions_$teamId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'contributions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'team_id',
            value: teamId,
          ),
          callback: (_) {
            _fetchContributions(teamId).then(controller.add);
          },
        )
        .subscribe();

    controller.onCancel = () {
      _client.removeChannel(channel);
    };

    return controller.stream;
  }

  Future<List<Contribution>> _fetchContributions(String teamId) async {
    final data = await _client
        .from('contributions')
        .select()
        .eq('team_id', teamId)
        .order('due_date', ascending: false);

    return (data as List)
        .map((e) => Contribution.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Contribution> createContribution({
    required String teamId,
    required int seasonYear,
    required int amountCents,
    required String description,
    required DateTime dueDate,
  }) async {
    final data = await _client.from('contributions').insert({
      'team_id': teamId,
      'season_year': seasonYear,
      'amount_cents': amountCents,
      'description': description,
      'due_date': dueDate.toIso8601String().split('T').first,
    }).select().single();

    return Contribution.fromJson(data);
  }

  // ── Payments ───────────────────────────────────────────────

  @override
  Stream<List<Payment>> getPayments(String contributionId) {
    final controller = StreamController<List<Payment>>.broadcast();

    _fetchPayments(contributionId).then(controller.add);

    final channel = _client
        .channel('payments_$contributionId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'payments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'contribution_id',
            value: contributionId,
          ),
          callback: (_) {
            _fetchPayments(contributionId).then(controller.add);
          },
        )
        .subscribe();

    controller.onCancel = () {
      _client.removeChannel(channel);
    };

    return controller.stream;
  }

  Future<List<Payment>> _fetchPayments(String contributionId) async {
    final data = await _client
        .from('payments')
        .select()
        .eq('contribution_id', contributionId)
        .order('created_at');

    return (data as List)
        .map((e) => Payment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Stream<List<Payment>> getMyPayments(String userId) {
    final controller = StreamController<List<Payment>>.broadcast();

    _fetchMyPayments(userId).then(controller.add);

    final channel = _client
        .channel('my_payments_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'payments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_uid',
            value: userId,
          ),
          callback: (_) {
            _fetchMyPayments(userId).then(controller.add);
          },
        )
        .subscribe();

    controller.onCancel = () {
      _client.removeChannel(channel);
    };

    return controller.stream;
  }

  Future<List<Payment>> _fetchMyPayments(String userId) async {
    final data = await _client
        .from('payments')
        .select()
        .eq('user_uid', userId)
        .order('created_at', ascending: false);

    return (data as List)
        .map((e) => Payment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> updatePaymentStatus(String paymentId, String status) async {
    await _client.from('payments').update({
      'status': status,
      if (status == 'paid') 'paid_at': DateTime.now().toIso8601String(),
    }).eq('id', paymentId);
  }

  @override
  Future<void> markAsPaid(String paymentId) async {
    await updatePaymentStatus(paymentId, 'paid');
  }

  @override
  void dispose() {
    // Channels worden opgeruimd via stream onCancel callbacks
  }
}
