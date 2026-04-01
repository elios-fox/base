import 'package:flutter/material.dart';
import '../../../core/models/team_event.dart';

class EventDetailPage extends StatelessWidget {
  const EventDetailPage({super.key, required this.eventId, this.event});
  final String eventId;
  final TeamEvent? event;
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(event?.title ?? 'Evenement')), body: Center(child: Text('Evenement detail — Fase 3')));
}
