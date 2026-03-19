import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/team.dart';
import '../../../core/supabase/supabase_storage.dart';
import '../../../core/utils/color_utils.dart';
import '../../../services/team_service.dart';

// Events
sealed class TeamDetailEvent extends Equatable {
  const TeamDetailEvent();
  @override
  List<Object?> get props => [];
}

final class TeamDetailLoadRequested extends TeamDetailEvent {
  const TeamDetailLoadRequested(this.teamId);
  final String teamId;
  @override
  List<Object?> get props => [teamId];
}

final class TeamDetailMemberRemoved extends TeamDetailEvent {
  const TeamDetailMemberRemoved({required this.teamId, required this.memberUid});
  final String teamId;
  final String memberUid;
  @override
  List<Object?> get props => [teamId, memberUid];
}

final class TeamDetailInviteCodeCopied extends TeamDetailEvent {
  const TeamDetailInviteCodeCopied(this.inviteCode);
  final String inviteCode;
  @override
  List<Object?> get props => [inviteCode];
}

final class TeamDetailPhotoUploadRequested extends TeamDetailEvent {
  const TeamDetailPhotoUploadRequested(this.imageFile);
  final File imageFile;
  @override
  List<Object?> get props => [imageFile];
}

// State
enum TeamDetailStatus { initial, loading, loaded, failure }

final class TeamDetailState extends Equatable {
  const TeamDetailState({
    this.status = TeamDetailStatus.initial,
    this.team,
    this.codeCopied = false,
    this.isUploadingPhoto = false,
  });

  final TeamDetailStatus status;
  final Team? team;
  final bool codeCopied;
  final bool isUploadingPhoto;

  TeamDetailState copyWith({
    TeamDetailStatus? status,
    Team? team,
    bool? codeCopied,
    bool? isUploadingPhoto,
  }) {
    return TeamDetailState(
      status: status ?? this.status,
      team: team ?? this.team,
      codeCopied: codeCopied ?? this.codeCopied,
      isUploadingPhoto: isUploadingPhoto ?? this.isUploadingPhoto,
    );
  }

  @override
  List<Object?> get props => [status, team, codeCopied, isUploadingPhoto];
}

// Bloc
class TeamDetailBloc extends Bloc<TeamDetailEvent, TeamDetailState> {
  TeamDetailBloc({
    required TeamService teamService,
    required StorageService storageService,
  })  : _teamService = teamService,
        _storageService = storageService,
        super(const TeamDetailState()) {
    on<TeamDetailLoadRequested>(_onLoadRequested);
    on<TeamDetailMemberRemoved>(_onMemberRemoved);
    on<TeamDetailInviteCodeCopied>(_onInviteCodeCopied);
    on<TeamDetailPhotoUploadRequested>(_onPhotoUploadRequested);
  }

  final TeamService _teamService;
  final StorageService _storageService;

  Future<void> _onLoadRequested(
    TeamDetailLoadRequested event,
    Emitter<TeamDetailState> emit,
  ) async {
    emit(state.copyWith(status: TeamDetailStatus.loading));
    try {
      final team = await _teamService.getTeam(event.teamId);
      emit(state.copyWith(status: TeamDetailStatus.loaded, team: team));
    } catch (_) {
      emit(state.copyWith(status: TeamDetailStatus.failure));
    }
  }

  Future<void> _onMemberRemoved(
    TeamDetailMemberRemoved event,
    Emitter<TeamDetailState> emit,
  ) async {
    if (state.team == null) return;
    final updatedMembers =
        state.team!.memberUids.where((uid) => uid != event.memberUid).toList();
    final updatedTeam = state.team!.copyWith(memberUids: updatedMembers);
    await _teamService.updateTeam(updatedTeam);
    emit(state.copyWith(team: updatedTeam));
  }

  Future<void> _onInviteCodeCopied(
    TeamDetailInviteCodeCopied event,
    Emitter<TeamDetailState> emit,
  ) async {
    await Clipboard.setData(ClipboardData(text: event.inviteCode));
    emit(state.copyWith(codeCopied: true));
    await Future.delayed(const Duration(seconds: 2));
    emit(state.copyWith(codeCopied: false));
  }

  Future<void> _onPhotoUploadRequested(
    TeamDetailPhotoUploadRequested event,
    Emitter<TeamDetailState> emit,
  ) async {
    if (state.team == null) return;
    emit(state.copyWith(isUploadingPhoto: true));
    try {
      final teamId = state.team!.id;
      final storagePath = 'teams/$teamId/photo.jpg';
      final photoUrl = await _storageService.uploadImage(storagePath, event.imageFile);
      final dominantColor = await ColorUtils.dominantColorFromUrl(photoUrl);
      final hexColor = ColorUtils.colorToHex(dominantColor);
      await _teamService.updateTeamPhoto(teamId, photoUrl, hexColor);
      final updatedTeam = state.team!.copyWith(
        photoUrl: photoUrl,
        dominantColor: hexColor,
      );
      emit(state.copyWith(team: updatedTeam, isUploadingPhoto: false));
    } catch (_) {
      emit(state.copyWith(isUploadingPhoto: false));
    }
  }
}
