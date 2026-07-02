import 'package:flutter/material.dart';

import '../../navigation/app_routes.dart';
import '../../ui/theme/app_colors.dart';
import '../../viewmodel/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController dniController =
      TextEditingController(text: '74253618');
  final TextEditingController passwordController =
      TextEditingController(text: '123456');
  final AuthViewModel viewModel = AuthViewModel();

  @override
  void dispose() {
    dniController.dispose();
    passwordController.dispose();
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: AnimatedBuilder(
        animation: viewModel,
        builder: (context, _) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.secondary,
                  AppColors.dark,
                  AppColors.accent,
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.78),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.22),
                            blurRadius: 30,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Image.asset(
                              'assets/banbif.png',
                              height: 56,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 26),
                          const Text(
                            'Hola de nuevo',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Ingresa a tu banca móvil BanBif.',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 15),
                          ),
                          const SizedBox(height: 28),
                          TextField(
                            controller: dniController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'DNI / Usuario',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                          ),
                          const SizedBox(height: 14),
                          if (viewModel.error != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                viewModel.error!,
                                style: const TextStyle(color: AppColors.error),
                              ),
                            ),
                          if (viewModel.coreStatus != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                viewModel.coreStatus!,
                                style: const TextStyle(color: AppColors.success),
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          ElevatedButton(
                            onPressed: viewModel.loading
                                ? null
                                : () async {
                                    final ok = await viewModel.login(
                                        dniController.text,
                                        passwordController.text);
                                    if (!context.mounted) return;
                                    if (!ok) return;
                                    Navigator.pushReplacementNamed(
                                      context,
                                      AppRoutes.dashboard,
                                      arguments: viewModel.usuario,
                                    );
                                  },
                            child: Text(viewModel.loading
                                ? 'Conectando...'
                                : 'Ingresar'),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              TextButton.icon(
                                onPressed: viewModel.checkingCore
                                    ? null
                                    : viewModel.probarConexionCore,
                                icon: viewModel.checkingCore
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.cloud_done_outlined),
                                label: const Text('Probar conexion Core'),
                              ),
                              TextButton.icon(
                                onPressed: viewModel.limpiarSesion,
                                icon: const Icon(Icons.cleaning_services_outlined),
                                label: const Text('Limpiar sesion'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
