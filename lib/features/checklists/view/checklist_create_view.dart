import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/checklist_item.dart';
import '../bloc/checklist_create_bloc.dart';
import '../widgets/checklist_item_editor.dart';

class ChecklistCreateView extends StatefulWidget {
  const ChecklistCreateView({super.key});

  @override
  State<ChecklistCreateView> createState() => _ChecklistCreateViewState();
}

class _ChecklistCreateViewState extends State<ChecklistCreateView> {
  final _titleController = TextEditingController();
  bool _titleInitialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChecklistCreateBloc, ChecklistCreateState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == ChecklistCreateStatus.success) {
          context.go('/checklists');
        } else if (state.status == ChecklistCreateStatus.failure &&
            state.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage)),
          );
        }
      },
      child: BlocBuilder<ChecklistCreateBloc, ChecklistCreateState>(
        builder: (context, state) {
          if (!_titleInitialized && state.title.isNotEmpty) {
            _titleController.text = state.title;
            _titleInitialized = true;
          }

          if (state.status == ChecklistCreateStatus.loading) {
            return Scaffold(
              appBar: AppBar(title: const Text('Checklist')),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Checklist'),
              actions: [
                IconButton(
                  onPressed: state.status == ChecklistCreateStatus.saving
                      ? null
                      : () => context
                          .read<ChecklistCreateBloc>()
                          .add(const ChecklistCreateSubmitted()),
                  icon: state.status == ChecklistCreateStatus.saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                ),
              ],
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Titel',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => context
                        .read<ChecklistCreateBloc>()
                        .add(ChecklistCreateTitleChanged(value)),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return ListTile(
                        leading: const Icon(Icons.check_box_outline_blank),
                        title: Text(item.title),
                        subtitle: item.description.isNotEmpty
                            ? Text(
                                item.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => context
                              .read<ChecklistCreateBloc>()
                              .add(ChecklistCreateItemRemoved(index)),
                        ),
                        onTap: () => _editItem(context, index, item),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _addItem(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Stap toevoegen'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: state.status == ChecklistCreateStatus.saving
                          ? null
                          : () => context
                              .read<ChecklistCreateBloc>()
                              .add(const ChecklistCreateSubmitted()),
                      icon: state.status == ChecklistCreateStatus.saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: const Text('Checklist opslaan'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _addItem(BuildContext context) async {
    final bloc = context.read<ChecklistCreateBloc>();
    final newItem = ChecklistItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '',
      order: bloc.state.items.length,
    );

    final result = await Navigator.of(context).push<ChecklistItem>(
      MaterialPageRoute(
        builder: (_) => ChecklistItemEditorPage(item: newItem),
      ),
    );

    if (result != null && context.mounted) {
      bloc.add(ChecklistCreateItemAdded(result));
    }
  }

  Future<void> _editItem(
    BuildContext context,
    int index,
    ChecklistItem item,
  ) async {
    final result = await Navigator.of(context).push<ChecklistItem>(
      MaterialPageRoute(
        builder: (_) => ChecklistItemEditorPage(item: item, isNew: false),
      ),
    );

    if (result != null && context.mounted) {
      context
          .read<ChecklistCreateBloc>()
          .add(ChecklistCreateItemUpdated(index, result));
    }
  }
}
