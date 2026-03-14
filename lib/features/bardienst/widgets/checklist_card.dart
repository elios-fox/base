import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/checklist.dart';
import '../bloc/bardienst_bloc.dart';

class ChecklistCard extends StatelessWidget {
  const ChecklistCard({super.key, required this.checklist});

  final Checklist checklist;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(checklist.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Verwijderen'),
            content: Text('Weet je zeker dat je "${checklist.title}" wilt verwijderen?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Annuleren'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Verwijderen'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        context
            .read<BardienstBloc>()
            .add(BardienstChecklistDeleted(id: checklist.id));
      },
      child: Card(
        child: ListTile(
          title: Text(checklist.title),
          subtitle: Text('${checklist.items.length} items'),
          onTap: () => _showModeDialog(context),
          onLongPress: () => _showModeDialog(context),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Verwijderen'),
        content: Text(
            'Weet je zeker dat je "${checklist.title}" wilt verwijderen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuleren'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child:
                const Text('Verwijderen', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context
          .read<BardienstBloc>()
          .add(BardienstChecklistDeleted(id: checklist.id));
    }
  }

  void _showModeDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.checklist),
              title: const Text('Als checklist doorlopen'),
              onTap: () {
                Navigator.of(ctx).pop();
                context.go('/bardienst/${checklist.id}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.swipe),
              title: const Text('Als wizard doorlopen'),
              onTap: () {
                Navigator.of(ctx).pop();
                context.go('/bardienst/${checklist.id}/wizard');
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Bewerken'),
              onTap: () {
                Navigator.of(ctx).pop();
                context.go('/bardienst/edit/${checklist.id}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Verwijderen',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(ctx).pop();
                _confirmDelete(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
