import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/team_event.dart';
import '../../../services/event_service.dart';

// Events
sealed class EventListEvent extends Equatable {
  const EventListEvent();

  @override
  List<Object?> get props => [];
}

final class EventListLoadRequested extends EventListEvent {
  const EventListLoadRequested({required this.teamId});
  final String teamId;

  @override
  List<Object?> get props => [teamId];
}

final class EventListUpdated extends EventListEvent {
  const EventListUpdated(this.events);
  final List<TeamEvent> events;

  @override
  List<Object?> get props => [events];
}

final class EventCreateRequested extends EventListEvent {
  const EventCreateRequested({required this.event});
  final TeamEvent event;

  @override
  List<Object?> get props => [event];
}

final class EventDeleteRequested extends EventListEvent {
  const EventDeleteRequested(this.eventId);
  final String eventId;

  @override
  List<Object?> get props => [eventId];
}

// State
enum EventListStatus { initial, loading, loaded, failure }

final class EventListState extends Equatable {
  const EventListState({
    this.status = EventListStatus.initial,
    this.events = const [],
  });

  final EventListStatus status;
  final List<TeamEvent> events;

  EventListState copyWith({
    EventListStatus? status,
    List<TeamEvent>? events,
  }) {
    return EventListState(
      status: status ?? this.status,
      events: events ?? this.events,
    );
  }

  @override
  List<Object?> get props => [status, events];
}

// Bloc
class EventListBloc extends Bloc<EventListEvent, EventListState> {
  EventListBloc({required EventService eventService})
      : _eventService = eventService,
        super(const EventListState()) {
    on<EventListLoadRequested>(_onLoadRequested);
    on<EventListUpdated>(_onUpdated);
    on<EventCreateRequested>(_onCreateRequested);
    on<EventDeleteRequested>(_onDeleteRequested);
  }

  final EventService _eventService;
  StreamSubscription<List<TeamEvent>>? _subscription;

  Future<void> _onLoadRequested(
    EventListLoadRequested event,
    Emitter<EventListState> emit,
  ) async {
    emit(state.copyWith(status: EventListStatus.loading));
    await _subscription?.cancel();
    _subscription = _eventService.getEvents(event.teamId).listen(
          (events) => add(EventListUpdated(events)),
        );
  }

  void _onUpdated(
    EventListUpdated event,
    Emitter<EventListState> emit,
  ) {
    emit(state.copyWith(
      status: EventListStatus.loaded,
      events: event.events,
    ));
  }

  Future<void> _onCreateRequested(
    EventCreateRequested event,
    Emitter<EventListState> emit,
  ) async {
    await _eventService.createEvent(event.event);
  }

  Future<void> _onDeleteRequested(
    EventDeleteRequested event,
    Emitter<EventListState> emit,
  ) async {
    await _eventService.deleteEvent(event.eventId);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
