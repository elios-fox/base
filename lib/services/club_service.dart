import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/models/club.dart';
import '../core/models/club_member.dart';
import '../core/supabase/supabase_client.dart';

abstract class ClubService {
  Stream<List<Club>> getMyClubs(String userId);
  Future<Club?> getClub(String id);
  Future<Club> createClub(String name, String creatorUid);
  Future<void> updateClub(Club club);
  Future<void> deleteClub(String id);
  Stream<List<ClubMember>> getClubMembers(String clubId);
  Future<ClubMember?> getMyMembership(String clubId, String userId);
  Future<void> updateMemberRole(String memberId, ClubRole role);
  Future<void> removeMember(String memberId);
  Future<Club> joinClub(String inviteCode);
}

class SupaClubService implements ClubService {
  SupaClubService({SupabaseClientWrapper? client})
      : _client = client ?? SupabaseClientWrapper.instance;

  final SupabaseClientWrapper _client;

  SupabaseClient get _supabase => _client.client;

  @override
  Stream<List<Club>> getMyClubs(String userId) {
    final controller = StreamController<List<Club>>.broadcast();

    Future<void> fetch() async {
      try {
        // Get club IDs where user is a member
        final memberRows = await _supabase
            .from('club_members')
            .select('club_id')
            .eq('user_uid', userId);
        final clubIds =
            memberRows.map((r) => r['club_id'] as String).toList();

        if (clubIds.isEmpty) {
          if (!controller.isClosed) controller.add([]);
          return;
        }

        final data = await _supabase
            .from('clubs')
            .select()
            .inFilter('id', clubIds)
            .order('name', ascending: true);

        if (!controller.isClosed) {
          controller.add(data.map(_clubFromMap).toList());
        }
      } catch (e) {
        if (!controller.isClosed) controller.addError(e);
      }
    }

    fetch();

    final channel = _supabase
        .channel('public:clubs:member:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'clubs',
          callback: (_) => fetch(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'club_members',
          callback: (_) => fetch(),
        )
        .subscribe();

    controller.onCancel = () {
      _supabase.removeChannel(channel);
    };

    return controller.stream;
  }

  @override
  Future<Club?> getClub(String id) async {
    try {
      final data =
          await _supabase.from('clubs').select().eq('id', id).maybeSingle();
      if (data == null) return null;
      return _clubFromMap(data);
    } on PostgrestException {
      return null;
    }
  }

  @override
  Future<Club> createClub(String name, String creatorUid) async {
    final data = await _supabase
        .from('clubs')
        .insert({'name': name})
        .select()
        .single();
    final club = _clubFromMap(data);

    // Add creator as bestuur
    await _supabase.from('club_members').insert({
      'club_id': club.id,
      'user_uid': creatorUid,
      'role': 'bestuur',
    });

    return club;
  }

  @override
  Future<void> updateClub(Club club) async {
    await _supabase.from('clubs').update({
      'name': club.name,
      'logo_url': club.logoUrl,
    }).eq('id', club.id);
  }

  @override
  Future<void> deleteClub(String id) async {
    await _supabase.from('clubs').delete().eq('id', id);
  }

  @override
  Stream<List<ClubMember>> getClubMembers(String clubId) {
    final controller = StreamController<List<ClubMember>>.broadcast();

    Future<void> fetch() async {
      try {
        final data = await _supabase
            .from('club_members')
            .select()
            .eq('club_id', clubId)
            .order('role', ascending: true);
        if (!controller.isClosed) {
          controller.add(data.map(_memberFromMap).toList());
        }
      } catch (e) {
        if (!controller.isClosed) controller.addError(e);
      }
    }

    fetch();

    final channel = _supabase
        .channel('public:club_members:$clubId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'club_members',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'club_id',
            value: clubId,
          ),
          callback: (_) => fetch(),
        )
        .subscribe();

    controller.onCancel = () {
      _supabase.removeChannel(channel);
    };

    return controller.stream;
  }

  @override
  Future<ClubMember?> getMyMembership(String clubId, String userId) async {
    try {
      final data = await _supabase
          .from('club_members')
          .select()
          .eq('club_id', clubId)
          .eq('user_uid', userId)
          .maybeSingle();
      if (data == null) return null;
      return _memberFromMap(data);
    } on PostgrestException {
      return null;
    }
  }

  @override
  Future<void> updateMemberRole(String memberId, ClubRole role) async {
    await _supabase.from('club_members').update({
      'role': role.name,
    }).eq('id', memberId);
  }

  @override
  Future<void> removeMember(String memberId) async {
    await _supabase.from('club_members').delete().eq('id', memberId);
  }

  @override
  Future<Club> joinClub(String inviteCode) async {
    final data = await _supabase
        .from('clubs')
        .select()
        .eq('invite_code', inviteCode)
        .single();
    final club = _clubFromMap(data);

    // Check if already a member
    final existing = await _supabase
        .from('club_members')
        .select()
        .eq('club_id', club.id)
        .eq('user_uid', _client.userId)
        .maybeSingle();

    if (existing == null) {
      await _supabase.from('club_members').insert({
        'club_id': club.id,
        'user_uid': _client.userId,
        'role': 'speler',
      });
    }

    return club;
  }

  Club _clubFromMap(Map<String, dynamic> map) {
    return Club(
      id: map['id'] as String,
      name: map['name'] as String,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      logoUrl: map['logo_url'] as String?,
      inviteCode: map['invite_code'] as String?,
    );
  }

  ClubMember _memberFromMap(Map<String, dynamic> map) {
    return ClubMember(
      id: map['id'] as String,
      clubId: map['club_id'] as String,
      userUid: map['user_uid'] as String,
      role: ClubRole.values.byName(map['role'] as String),
      joinedAt: DateTime.tryParse(map['joined_at'] as String? ?? '') ??
          DateTime.now(),
      displayName: map['display_name'] as String?,
      email: map['email'] as String?,
    );
  }
}
