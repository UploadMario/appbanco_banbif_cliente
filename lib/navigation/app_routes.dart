import 'package:flutter/material.dart';

import '../view/auth/login_screen.dart';
import '../view/home/dashboard_screen.dart';

class AppRoutes {
  static const login = '/';
  static const dashboard = '/dashboard';

  static Map<String, WidgetBuilder> get routes => {
    login: (_) => const LoginScreen(),
    dashboard: (_) => const DashboardScreen(),
  };
}
