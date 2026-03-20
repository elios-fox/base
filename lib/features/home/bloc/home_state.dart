part of 'home_bloc.dart';

enum HomeStatus { initial, loading, success, failure }

final class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.greeting = '',
    this.teams = const [],
    this.upcomingEvents = const [],
  });

  final HomeStatus status;
  final String greeting;
  final List<Team> teams;
  final List<TeamEvent> upcomingEvents;

  HomeState copyWith({
    HomeStatus? status,
    String? greeting,
    List<Team>? teams,
    List<TeamEvent>? upcomingEvents,
  }) {
    return HomeState(
      status: status ?? this.status,
      greeting: greeting ?? this.greeting,
      teams: teams ?? this.teams,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
    );
  }

  @override
  List<Object?> get props => [status, greeting, teams, upcomingEvents];
}
