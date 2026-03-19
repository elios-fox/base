import 'package:equatable/equatable.dart';

enum NotificationType { eventReminder, attendanceRequest, teamInvite }

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.read,
    required this.createdAt,
    this.data = const {},
  });

  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final bool read;
  final DateTime createdAt;
  final Map<String, dynamic> data;

  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    bool? read,
    DateTime? createdAt,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }

  static NotificationType _parseType(String? value) {
    return switch (value) {
      'event_reminder' => NotificationType.eventReminder,
      'attendance_request' => NotificationType.attendanceRequest,
      'team_invite' => NotificationType.teamInvite,
      _ => NotificationType.attendanceRequest,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      body: json['body'] as String? ?? '',
      type: _parseType(json['type'] as String?),
      read: json['read'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      data: json['data'] as Map<String, dynamic>? ?? const {},
    );
  }

  @override
  List<Object?> get props =>
      [id, userId, title, body, type, read, createdAt, data];
}
