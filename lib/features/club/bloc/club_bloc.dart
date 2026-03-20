import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/club.dart';
import '../../../core/models/club_member.dart';
import '../../../services/club_service.dart';

part 'club_event.dart';
part 'club_state.dart';

class ClubBloc extends Bloc<ClubEvent, ClubState> {
  ClubBloc({required ClubService clubService, required String userId})
      : _clubService = clubService,
        _userId = userId,
        super(const ClubState()) {
    on<ClubLoadRequested>(_onLoadRequested);
    on<ClubDetailLoadRequested>(_onDetailLoadRequested);
    on<ClubCreateRequested>(_onCreateRequested);
    on<ClubJoinRequested>(_onJoinRequested);
    on<ClubSelected>(_onSelected);
    on<ClubMembersLoadRequested>(_onMembersLoadRequested);
    on<ClubMemberRoleChanged>(_onMemberRoleChanged);
    on<ClubMemberRemoved>(_onMemberRemoved);
  }

  final ClubService _clubService;
  final String _userId;

  Future<void> _onLoadRequested(
    ClubLoadRequested event,
    Emitter<ClubState> emit,
  ) async {
    emit(state.copyWith(status: ClubStatus.loading));
    await emit.forEach<List<Club>>(
      _clubService.getMyClubs(_userId),
      onData: (clubs) => state.copyWith(
        status: ClubStatus.loaded,
        clubs: clubs,
      ),
      onError: (_, __) => state.copyWith(status: ClubStatus.failure),
    );
  }

  Future<void> _onDetailLoadRequested(
    ClubDetailLoadRequested event,
    Emitter<ClubState> emit,
  ) async {
    final club = await _clubService.getClub(event.clubId);
    if (club != null) {
      emit(state.copyWith(selectedClub: club));
    }
  }

  Future<void> _onCreateRequested(
    ClubCreateRequested event,
    Emitter<ClubState> emit,
  ) async {
    emit(state.copyWith(createStatus: ClubCreateStatus.submitting));
    try {
      await _clubService.createClub(event.name, _userId);
      emit(state.copyWith(createStatus: ClubCreateStatus.success));
      // Reset create status
      emit(state.copyWith(createStatus: ClubCreateStatus.initial));
    } catch (e) {
      emit(state.copyWith(
        createStatus: ClubCreateStatus.failure,
        errorMessage: 'Kon club niet aanmaken. Probeer het opnieuw.',
      ));
    }
  }

  Future<void> _onJoinRequested(
    ClubJoinRequested event,
    Emitter<ClubState> emit,
  ) async {
    emit(state.copyWith(createStatus: ClubCreateStatus.submitting));
    try {
      await _clubService.joinClub(event.inviteCode);
      emit(state.copyWith(createStatus: ClubCreateStatus.success));
      emit(state.copyWith(createStatus: ClubCreateStatus.initial));
    } catch (e) {
      emit(state.copyWith(
        createStatus: ClubCreateStatus.failure,
        errorMessage: 'Ongeldige uitnodigingscode.',
      ));
    }
  }

  void _onSelected(ClubSelected event, Emitter<ClubState> emit) {
    emit(state.copyWith(selectedClub: event.club));
  }

  Future<void> _onMembersLoadRequested(
    ClubMembersLoadRequested event,
    Emitter<ClubState> emit,
  ) async {
    await emit.forEach<List<ClubMember>>(
      _clubService.getClubMembers(event.clubId),
      onData: (members) {
        final myMembership = members
            .where((m) => m.userUid == _userId)
            .firstOrNull;
        return state.copyWith(
          members: members,
          myMembership: myMembership,
        );
      },
      onError: (_, __) => state,
    );
  }

  Future<void> _onMemberRoleChanged(
    ClubMemberRoleChanged event,
    Emitter<ClubState> emit,
  ) async {
    try {
      await _clubService.updateMemberRole(event.memberId, event.newRole);
    } catch (_) {
      // Members stream will reflect current state
    }
  }

  Future<void> _onMemberRemoved(
    ClubMemberRemoved event,
    Emitter<ClubState> emit,
  ) async {
    try {
      await _clubService.removeMember(event.memberId);
    } catch (_) {
      // Members stream will reflect current state
    }
  }
}
