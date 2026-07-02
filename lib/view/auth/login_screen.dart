import 'package:flutter/material.dart';

import '../../navigation/app_routes.dart';
import '../../ui/components/app_components.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_spacing.dart';
import '../../ui/theme/app_text_styles.dart';
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
      body: AnimatedBuilder(
        animation: viewModel,
        builder: (context, _) {
          return Container(
            decoration: const BoxDecoration(gradient: AppColors.brandGradient),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.screen),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: AppCard(
                      padding: const EdgeInsets.all(AppSpacing.card),
                      color: Colors.white.withValues(alpha: 0.92),
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
                          const SizedBox(height: AppSpacing.xl),
                          const Text('Hola de nuevo', style: AppTextStyles.display),
                          const SizedBox(height: AppSpacing.sm),
                          const Text(
                            'Ingresa a tu banca movil BanBif.',
                            style: AppTextStyles.body,
                          ),
                          const SizedBox(height: AppSpacing.xxxl),
                          TextField(
                            controller: dniController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'DNI / Usuario',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Contrasena',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          if (viewModel.error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: _InlineMessage(
                                message: viewModel.error!,
                                color: AppColors.error,
                                icon: Icons.error_outline,
                              ),
                            ),
                          if (viewModel.coreStatus != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: _InlineMessage(
                                message: viewModel.coreStatus!,
                                color: AppColors.success,
                                icon: Icons.check_circle_outline,
                              ),
                            ),
                          PrimaryButton(
                            label: 'Ingresar',
                            icon: Icons.login,
                            loading: viewModel.loading,
                            onPressed: viewModel.loading
                                ? null
                                : () async {
                                    final ok = await viewModel.login(
                                      dniController.text,
                                      passwordController.text,
                                    );
                                    if (!context.mounted) return;
                                    if (!ok) return;
                                    Navigator.pushReplacementNamed(
                                      context,
                                      AppRoutes.dashboard,
                                      arguments: viewModel.usuario,
                                    );
                                  },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.xs,
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
                          const SizedBox(height: AppSpacing.sm),
                          const Text(
                            'Credenciales de prueba:\n74253618 / 123456',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption,
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

class _InlineMessage extends StatelessWidget {
  final String message;
  final Color color;
  final IconData icon;

  const _InlineMessage({
    required this.message,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyStrong.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
