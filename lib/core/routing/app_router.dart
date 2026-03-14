import 'package:go_router/go_router.dart';

import '../../features/auth/view/login_page.dart';
import '../../features/auth/view/sign_up_page.dart';
import '../../features/home/view/home_page.dart';
import '../auth/auth_bloc.dart';
import 'go_router_refresh_stream.dart';
import 'route_names.dart';

GoRouter createAppRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final isAuthenticated =
          authBloc.state.status == AuthStatus.authenticated;
      final isOnLogin = state.matchedLocation == '/login' ||
          state.matchedLocation == '/sign-up';

      // Still loading auth state — don't redirect yet.
      if (authBloc.state.status == AuthStatus.unknown) return null;

      if (!isAuthenticated && !isOnLogin) return '/login';
      if (isAuthenticated && isOnLogin) return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: RouteNames.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/sign-up',
        name: RouteNames.signUp,
        builder: (context, state) => const SignUpPage(),
      ),
    ],
  );
}
