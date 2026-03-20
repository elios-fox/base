import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/attendance.dart';
import '../../../core/models/team_event.dart';
import '../../../services/attendance_service.dart';
import '../../../services/event_service.dart';

// Events
sealed class EventDetailEvent extends Equatable {
  const EventDetailEvent();

  @override
  List<Object?> get props => [];
}

final class EventDetailLoadRequested extends EventDetailEvent {
  const EventDetailLoadRequested({required this.eventId, this.event});
  final String eventId;
  final TeamEvent? event;

  @override
  List<Object?> get props => [eventId, event];
}

final class EventDetailAttendancesUpdated extends EventDetailEvent {
  const EventDetailAttendancesUpdated(this.attendances);
  final List<Attendance> attendances;

  @override
  List<Object?> get props => [attendances];
}

final class AttendanceSubmitted extends EventDetailEvent {
  const AttendanceSubmitted({
    required this.eventId,
    required this.userUid,
    required this.userName,
    required this.status,
    this.reason = '',
  });

  final String eventId;
  final String userUid;
  final String userName;
  final AttendanceStatus status;
  final String reason;

  @override
  List<Object?> get props => [eventId, userUid, userName, status, reason];
}

// State
enum EventDetailStatus { initial, loading, loaded, failure }

final class EventDetailState extends Equatable {
  const EventDetailState({
    this.status = EventDetailStatus.initial,
    this.event,
    this.attendances = const [],
  });

  final EventDetailStatus status;
  final TeamEvent? event;
  final List<Attendance> attendances;

  int get aanwezigCount =>
      attendances.where((a) => a.status == AttendanceStatus.aanwezig).length;

  int get afwezigCount =>
      attendances.where((a) => a.status == AttendanceStatus.afwezig).length;

  int get onzekerCount =>
      attendances.where((a) => a.status == AttendanceStatus.onzeker).length;

  EventDetailState copyWith({
    EventDetailStatus? status,
    TeamEvent? event,
    List<Attendance>? attendances,
  }) {
    return EventDetailState(
      status: status ?? this.status,
      event: event ?? this.event,
      attendances: attendances ?? this.attendances,
    );
  }

  @override
  List<Object?> get props => [status, event, attendances];
}

// Bloc
class EventDetailBloc extends Bloc<EventDetailEvent, EventDetailState> {
  EventDetailBloc({
    required AttendanceService attendanceService,
    required EventService eventService,
  })  : _attendanceService = attendanceService,
        _eventService = eventService,
        super(const EventDetailState()) {
    on<EventDetailLoadRequested>(_onLoadRequested);
    on<EventDetailAttendancesUpdated>(_onAttendancesUpdated);
    on<AttendanceSubmitted>(_onAttendanceSubmitted);
  }

  final AttendanceService _attendanceService;
  final EventService _eventService;
  StreamSubscription<List<Attendance>>? _subscription;

  Future<void> _onLoadRequested(
    EventDetailLoadRequested event,
    Emitter<EventDetailState> emit,
  ) async {
    emit(state.copyWith(status: EventDetailStatus.loading));

    // Use passed event or fetch from service
    final teamEvent =
        event.event ?? await _eventService.getEvent(event.eventId);
    if (teamEvent != null) {
      emit(state.copyWith(event: teamEvent));
    }

    await _subscription?.cancel();
    _subscription = _attendanceService.getAttendances(event.eventId).listen(
          (attendances) => add(EventDetailAttendancesUpdated(attendances)),
        );
  }

  void _onAttendancesUpdated(
    EventDetailAttendancesUpdated event,
    Emitter<EventDetailState> emit,
  ) {
    emit(state.copyWith(
      status: EventDetailStatus.loaded,
      attendances: event.attendances,
    ));
  }

  Future<void> _onAttendanceSubmitted(
    AttendanceSubmitted event,
    Emitter<EventDetailState> emit,
  ) async {
    await _attendanceService.submitAttendance(
      eventId: event.eventId,
      userId: event.userUid,
      userName: event.userName,
      status: event.status,
      reason: event.reason,
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
