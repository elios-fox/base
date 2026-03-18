import 'package:flutter/material.dart';

import '../../../core/models/team.dart';

class TeamCard extends StatelessWidget {
  const TeamCard({
    super.key,
    required this.team,
    required this.onTap,
    this.onDelete,
  });

  final Team team;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.groups,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          team.name,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text('${team.memberUids.length} leden'),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              )
            : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}