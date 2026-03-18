import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/attendance/view/event_detail_page.dart';
import '../../features/attendance/view/join_team_page.dart';
import '../../features/attendance/view/team_detail_page.dart';
import '../../features/attendance/view/team_events_page.dart';
import '../../features/attendance/view/team_list_page.dart';
import '../../features/auth/view/login_page.dart';
import '../../features/auth/view/sign_up_page.dart';
import '../../features/bardienst/view/bardienst_page.dart';
import '../../features/bardienst/view/checklist_create_page.dart';
import '../../features/bardienst/view/checklist_detail_page.dart';
import '../../features/bardienst/view/checklist_wizard_page.dart';
import '../../features/home/view/home_page.dart';
import '../../features/profile/view/profile_page.dart';
import '../../features/shell/view/shell_page.dart';
import '../auth/auth_bloc.dart';
import 'go_router_refresh_stream.dart';
import 'route_names.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter(AuthBloc authBloc) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final isAuthenticated =
          authBloc.state.status == AuthStatus.authenticated;
      final isOnLogin = state.matchedLocation == '/login' ||
          state.matchedLocation == '/sign-up';

      if (authBloc.state.status == AuthStatus.unknown) return null;

      if (!isAuthenticated && !isOnLogin) return '/login';
      if (isAuthenticated && isOnLogin) return '/';

      return null;
    },
    routes: [
      // Auth routes (outside shell)
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/sign-up',
        name: RouteNames.signUp,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SignUpPage(),
      ),

      // Main app with bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ShellPage(navigationShell: navigationShell),
        branches: [
          // Tab 1: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: RouteNames.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),

          // Tab 2: Teams / Aanwezigheid
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/attendance',
                name: RouteNames.attendance,
                builder: (context, state) => const TeamListPage(),
                routes: [
                  GoRoute(
                    path: 'join',
                    name: RouteNames.joinTeam,
                    builder: (context, state) => const JoinTeamPage(),
                  ),
                  GoRoute(
                    path: ':teamId',
                    name: RouteNames.teamEvents,
                    builder: (context, state) => TeamEventsPage(
                      teamId: state.pathParameters['teamId']!,
                      teamName:
                          state.uri.queryParameters['name'] ?? 'Team',
                    ),
                    routes: [
                      GoRoute(
                        path: 'detail',
                        name: RouteNames.teamDetail,
                        builder: (context, state) => TeamDetailPage(
                          teamId: state.pathParameters['teamId']!,
                        ),
                      ),
                      GoRoute(
                        path: 'event/:eventId',
                        name: RouteNames.eventDetail,
                        builder: (context, state) => EventDetailPage(
                          eventId: state.pathParameters['eventId']!,
                          event: state.extra as dynamic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Tab 3: Profiel
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: RouteNames.profile,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),

      // Bardienst (accessible from anywhere)
      GoRoute(
        path: '/bardienst',
        name: RouteNames.bardienst,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BardienstPage(),
        routes: [
          GoRoute(
            path: 'create',
            name: RouteNames.checklistCreate,
            builder: (context, state) => const ChecklistCreatePage(),
          ),
          GoRoute(
            path: 'edit/:id',
            name: RouteNames.checklistEdit,
            builder: (context, state) => ChecklistCreatePage(
              checklistId: state.pathParameters['id'],
            ),
          ),
          GoRoute(
            path: ':id',
            name: RouteNames.checklistDetail,
            builder: (context, state) => ChecklistDetailPage(
              checklistId: state.pathParameters['id']!,
            ),
            routes: [
              GoRoute(
                path: 'wizard',
                name: RouteNames.checklistWizard,
                builder: (context, state) => ChecklistWizardPage(
                  checklistId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
