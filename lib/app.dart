import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/auth/auth_bloc.dart';
import 'core/auth/auth_repository.dart';
import 'core/di/injection.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_bloc.dart';

class ClubHubApp extends StatefulWidget {
  const ClubHubApp({super.key});

  @override
  State<ClubHubApp> createState() => _ClubHubAppState();
}

class _ClubHubAppState extends State<ClubHubApp> {
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(authRepository: locate<AuthRepository>())
      ..add(const AuthSubscriptionRequested());
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider(create: (_) => ThemeBloc()..add(const ThemeLoaded())),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final router = createAppRouter(_authBloc);
          return MaterialApp.router(
            title: 'ClubHub',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeState.themeMode,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
