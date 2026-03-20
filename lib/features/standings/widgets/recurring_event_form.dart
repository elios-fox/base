import 'package:flutter/material.dart';

import '../../../core/models/recurring_pattern.dart';

/// Formulier-onderdeel voor terugkerende events.
/// Toont een toggle + frequentie selector + einddatum.
class RecurringEventForm extends StatefulWidget {
  const RecurringEventForm({
    super.key,
    required this.isRecurring,
    required this.onRecurringChanged,
    required this.onPatternChanged,
    this.initialPattern,
  });

  final bool isRecurring;
  final ValueChanged<bool> onRecurringChanged;
  final ValueChanged<RecurringPattern?> onPatternChanged;
  final RecurringPattern? initialPattern;

  @override
  State<RecurringEventForm> createState() => _RecurringEventFormState();
}

class _RecurringEventFormState extends State<RecurringEventForm> {
  late RecurringFrequency _frequency;
  late int _dayOfWeek;
  DateTime? _endDate;

  static const _dayNames = {
    1: 'Maandag',
    2: 'Dinsdag',
    3: 'Woensdag',
    4: 'Donderdag',
    5: 'Vrijdag',
    6: 'Zaterdag',
    7: 'Zondag',
  };

  @override
  void initState() {
    super.initState();
    _frequency =
        widget.initialPattern?.frequency ?? RecurringFrequency.weekly;
    _dayOfWeek = widget.initialPattern?.dayOfWeek ?? DateTime.now().weekday;
    _endDate = widget.initialPattern?.endDate;
  }

  void _notifyPatternChanged() {
    if (!widget.isRecurring || _endDate == null) {
      widget.onPatternChanged(null);
      return;
    }
    widget.onPatternChanged(RecurringPattern(
      frequency: _frequency,
      dayOfWeek: _dayOfWeek,
      endDate: _endDate!,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Terugkerend event'),
          subtitle: const Text('Herhaal dit event automatisch'),
          value: widget.isRecurring,
          onChanged: (value) {
            widget.onRecurringChanged(value);
            if (!value) {
              widget.onPatternChanged(null);
            }
          },
        ),
        if (widget.isRecurring) ...[
          const SizedBox(height: 8),

          // Frequentie
          DropdownButtonFormField<RecurringFrequency>(
            value: _frequency,
            decoration: const InputDecoration(
              labelText: 'Frequentie',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: RecurringFrequency.weekly,
                child: Text('Wekelijks'),
              ),
              DropdownMenuItem(
                value: RecurringFrequency.biweekly,
                child: Text('Tweewekelijks'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _frequency = value);
                _notifyPatternChanged();
              }
            },
          ),
          const SizedBox(height: 16),

          // Dag van de week
          DropdownButtonFormField<int>(
            value: _dayOfWeek,
            decoration: const InputDecoration(
              labelText: 'Dag van de week',
              border: OutlineInputBorder(),
            ),
            items: _dayNames.entries
                .map((e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _dayOfWeek = value);
                _notifyPatternChanged();
              }
            },
          ),
          const SizedBox(height: 16),

          // Einddatum
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Einddatum'),
            subtitle: Text(
              _endDate != null
                  ? '${_endDate!.day}-${_endDate!.month}-${_endDate!.year}'
                  : 'Selecteer een einddatum',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate:
                    _endDate ?? DateTime.now().add(const Duration(days: 90)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() => _endDate = date);
                _notifyPatternChanged();
              }
            },
          ),
        ],
      ],
    );
  }
}
