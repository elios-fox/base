import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../services/attendance_service.dart';
import '../../../services/event_service.dart';
import '../../../core/models/team_event.dart';
import '../bloc/event_detail_bloc.dart';
import 'event_detail_view.dart';

class EventDetailPage extends StatelessWidget {
  const EventDetailPage({
    super.key,
    required this.eventId,
    required this.event,
  });

  final String eventId;
  final TeamEvent? event;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EventDetailBloc(
        attendanceService: locate<AttendanceService>(),
        eventService: locate<EventService>(),
      )..add(EventDetailLoadRequested(eventId: eventId, event: event)),
      child: const EventDetailView(),
    );
  }
}
