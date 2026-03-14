import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../bloc/home_bloc.dart';
import '../widgets/home_greeting_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Base')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              child: Text(
                'Menu',
                style: TextStyle(fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.checklist),
              title: const Text('Checklists'),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/bardienst');
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
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return switch (state.status) {
            HomeStatus.initial || HomeStatus.loading => const LoadingIndicator(),
            HomeStatus.success => Center(
                child: HomeGreetingCard(greeting: state.greeting),
              ),
            HomeStatus.failure => ErrorView(
                message: 'Er ging iets mis.',
                onRetry: () =>
                    context.read<HomeBloc>().add(const HomeStarted()),
              ),
          };
        },
      ),
    );
  }
}