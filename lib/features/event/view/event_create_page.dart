import 'package:flutter/material.dart';

class EventCreatePage extends StatelessWidget {
  const EventCreatePage({super.key, required this.teamId});
  final String teamId;
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Evenement toevoegen')), body: Center(child: Text('Evenement toevoegen — Fase 3')));
}
