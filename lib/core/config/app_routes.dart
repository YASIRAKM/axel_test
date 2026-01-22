import 'package:axel_todo_test/features/splash/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/todo/presentation/pages/home_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String settings = '/settings';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashPage(),
    home: (context) => const HomePage(),
    settings: (context) => const SettingsPage(),
    login: (context) => const LoginPage(),
    register: (context) => const RegisterPage(),
    profile: (context) => const ProfilePage(),
  };
}
