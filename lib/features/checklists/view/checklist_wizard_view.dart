import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/checklist_wizard_bloc.dart';
import '../widgets/checklist_photo.dart';

class ChecklistWizardView extends StatelessWidget {
  const ChecklistWizardView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChecklistWizardBloc, ChecklistWizardState>(
      builder: (context, state) {
        final checklist = state.checklist;
        if (checklist == null || checklist.items.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Wizard')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final item = checklist.items[state.currentIndex];
        final total = checklist.items.length;
        final isCompleted = state.completed.length > state.currentIndex &&
            state.completed[state.currentIndex];

        return Scaffold(
          appBar: AppBar(
            title: Text(checklist.title),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4),
              child: LinearProgressIndicator(
                value: (state.currentIndex + 1) / total,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (item.photoUrl != null) ...[
                  ChecklistPhoto(
                    photoUrl: item.photoUrl!,
                    borderRadius: 12,
                  ),
                  const SizedBox(height: 24),
                ],
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    item.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => context
                      .read<ChecklistWizardBloc>()
                      .add(const ChecklistWizardItemCompleted()),
                  icon: Icon(isCompleted ? Icons.check_circle : Icons.circle_outlined),
                  label: Text(isCompleted ? 'Gereed' : 'Markeer als gereed'),
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        isCompleted ? Colors.green : null,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: state.currentIndex > 0
                            ? () => context
                                .read<ChecklistWizardBloc>()
                                .add(const ChecklistWizardPrevious())
                            : null,
                        child: const Text('Vorige'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: state.currentIndex < total - 1
                          ? FilledButton(
                              onPressed: () => context
                                  .read<ChecklistWizardBloc>()
                                  .add(const ChecklistWizardNext()),
                              child: const Text('Volgende'),
                            )
                          : FilledButton(
                              onPressed: () => context.go('/checklists'),
                              child: const Text('Voltooi'),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${state.currentIndex + 1} / $total',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
