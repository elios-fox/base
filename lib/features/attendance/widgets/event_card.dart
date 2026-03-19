import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/team_event.dart';
import '../../../core/theme/app_colors.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  final TeamEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTraining = event.type == EventType.training;
    final dateFormat = DateFormat('EEE d MMM', 'nl_NL');
    final timeFormat = DateFormat('HH:mm');
    final isPast = event.dateTime.isBefore(DateTime.now());

    return Card(
      color: isPast ? theme.colorScheme.surfaceContainerLow : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isTraining
              ? AppColors.trainingBg
              : AppColors.wedstrijdBg,
          child: Icon(
            isTraining ? Icons.fitness_center : Icons.emoji_events,
            color: isTraining ? AppColors.training : AppColors.wedstrijd,
          ),
        ),
        title: Text(
          event.title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isPast ? theme.colorScheme.onSurfaceVariant : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${dateFormat.format(event.dateTime)} om ${timeFormat.format(event.dateTime)}',
            ),
            if (event.location.isNotEmpty)
              Text(
                event.location,
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
        trailing: Chip(
          label: Text(
            isTraining ? 'Training' : 'Wedstrijd',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isTraining ? AppColors.training : AppColors.wedstrijd,
            ),
          ),
          backgroundColor: isTraining
              ? AppColors.trainingBgLight
              : AppColors.wedstrijdBgLight,
          side: BorderSide.none,
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
        isThreeLine: event.location.isNotEmpty,
        onTap: onTap,
      ),
    );
  }
}
