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
  final TextEditingController dniController = TextEditingController(text: '74253618');
  final TextEditingController passwordController = TextEditingController(text: '123456');
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
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(26)),
                    child: const Center(child: Text('Bb', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(height: 16),
                  const Text('BanBif', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const Text('Home Banking', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 28),
                  TextField(controller: dniController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'DNI / Usuario', prefixIcon: Icon(Icons.person))),
                  const SizedBox(height: 14),
                  TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña', prefixIcon: Icon(Icons.lock))),
                  const SizedBox(height: 14),
                  if (viewModel.error != null) Text(viewModel.error!, style: const TextStyle(color: AppColors.error)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: viewModel.loading ? null : () async {
                      final ok = await viewModel.login(dniController.text, passwordController.text);
                      if (ok && mounted) {
                        Navigator.pushReplacementNamed(context, AppRoutes.dashboard, arguments: viewModel.usuario);
                      }
                    },
                    child: Text(viewModel.loading ? 'Conectando...' : 'Ingresar'),
                  ),
                  const SizedBox(height: 12),
                  const Text('Demo Supabase Cliente: 74253618 / 123456', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
