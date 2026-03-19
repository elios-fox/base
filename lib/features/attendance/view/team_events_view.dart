import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/models/team_event.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../bloc/event_list_bloc.dart';
import '../widgets/event_card.dart';

class TeamEventsView extends StatelessWidget {
  const TeamEventsView({
    super.key,
    required this.teamId,
    required this.teamName,
  });

  final String teamId;
  final String teamName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(teamName)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateEventDialog(context),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<EventListBloc, EventListState>(
        builder: (context, state) {
          return switch (state.status) {
            EventListStatus.initial ||
            EventListStatus.loading =>
              const LoadingIndicator(),
            EventListStatus.failure => ErrorView(
                message: 'Kon evenementen niet laden.',
                onRetry: () {
                  context
                      .read<EventListBloc>()
                      .add(EventListLoadRequested(teamId: teamId));
                },
              ),
            EventListStatus.loaded => state.events.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.event_outlined,
                              size: 64, color: AppColors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Nog geen evenementen.',
                            style: TextStyle(fontSize: 18, color: AppColors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Voeg een training of wedstrijd toe.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                : _buildEventList(context, state.events),
          };
        },
      ),
    );
  }

  Widget _buildEventList(BuildContext context, List<TeamEvent> events) {
    final now = DateTime.now();
    final upcoming = events.where((e) => e.dateTime.isAfter(now)).toList();
    final past = events.where((e) => e.dateTime.isBefore(now)).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (upcoming.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Aankomend',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          ...upcoming.map((event) => EventCard(
                event: event,
                onTap: () => context.go(
                  '/attendance/$teamId/event/${event.id}',
                ),
              )),
        ],
        if (past.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              'Afgelopen',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          ...past.reversed.map((event) => EventCard(
                event: event,
                onTap: () => context.go(
                  '/attendance/$teamId/event/${event.id}',
                ),
              )),
        ],
      ],
    );
  }

  void _showCreateEventDialog(BuildContext context) {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    var selectedType = EventType.training;
    var selectedDate = DateTime.now().add(const Duration(days: 1));
    var selectedTime = const TimeOfDay(hour: 19, minute: 0);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final dateFormat = DateFormat('EEE d MMM yyyy', 'nl_NL');
            return AlertDialog(
              title: const Text('Nieuw evenement'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SegmentedButton<EventType>(
                      segments: const [
                        ButtonSegment(
                          value: EventType.training,
                          label: Text('Training'),
                          icon: Icon(Icons.fitness_center),
                        ),
                        ButtonSegment(
                          value: EventType.wedstrijd,
                          label: Text('Wedstrijd'),
                          icon: Icon(Icons.emoji_events),
                        ),
                      ],
                      selected: {selectedType},
                      onSelectionChanged: (s) =>
                          setState(() => selectedType = s.first),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Titel',
                        hintText: selectedType == EventType.training
                            ? 'bijv. Training'
                            : 'bijv. vs. Tegenstander',
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Locatie (optioneel)',
                        hintText: 'bijv. Sportpark Noord',
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: Text(dateFormat.format(selectedDate)),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => selectedDate = date);
                        }
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.access_time),
                      title: Text(selectedTime.format(context)),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (time != null) {
                          setState(() => selectedTime = time);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Annuleren'),
                ),
                FilledButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isNotEmpty) {
                      final dateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );
                      final event = TeamEvent(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        teamId: teamId,
                        title: title,
                        type: selectedType,
                        dateTime: dateTime,
                        location: locationController.text.trim(),
                      );
                      // Access the bloc from the outer context
                      final bloc = BlocProvider.of<EventListBloc>(
                        dialogContext,
                        listen: false,
                      );
                      bloc.add(EventCreateRequested(event: event));
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: const Text('Toevoegen'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}