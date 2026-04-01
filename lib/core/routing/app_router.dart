import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_bloc.dart';
import '../models/team_event.dart';
import '../../features/auth/view/login_page.dart';
import '../../features/auth/view/sign_up_page.dart';
import '../../features/auth/view/forgot_password_page.dart';
import '../../features/home/view/home_page.dart';
import '../../features/team/view/team_list_page.dart';
import '../../features/team/view/team_create_page.dart';
import '../../features/team/view/team_detail_page.dart';
import '../../features/team/view/team_join_page.dart';
import '../../features/team/view/team_invite_page.dart';
import '../../features/event/view/event_create_page.dart';
import '../../features/event/view/event_detail_page.dart';
import '../../features/profile/view/profile_page.dart';
import '../../features/profile/view/password_page.dart';
import '../../features/profile/view/notifications_page.dart';
import '../../features/shell/view/shell_page.dart';
import 'go_router_refresh_stream.dart';
import 'route_names.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter(AuthBloc authBloc) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final isAuthenticated = authBloc.state.status == AuthStatus.authenticated;
      final isOnAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/sign-up' ||
          state.matchedLocation == '/forgot-password';
      if (authBloc.state.status == AuthStatus.unknown) return null;
      if (!isAuthenticated && !isOnAuth) return '/login';
      if (isAuthenticated && isOnAuth) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', name: RouteNames.login, parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const LoginPage()),
      GoRoute(path: '/sign-up', name: RouteNames.signUp, parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const SignUpPage()),
      GoRoute(path: '/forgot-password', name: RouteNames.forgotPassword, parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const ForgotPasswordPage()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => ShellPage(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/', name: RouteNames.home, builder: (context, state) => const HomePage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/teams', name: RouteNames.teams, builder: (context, state) => const TeamListPage(), routes: [
              GoRoute(path: 'join', name: RouteNames.teamJoin, builder: (context, state) => const TeamJoinPage()),
              GoRoute(path: ':teamId', name: RouteNames.teamDetail, builder: (context, state) => TeamDetailPage(teamId: state.pathParameters['teamId']!), routes: [
                GoRoute(path: 'invite', name: RouteNames.teamInvite, builder: (context, state) => TeamInvitePage(teamId: state.pathParameters['teamId']!)),
                GoRoute(path: 'event/create', name: RouteNames.eventCreate, builder: (context, state) => EventCreatePage(teamId: state.pathParameters['teamId']!)),
                GoRoute(path: 'event/:eventId', name: RouteNames.eventDetail, builder: (context, state) => EventDetailPage(eventId: state.pathParameters['eventId']!, event: state.extra as TeamEvent?)),
              ]),
            ]),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', name: RouteNames.profile, builder: (context, state) => const ProfilePage(), routes: [
              GoRoute(path: 'password', name: RouteNames.profilePassword, builder: (context, state) => const PasswordPage()),
              GoRoute(path: 'notifications', name: RouteNames.profileNotifications, builder: (context, state) => const NotificationsPage()),
            ]),
          ]),
        ],
      ),
      GoRoute(path: '/team/create', name: RouteNames.teamCreate, parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const TeamCreatePage()),
    ],
  );
}
