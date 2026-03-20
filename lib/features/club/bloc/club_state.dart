part of 'club_bloc.dart';

enum ClubStatus { initial, loading, loaded, failure }

enum ClubCreateStatus { initial, submitting, success, failure }

final class ClubState extends Equatable {
  const ClubState({
    this.status = ClubStatus.initial,
    this.clubs = const [],
    this.selectedClub,
    this.members = const [],
    this.myMembership,
    this.createStatus = ClubCreateStatus.initial,
    this.errorMessage,
  });

  final ClubStatus status;
  final List<Club> clubs;
  final Club? selectedClub;
  final List<ClubMember> members;
  final ClubMember? myMembership;
  final ClubCreateStatus createStatus;
  final String? errorMessage;

  bool get isBestuur => myMembership?.isBestuur ?? false;
  bool get isTeamcaptain =>
      myMembership?.isTeamcaptain ?? false || isBestuur;

  ClubState copyWith({
    ClubStatus? status,
    List<Club>? clubs,
    Club? selectedClub,
    List<ClubMember>? members,
    ClubMember? myMembership,
    ClubCreateStatus? createStatus,
    String? errorMessage,
  }) {
    return ClubState(
      status: status ?? this.status,
      clubs: clubs ?? this.clubs,
      selectedClub: selectedClub ?? this.selectedClub,
      members: members ?? this.members,
      myMembership: myMembership ?? this.myMembership,
      createStatus: createStatus ?? this.createStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        clubs,
        selectedClub,
        members,
        myMembership,
        createStatus,
        errorMessage,
      ];
}
