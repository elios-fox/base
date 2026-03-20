import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/models/checklist.dart';
import '../core/models/checklist_item.dart';
import '../core/supabase/supabase_client.dart';
import '../core/supabase/supabase_realtime.dart';

abstract class ChecklistService {
  Stream<List<Checklist>> getChecklists(String ownerUid);
  Stream<List<Checklist>> getTeamChecklists(String teamId);
  Future<Checklist?> getChecklist(String id);
  Future<Checklist> createChecklist({
    required String title,
    required String ownerUid,
    String? teamId,
    List<ChecklistItem> items,
  });
  Future<void> updateChecklist(Checklist checklist);
  Future<void> deleteChecklist(String id);
}

class SupaChecklistService implements ChecklistService {
  SupaChecklistService({
    SupabaseClientWrapper? client,
    SupabaseRealtime? realtime,
  })  : _client = client ?? SupabaseClientWrapper.instance,
        _realtime = realtime ?? SupabaseRealtime();

  final SupabaseClientWrapper _client;
  final SupabaseRealtime _realtime;

  SupabaseClient get _supabase => _client.client;

  @override
  Stream<List<Checklist>> getChecklists(String ownerUid) {
    return _realtime
        .subscribeToList(
          'checklists',
          column: 'owner_uid',
          value: ownerUid,
          orderBy: 'created_at',
          ascending: false,
        )
        .map((rows) => rows.map(_checklistFromMap).toList());
  }

  @override
  Stream<List<Checklist>> getTeamChecklists(String teamId) {
    return _realtime
        .subscribeToList(
          'checklists',
          column: 'team_id',
          value: teamId,
          orderBy: 'created_at',
          ascending: false,
        )
        .map((rows) => rows.map(_checklistFromMap).toList());
  }

  @override
  Future<Checklist?> getChecklist(String id) async {
    try {
      final data = await _supabase
          .from('checklists')
          .select()
          .eq('id', id)
          .maybeSingle();
      if (data == null) return null;
      return _checklistFromMap(data);
    } on PostgrestException {
      return null;
    }
  }

  @override
  Future<Checklist> createChecklist({
    required String title,
    required String ownerUid,
    String? teamId,
    List<ChecklistItem> items = const [],
  }) async {
    final data = await _supabase.from('checklists').insert({
      'title': title,
      'owner_uid': ownerUid,
      'team_id': teamId,
      'items': items.map((e) => e.toMap()).toList(),
    }).select().single();
    return _checklistFromMap(data);
  }

  @override
  Future<void> updateChecklist(Checklist checklist) async {
    await _supabase.from('checklists').update({
      'title': checklist.title,
      'owner_uid': checklist.ownerUid,
      'team_id': checklist.teamId,
      'items': checklist.items.map((e) => e.toMap()).toList(),
    }).eq('id', checklist.id);
  }

  @override
  Future<void> deleteChecklist(String id) async {
    await _supabase.from('checklists').delete().eq('id', id);
  }

  Checklist _checklistFromMap(Map<String, dynamic> map) {
    final itemsList = (map['items'] as List<dynamic>?)
            ?.map((e) =>
                ChecklistItem.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        [];
    return Checklist(
      id: map['id'] as String,
      title: map['title'] as String,
      ownerUid: map['owner_uid'] as String,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      teamId: map['team_id'] as String?,
      items: itemsList,
    );
  }
}
