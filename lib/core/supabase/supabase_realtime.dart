import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_client.dart';

class SupabaseRealtime {
  SupabaseRealtime({SupabaseClientWrapper? client})
      : _client = client ?? SupabaseClientWrapper.instance;

  final SupabaseClientWrapper _client;

  SupabaseClient get _supabase => _client.client;

  /// Subscribe to a table and get a stream of all rows matching the filter.
  /// Does initial fetch + listens for changes.
  Stream<List<Map<String, dynamic>>> subscribeToList(
    String table, {
    String? column,
    String? value,
    String orderBy = 'created_at',
    bool ascending = false,
  }) {
    final controller = StreamController<List<Map<String, dynamic>>>.broadcast();

    // Initial fetch
    _fetchAndEmit(table, column, value, orderBy, ascending, controller);

    // Subscribe to changes
    final channel = _supabase
        .channel('public:$table:${column ?? 'all'}:${value ?? 'all'}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: table,
          callback: (payload) {
            // Re-fetch on any change
            _fetchAndEmit(table, column, value, orderBy, ascending, controller);
          },
        )
        .subscribe();

    controller.onCancel = () {
      _supabase.removeChannel(channel);
    };

    return controller.stream;
  }

  Future<void> _fetchAndEmit(
    String table,
    String? column,
    String? value,
    String orderBy,
    bool ascending,
    StreamController<List<Map<String, dynamic>>> controller,
  ) async {
    try {
      var query = _supabase.from(table).select();
      if (column != null && value != null) {
        query = query.eq(column, value);
      }
      final data = await query.order(orderBy, ascending: ascending);
      if (!controller.isClosed) {
        controller.add(data);
      }
    } catch (e) {
      if (!controller.isClosed) {
        controller.addError(e);
      }
    }
  }
}
