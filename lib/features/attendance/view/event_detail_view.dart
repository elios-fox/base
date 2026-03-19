import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/attendance.dart';
import '../../../core/models/team_event.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../bloc/event_detail_bloc.dart';
import '../widgets/attendance_tile.dart';

class EventDetailView extends StatelessWidget {
  const EventDetailView({super.key, this.event});

  final TeamEvent? event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE d MMMM yyyy', 'nl_NL');
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(event?.title ?? 'Evenement'),
      ),
      body: BlocBuilder<EventDetailBloc, EventDetailState>(
        builder: (context, state) {
          if (state.status == EventDetailStatus.initial ||
              state.status == EventDetailStatus.loading) {
            return const LoadingIndicator();
          }

          final displayEvent = event;
          final user = context.read<AuthBloc>().state.user!;
          final myAttendance = state.attendances
              .where((a) => a.userUid == user.uid)
              .firstOrNull;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Event info header
              if (displayEvent != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              displayEvent.type == EventType.training
                                  ? Icons.fitness_center
                                  : Icons.emoji_events,
                              color: displayEvent.type == EventType.training
                                  ? AppColors.training
                                  : AppColors.wedstrijd,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              displayEvent.type == EventType.training
                                  ? 'Training'
                                  : 'Wedstrijd',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: displayEvent.type == EventType.training
                                    ? AppColors.training
                                    : AppColors.wedstrijd,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 18),
                            const SizedBox(width: 8),
                            Text(dateFormat.format(displayEvent.dateTime)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 18),
                            const SizedBox(width: 8),
                            Text(timeFormat.format(displayEvent.dateTime)),
                          ],
                        ),
                        if (displayEvent.location.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 18),
                              const SizedBox(width: 8),
                              Expanded(child: Text(displayEvent.location)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // My attendance
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jouw beschikbaarheid',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<AttendanceStatus>(
                        segments: const [
                          ButtonSegment(
                            value: AttendanceStatus.aanwezig,
                            label: Text('Aanwezig'),
                            icon: Icon(Icons.check_circle_outline),
                          ),
                          ButtonSegment(
                            value: AttendanceStatus.onzeker,
                            label: Text('Onzeker'),
                            icon: Icon(Icons.help_outline),
                          ),
                          ButtonSegment(
                            value: AttendanceStatus.afwezig,
                            label: Text('Afwezig'),
                            icon: Icon(Icons.cancel_outlined),
                          ),
                        ],
                        selected: myAttendance != null
                            ? {myAttendance.status}
                            : const {},
                        emptySelectionAllowed: true,
                        onSelectionChanged: (selected) {
                          if (selected.isNotEmpty) {
                            context.read<EventDetailBloc>().add(
                                  AttendanceSubmitted(
                                    eventId: displayEvent?.id ?? '',
                                    userUid: user.uid,
                                    userName:
                                        user.displayName ?? user.email ?? 'Onbekend',
                                    status: selected.first,
                                  ),
                                );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatChip(
                        label: 'Aanwezig',
                        count: state.aanwezigCount,
                        color: AppColors.aanwezig,
                      ),
                      _StatChip(
                        label: 'Onzeker',
                        count: state.onzekerCount,
                        color: AppColors.wedstrijd,
                      ),
                      _StatChip(
                        label: 'Afwezig',
                        count: state.afwezigCount,
                        color: AppColors.afwezig,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Attendance list
              if (state.attendances.isNotEmpty) ...[
                Text(
                  'Reacties (${state.attendances.length})',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: state.attendances
                        .map((a) => AttendanceTile(attendance: a))
                        .toList(),
                  ),
                ),
              ] else
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'Nog niemand heeft gereageerd.',
                      style: TextStyle(color: AppColors.grey),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }
}