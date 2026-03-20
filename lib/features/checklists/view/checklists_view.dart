import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../bloc/checklists_bloc.dart';
import '../widgets/checklist_card.dart';

class ChecklistsView extends StatelessWidget {
  const ChecklistsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checklists')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              child: Text('Menu', style: TextStyle(fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/');
              },
            ),
            ListTile(
              leading: const Icon(Icons.checklist),
              title: const Text('Checklists'),
              selected: true,
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.groups),
              title: const Text('Aanwezigheid'),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/attendance');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Uitloggen'),
              onTap: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(const AuthLogoutRequested());
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/checklists/create');
          if (context.mounted) {
            final uid = context.read<AuthBloc>().state.user!.uid;
            context
                .read<ChecklistsBloc>()
                .add(ChecklistsLoadRequested(ownerUid: uid));
          }
        },
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<ChecklistsBloc, ChecklistsState>(
        builder: (context, state) {
          return switch (state.status) {
            ChecklistsStatus.initial ||
            ChecklistsStatus.loading =>
              const LoadingIndicator(),
            ChecklistsStatus.failure => ErrorView(
                message: 'Kon checklists niet laden.',
                onRetry: () {
                  final uid = context.read<AuthBloc>().state.user!.uid;
                  context
                      .read<ChecklistsBloc>()
                      .add(ChecklistsLoadRequested(ownerUid: uid));
                },
              ),
            ChecklistsStatus.loaded => state.checklists.isEmpty
                ? const Center(
                    child: Text('Nog geen checklists. Maak er een aan!'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.checklists.length,
                    itemBuilder: (context, index) {
                      return ChecklistCard(
                        checklist: state.checklists[index],
                      );
                    },
                  ),
          };
        },
      ),
    );
  }
}
