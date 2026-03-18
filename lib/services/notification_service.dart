import 'package:pocketbase/pocketbase.dart';

import '../core/models/notification_model.dart';
import '../core/pocketbase/pb_client.dart';
import '../core/pocketbase/pb_realtime.dart';

abstract class NotificationService {
  Stream<List<AppNotification>> getNotifications(String userId);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
  Future<int> getUnreadCount(String userId);
}

class PbNotificationService implements NotificationService {
  PbNotificationService({PbClient? client, PbRealtime? realtime})
      : _client = client ?? PbClient.instance,
        _realtime = realtime ?? PbRealtime();

  final PbClient _client;
  final PbRealtime _realtime;

  PocketBase get _pb => _client.pb;

  @override
  Stream<List<AppNotification>> getNotifications(String userId) {
    return _realtime
        .subscribeToList(
          'notifications',
          filter: 'userId = "$userId"',
          sort: '-created',
        )
        .map((records) =>
            records.map(AppNotification.fromRecord).toList());
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _pb.collection('notifications').update(notificationId, body: {
      'read': true,
    });
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final records = await _pb.collection('notifications').getFullList(
          filter: 'userId = "$userId" && read = false',
        );
    for (final record in records) {
      await _pb.collection('notifications').update(record.id, body: {
        'read': true,
      });
    }
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    final result = await _pb.collection('notifications').getList(
          filter: 'userId = "$userId" && read = false',
          perPage: 1,
        );
    return result.totalItems;
  }
}
