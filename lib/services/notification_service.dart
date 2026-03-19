import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/models/notification_model.dart';
import '../core/supabase/supabase_client.dart';
import '../core/supabase/supabase_realtime.dart';

abstract class NotificationService {
  Stream<List<AppNotification>> getNotifications(String userId);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
  Future<int> getUnreadCount(String userId);
}

class SupaNotificationService implements NotificationService {
  SupaNotificationService({
    SupabaseClientWrapper? client,
    SupabaseRealtime? realtime,
  })  : _client = client ?? SupabaseClientWrapper.instance,
        _realtime = realtime ?? SupabaseRealtime();

  final SupabaseClientWrapper _client;
  final SupabaseRealtime _realtime;

  SupabaseClient get _supabase => _client.client;

  @override
  Stream<List<AppNotification>> getNotifications(String userId) {
    return _realtime
        .subscribeToList(
          'notifications',
          column: 'user_id',
          value: userId,
          orderBy: 'created_at',
          ascending: false,
        )
        .map((rows) => rows.map(AppNotification.fromJson).toList());
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _supabase.from('notifications').update({
      'read': true,
    }).eq('id', notificationId);
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    await _supabase
        .from('notifications')
        .update({'read': true})
        .eq('user_id', userId)
        .eq('read', false);
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    final data = await _supabase
        .from('notifications')
        .select('id')
        .eq('user_id', userId)
        .eq('read', false);
    return data.length;
  }
}
