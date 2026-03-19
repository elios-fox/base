import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/auth/auth_bloc.dart';
import 'core/auth/auth_repository.dart';
import 'core/di/injection.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(
        authRepository: locate<AuthRepository>(),
      )..add(const AuthSubscriptionRequested()),
      child: Builder(
        builder: (context) {
          final authBloc = context.read<AuthBloc>();
          return MaterialApp.router(
            title: 'ClubHub',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            routerConfig: createAppRouter(authBloc),
          );
        },
      ),
    );
  }
}
