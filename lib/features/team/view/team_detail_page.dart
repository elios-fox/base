import 'package:flutter/material.dart';

class TeamDetailPage extends StatelessWidget {
  const TeamDetailPage({super.key, required this.teamId});
  final String teamId;
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Team')), body: Center(child: Text('Team detail — Fase 2')));
}
