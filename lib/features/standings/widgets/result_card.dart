import 'package:flutter/material.dart';

import '../../../core/models/match_result.dart';

class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.result,
    this.onDelete,
  });

  final MatchResult result;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: _ResultIndicator(indicator: result.resultIndicator),
        title: Text(
          'vs ${result.opponentName}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${result.homeScore} - ${result.awayScore}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmDelete(context),
              )
            : null,
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Uitslag verwijderen'),
        content: Text(
          'Weet je zeker dat je de uitslag tegen '
          '${result.opponentName} wilt verwijderen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuleren'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Verwijderen',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      onDelete?.call();
    }
  }
}

class _ResultIndicator extends StatelessWidget {
  const _ResultIndicator({required this.indicator});

  final String indicator;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (indicator) {
      'W' => (const Color(0xFF2E7D32), 'W'),  // Groen - Winst
      'G' => (const Color(0xFFF57C00), 'G'),  // Oranje - Gelijk
      'V' => (Colors.red, 'V'),                // Rood - Verlies
      _ => (Colors.grey, '?'),
    };

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}
