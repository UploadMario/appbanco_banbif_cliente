import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/api_config.dart';
import 'data/supabase_config.dart';
import 'navigation/app_routes.dart';
import 'ui/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('[CORE] baseUrl = ${ApiConfig.baseUrl}');

  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  } else {
    debugPrint('[SUPABASE] SDK no inicializado; la app usa Core API.');
  }

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
