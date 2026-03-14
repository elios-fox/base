import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/checklist_run_bloc.dart';

class ChecklistDetailView extends StatelessWidget {
  const ChecklistDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChecklistRunBloc, ChecklistRunState>(
      builder: (context, state) {
        final checklist = state.checklist;
        if (checklist == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Checklist')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(checklist.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.swipe),
                tooltip: 'Wizard modus',
                onPressed: () =>
                    context.go('/bardienst/${checklist.id}/wizard'),
              ),
            ],
          ),
          body: ListView.builder(
            itemCount: checklist.items.length,
            itemBuilder: (context, index) {
              final item = checklist.items[index];
              return CheckboxListTile(
                value: state.checked.length > index
                    ? state.checked[index]
                    : false,
                onChanged: (_) => context
                    .read<ChecklistRunBloc>()
                    .add(ChecklistRunItemToggled(index)),
                title: Text(
                  item.title,
                  style: state.checked.length > index && state.checked[index]
                      ? const TextStyle(
                          decoration: TextDecoration.lineThrough)
                      : null,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
