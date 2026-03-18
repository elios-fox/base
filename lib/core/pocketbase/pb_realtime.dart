import 'dart:async';

import 'package:pocketbase/pocketbase.dart';

import 'pb_client.dart';

/// Wraps PocketBase realtime subscriptions into Dart Streams.
class PbRealtime {
  PbRealtime({PbClient? client}) : _client = client ?? PbClient.instance;

  final PbClient _client;

  /// Subscribe to a collection and return a Stream of RecordSubscriptionEvents.
  Stream<RecordSubscriptionEvent> subscribe(
    String collection, {
    String? recordId,
  }) {
    final controller = StreamController<RecordSubscriptionEvent>.broadcast();
    _client.pb.collection(collection).subscribe(
      recordId ?? '*',
      (event) {
        if (!controller.isClosed) {
          controller.add(event);
        }
      },
    );

    controller.onCancel = () {
      _client.pb.collection(collection).unsubscribe(recordId ?? '*');
    };

    return controller.stream;
  }

  /// Subscribe to a collection and emit full list on every change.
  Stream<List<RecordModel>> subscribeToList(
    String collection, {
    String? filter,
    String? sort,
    String? expand,
  }) {
    final controller = StreamController<List<RecordModel>>.broadcast();

    Future<void> fetchAll() async {
      try {
        final records = await _client.pb.collection(collection).getFullList(
              filter: filter,
              sort: sort,
              expand: expand,
            );
        if (!controller.isClosed) {
          controller.add(records);
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(e);
        }
      }
    }

    // Initial fetch
    fetchAll();

    // Subscribe to changes and re-fetch
    _client.pb.collection(collection).subscribe('*', (_) => fetchAll());

    controller.onCancel = () {
      _client.pb.collection(collection).unsubscribe('*');
    };

    return controller.stream;
  }
}
