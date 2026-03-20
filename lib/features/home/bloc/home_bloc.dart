import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/team.dart';
import '../../../core/models/team_event.dart';
import '../../../services/event_service.dart';
import '../../../services/team_service.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required TeamService teamService,
    required EventService eventService,
    required String userId,
    required String displayName,
  })  : _teamService = teamService,
        _eventService = eventService,
        _userId = userId,
        _displayName = displayName,
        super(const HomeState()) {
    on<HomeStarted>(_onStarted);
  }

  final TeamService _teamService;
  final EventService _eventService;
  final String _userId;
  final String _displayName;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));

    // Build greeting based on time of day
    final hour = DateTime.now().hour;
    final timeGreeting = hour < 12
        ? 'Goedemorgen'
        : hour < 18
            ? 'Goedemiddag'
            : 'Goedenavond';
    final greeting = _displayName.isNotEmpty
        ? '$timeGreeting, $_displayName!'
        : '$timeGreeting!';

    // Listen to teams stream for real-time updates
    await emit.forEach<List<Team>>(
      _teamService.getTeams(_userId),
      onData: (teams) {
        // Also fetch upcoming events (non-stream, done once per team update)
        _fetchUpcomingEvents(emit);
        return state.copyWith(
          status: HomeStatus.success,
          greeting: greeting,
          teams: teams,
        );
      },
      onError: (_, __) => state.copyWith(status: HomeStatus.failure),
    );
  }

  Future<void> _fetchUpcomingEvents(Emitter<HomeState> emit) async {
    try {
      final events = await _eventService.getUpcomingEvents(_userId);
      // Only show next 5 events
      final upcoming = events.take(5).toList();
      emit(state.copyWith(upcomingEvents: upcoming));
    } catch (_) {
      // Non-critical, don't fail the whole page
    }
  }
}
