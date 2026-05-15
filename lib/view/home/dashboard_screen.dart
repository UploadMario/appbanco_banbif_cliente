import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model/cliente_usuario.dart';
import '../../ui/theme/app_colors.dart';
import '../../viewmodel/home_viewmodel.dart';
import '../../widgets/header.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final HomeViewModel viewModel = HomeViewModel();
  int currentIndex = 0;
  bool initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      final usuario = ModalRoute.of(context)?.settings.arguments as ClienteUsuario?;
      if (usuario != null) viewModel.cargarDatos(usuario);
      initialized = true;
    }
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usuario = ModalRoute.of(context)?.settings.arguments as ClienteUsuario?;
    final money = NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ');

    return Scaffold(
      body: Column(
        children: [
          Header(title: 'BanBif', subtitle: 'Hola, ${usuario?.nombre ?? 'Cliente'}', onLogout: () => Navigator.pushReplacementNamed(context, '/')),
          Expanded(
            child: AnimatedBuilder(
              animation: viewModel,
              builder: (context, _) {
                if (viewModel.loading) return const Center(child: CircularProgressIndicator());
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _summaryCard('Cuenta de ahorros', money.format(viewModel.cuenta?.saldo ?? 0), viewModel.cuenta?.numeroCuenta ?? 'Sin cuenta', Icons.savings, AppColors.primary),
                    const SizedBox(height: 12),
                    _summaryCard(viewModel.credito?.producto ?? 'Crédito activo', money.format(viewModel.credito?.montoPendiente ?? 0), 'Cuota mensual: ${money.format(viewModel.credito?.cuotaMensual ?? 0)}', Icons.credit_score, AppColors.secondary),
                    const SizedBox(height: 18),
                    const Text('Últimos movimientos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...viewModel.movimientos.map((movimiento) => Card(
                      child: ListTile(
                        leading: Icon(movimiento.tipo == 'INGRESO' ? Icons.arrow_downward : Icons.arrow_upward, color: movimiento.tipo == 'INGRESO' ? AppColors.success : AppColors.error),
                        title: Text(movimiento.descripcion),
                        subtitle: Text(DateFormat('dd/MM/yyyy').format(movimiento.fecha)),
                        trailing: Text(money.format(movimiento.monto), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    )),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: 'Cuentas'),
          BottomNavigationBarItem(icon: Icon(Icons.payments), label: 'Créditos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(22)),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 36),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Colors.white70)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(color: Colors.white70)),
          ])),
        ],
      ),
    );
  }
}
