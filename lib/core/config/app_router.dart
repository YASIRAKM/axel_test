import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/todo/presentation/pages/home_page.dart';
import 'app_routes.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
class AppRouter {
  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  late final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuth = authState is AuthAuthenticated;
      final isUnAuth = authState is AuthUnauthenticated;

      final isSplash = state.matchedLocation == AppRoutes.splash;
      final isLoggingIn = state.matchedLocation == AppRoutes.login;
      final isRegistering = state.matchedLocation == AppRoutes.register;

      if (isSplash) {
        if (isAuth) return AppRoutes.home;
        if (isUnAuth) return AppRoutes.login;
        return null;
      }

      if (isLoggingIn || isRegistering) {
        if (isAuth) {
          return AppRoutes.home;
        }
      }

      if (!isAuth && !isLoggingIn && !isRegistering && !isSplash) {
        return AppRoutes.login;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
