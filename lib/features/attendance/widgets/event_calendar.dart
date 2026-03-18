import 'package:flutter/material.dart';

import '../../../core/models/team_event.dart';

class EventCalendar extends StatefulWidget {
  const EventCalendar({
    super.key,
    required this.events,
    required this.onDaySelected,
    this.selectedDay,
  });

  final List<TeamEvent> events;
  final ValueChanged<DateTime?> onDaySelected;
  final DateTime? selectedDay;

  @override
  State<EventCalendar> createState() => _EventCalendarState();
}

class _EventCalendarState extends State<EventCalendar> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstWeekday =
        DateTime(_currentMonth.year, _currentMonth.month, 1).weekday;
    final today = DateTime.now();

    // Map event days
    final eventDays = <int, List<EventType>>{};
    for (final event in widget.events) {
      if (event.dateTime.year == _currentMonth.year &&
          event.dateTime.month == _currentMonth.month) {
        eventDays.putIfAbsent(event.dateTime.day, () => []).add(event.type);
      }
    }

    const weekDays = ['Ma', 'Di', 'Wo', 'Do', 'Vr', 'Za', 'Zo'];
    final monthNames = [
      'Januari', 'Februari', 'Maart', 'April', 'Mei', 'Juni',
      'Juli', 'Augustus', 'September', 'Oktober', 'November', 'December',
    ];

    return Column(
      children: [
        // Month navigator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  _currentMonth = DateTime(
                    _currentMonth.year,
                    _currentMonth.month - 1,
                  );
                });
              },
            ),
            Text(
              '${monthNames[_currentMonth.month - 1]} ${_currentMonth.year}',
              style: theme.textTheme.titleMedium,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  _currentMonth = DateTime(
                    _currentMonth.year,
                    _currentMonth.month + 1,
                  );
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Weekday headers
        Row(
          children: weekDays
              .map((d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 4),

        // Calendar grid
        ...List.generate(6, (week) {
          return Row(
            children: List.generate(7, (weekday) {
              final dayIndex = week * 7 + weekday - (firstWeekday - 2);
              if (dayIndex < 1 || dayIndex > daysInMonth) {
                return const Expanded(child: SizedBox(height: 44));
              }

              final date = DateTime(
                  _currentMonth.year, _currentMonth.month, dayIndex);
              final isToday = date.day == today.day &&
                  date.month == today.month &&
                  date.year == today.year;
              final isSelected = widget.selectedDay != null &&
                  date.day == widget.selectedDay!.day &&
                  date.month == widget.selectedDay!.month &&
                  date.year == widget.selectedDay!.year;
              final dayEvents = eventDays[dayIndex];

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (isSelected) {
                      widget.onDaySelected(null);
                    } else {
                      widget.onDaySelected(date);
                    }
                  },
                  child: Container(
                    height: 44,
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : null,
                      border: isToday && !isSelected
                          ? Border.all(color: theme.colorScheme.primary)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$dayIndex',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : null,
                            fontWeight:
                                isToday ? FontWeight.bold : null,
                          ),
                        ),
                        if (dayEvents != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (dayEvents.contains(EventType.training))
                                Container(
                                  width: 5,
                                  height: 5,
                                  margin: const EdgeInsets.only(right: 1),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? theme.colorScheme.onPrimary
                                        : Colors.blue,
                                  ),
                                ),
                              if (dayEvents.contains(EventType.wedstrijd))
                                Container(
                                  width: 5,
                                  height: 5,
                                  margin: const EdgeInsets.only(left: 1),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? theme.colorScheme.onPrimary
                                        : Colors.orange,
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ],
    );
  }
}
