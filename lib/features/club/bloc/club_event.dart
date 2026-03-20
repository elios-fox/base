part of 'club_bloc.dart';

sealed class ClubEvent extends Equatable {
  const ClubEvent();

  @override
  List<Object?> get props => [];
}

final class ClubLoadRequested extends ClubEvent {
  const ClubLoadRequested();
}

final class ClubDetailLoadRequested extends ClubEvent {
  const ClubDetailLoadRequested({required this.clubId});
  final String clubId;

  @override
  List<Object?> get props => [clubId];
}

final class ClubCreateRequested extends ClubEvent {
  const ClubCreateRequested({required this.name});
  final String name;

  @override
  List<Object?> get props => [name];
}

final class ClubJoinRequested extends ClubEvent {
  const ClubJoinRequested({required this.inviteCode});
  final String inviteCode;

  @override
  List<Object?> get props => [inviteCode];
}

final class ClubSelected extends ClubEvent {
  const ClubSelected({required this.club});
  final Club club;

  @override
  List<Object?> get props => [club];
}

final class ClubMembersLoadRequested extends ClubEvent {
  const ClubMembersLoadRequested({required this.clubId});
  final String clubId;

  @override
  List<Object?> get props => [clubId];
}

final class ClubMemberRoleChanged extends ClubEvent {
  const ClubMemberRoleChanged({
    required this.memberId,
    required this.newRole,
  });
  final String memberId;
  final ClubRole newRole;

  @override
  List<Object?> get props => [memberId, newRole];
}

final class ClubMemberRemoved extends ClubEvent {
  const ClubMemberRemoved({required this.memberId});
  final String memberId;

  @override
  List<Object?> get props => [memberId];
}
