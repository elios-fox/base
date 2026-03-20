import 'package:equatable/equatable.dart';

class Payment extends Equatable {
  const Payment({
    required this.id,
    required this.contributionId,
    required this.userUid,
    required this.amountCents,
    required this.status,
    this.paidAt,
    required this.createdAt,
  });

  final String id;
  final String contributionId;
  final String userUid;
  final int amountCents;
  final String status;
  final DateTime? paidAt;
  final DateTime createdAt;

  double get amountEuros => amountCents / 100;

  bool get isPaid => status == 'paid';
  bool get isOverdue => status == 'overdue';
  bool get isOpen => status == 'open';

  Payment copyWith({
    String? id,
    String? contributionId,
    String? userUid,
    int? amountCents,
    String? status,
    DateTime? paidAt,
    DateTime? createdAt,
  }) {
    return Payment(
      id: id ?? this.id,
      contributionId: contributionId ?? this.contributionId,
      userUid: userUid ?? this.userUid,
      amountCents: amountCents ?? this.amountCents,
      status: status ?? this.status,
      paidAt: paidAt ?? this.paidAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      contributionId: json['contribution_id'] as String,
      userUid: json['user_uid'] as String,
      amountCents: json['amount_cents'] as int,
      status: json['status'] as String,
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contribution_id': contributionId,
      'user_uid': userUid,
      'amount_cents': amountCents,
      'status': status,
      if (paidAt != null) 'paid_at': paidAt!.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        contributionId,
        userUid,
        amountCents,
        status,
        paidAt,
        createdAt,
      ];
}
