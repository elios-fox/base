import 'package:flutter/material.dart';

class TeamInvitePage extends StatelessWidget {
  const TeamInvitePage({super.key, required this.teamId});
  final String teamId;
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Leden uitnodigen')), body: Center(child: Text('Leden uitnodigen — Fase 2')));
}
