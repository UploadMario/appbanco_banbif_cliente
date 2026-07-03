import 'package:flutter/material.dart';

import 'data/api_config.dart';
import 'navigation/app_routes.dart';
import 'ui/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('[CORE] baseUrl = ${ApiConfig.baseUrl}');
  debugPrint('[CORE] App Cliente usa Core FastAPI para operaciones bancarias.');

  runApp(const BanBifClienteApp());
}

class BanBifClienteApp extends StatelessWidget {
  const BanBifClienteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BanBif Clientes',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}
