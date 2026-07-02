import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model/cliente_usuario.dart';
import '../../model/credito.dart';
import '../../model/movimiento.dart';
import '../../navigation/app_routes.dart';
import '../../ui/components/app_components.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_radius.dart';
import '../../ui/theme/app_spacing.dart';
import '../../ui/theme/app_text_styles.dart';
import '../../viewmodel/home_viewmodel.dart';
import '../../widgets/header.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final HomeViewModel viewModel = HomeViewModel();
  final _money = NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ');
  int currentIndex = 0;
  bool initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (initialized) return;
    final usuario = ModalRoute.of(context)?.settings.arguments as ClienteUsuario?;
    if (usuario != null) viewModel.cargarDatos(usuario);
    initialized = true;
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        final usuario = viewModel.usuario;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                Header(
                  title: _title,
                  subtitle: 'Hola, ${usuario?.nombre.isEmpty == false ? usuario!.nombre : 'Cliente BanBif'}',
                  onLogout: _logout,
                ),
                if (viewModel.saving) const LinearProgressIndicator(minHeight: 3),
                Expanded(child: _body()),
              ],
            ),
          ),
          bottomNavigationBar: NavigationBar(
            backgroundColor: AppColors.surface,
            indicatorColor: AppColors.brandWarmSoft,
            selectedIndex: currentIndex,
            onDestinationSelected: (index) => setState(() => currentIndex = index),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
              NavigationDestination(icon: Icon(Icons.wallet_outlined), selectedIcon: Icon(Icons.wallet), label: 'Productos'),
              NavigationDestination(icon: Icon(Icons.request_quote_outlined), selectedIcon: Icon(Icons.request_quote), label: 'Solicitar'),
              NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications), label: 'Actividad'),
              NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
            ],
          ),
        );
      },
    );
  }

  String get _title => const ['Resumen', 'Productos', 'Solicitud', 'Actividad', 'Perfil'][currentIndex];

  Widget _body() {
    if (viewModel.loading) return const AppLoading();
    if (viewModel.usuario == null) {
      return _state(Icons.lock_outline, 'Sesion no disponible', 'Vuelve a iniciar sesion para continuar.');
    }
    final pages = [_home(), _products(), _request(), _activity(), _profile()];
    return Column(
      children: [
        if (viewModel.error != null)
          MaterialBanner(
            content: Text(viewModel.error!),
            leading: const Icon(Icons.error_outline, color: AppColors.error),
            actions: [
              TextButton(
                onPressed: () => viewModel.cargarDatos(viewModel.usuario!),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        Expanded(child: pages[currentIndex]),
      ],
    );
  }

  Widget _home() {
    final cuenta = viewModel.cuentaPrincipal;
    final credito = viewModel.creditoPrincipal;
    return RefreshIndicator(
      onRefresh: () => viewModel.cargarDatos(viewModel.usuario!),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _heroCard(
            'Saldo disponible',
            cuenta == null ? 'Sin cuentas' : _format(cuenta.saldo),
            cuenta?.numeroCuenta ?? 'Tus productos apareceran aqui',
            Icons.account_balance_wallet,
            () => setState(() => currentIndex = 1),
          ),
          const SizedBox(height: AppSpacing.md),
          _heroCard(
            credito?.producto.isNotEmpty == true ? credito!.producto : 'Credito BanBif',
            credito == null ? 'Sin creditos activos' : _format(credito.montoPendiente),
            credito == null ? 'Solicita capital de trabajo en minutos' : 'Estado: ${credito.estado}',
            Icons.credit_score,
            () => setState(() => currentIndex = credito == null ? 2 : 1),
          ),
          const SizedBox(height: AppSpacing.xl),
          const AppSectionTitle(
            title: 'Ultimos movimientos',
            subtitle: 'Actividad reciente de tus productos',
          ),
          ...viewModel.movimientos.take(4).map(_movementTile),
          if (viewModel.movimientos.isEmpty)
            const AppEmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Sin movimientos',
              message: 'Cuando haya desembolsos o pagos se mostraran aqui.',
            ),
        ],
      ),
    );
  }

  Widget _products() {
    return RefreshIndicator(
      onRefresh: () => viewModel.cargarDatos(viewModel.usuario!),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const AppSectionTitle(title: 'Cuentas'),
          if (viewModel.cuentas.isEmpty)
            _compactEmpty('No hay cuentas registradas')
          else
            ...viewModel.cuentas.map((item) => _infoCard(
                  title: item.tipo,
                  subtitle: '${_mask(item.numeroCuenta)} | ${item.moneda}',
                  value: _format(item.saldo),
                  icon: Icons.account_balance,
                  color: AppColors.primary,
                )),
          const AppSectionTitle(title: 'Tarjetas'),
          if (viewModel.tarjetas.isEmpty)
            _compactEmpty('No hay tarjetas registradas')
          else
            ...viewModel.tarjetas.map((item) => _infoCard(
                  title: item['tipo']?.toString() ?? 'Tarjeta',
                  subtitle: '${item['numero_enmascarado'] ?? '****'} | ${item['estado'] ?? ''}',
                  value: _format((item['linea_disponible'] as num?)?.toDouble() ?? 0),
                  icon: Icons.credit_card,
                  color: AppColors.secondary,
                )),
          const AppSectionTitle(title: 'Creditos'),
          if (viewModel.creditos.isEmpty)
            _compactEmpty('No hay creditos desembolsados')
          else
            ...viewModel.creditos.map((credito) => _creditCard(credito)),
        ],
      ),
    );
  }

  Widget _request() {
    return _CreditRequestForm(viewModel: viewModel, onDone: () => viewModel.cargarDatos(viewModel.usuario!));
  }

  Widget _activity() {
    return RefreshIndicator(
      onRefresh: () => viewModel.cargarDatos(viewModel.usuario!),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const AppSectionTitle(title: 'Movimientos'),
          if (viewModel.movimientos.isEmpty)
            _compactEmpty('No hay movimientos')
          else
            ...viewModel.movimientos.map(_movementTile),
          const AppSectionTitle(title: 'Notificaciones'),
          if (viewModel.notificaciones.isEmpty)
            _compactEmpty('No hay notificaciones')
          else
            ...viewModel.notificaciones.map((item) => Card(
                  child: ListTile(
                    leading: Icon(
                      item['leido'] == true ? Icons.mark_email_read_outlined : Icons.notifications_active_outlined,
                      color: item['leido'] == true ? AppColors.textSecondary : AppColors.accent,
                    ),
                    title: Text(item['titulo']?.toString() ?? 'Notificacion'),
                    subtitle: Text(item['mensaje']?.toString() ?? ''),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _profile() {
    final perfil = viewModel.perfil ?? {};
    final usuario = viewModel.usuario!;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const CircleAvatar(
          radius: 42,
          backgroundColor: Color(0xFFE5F4FE),
          child: Icon(Icons.person, color: AppColors.primary, size: 44),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(usuario.nombre, textAlign: TextAlign.center, style: AppTextStyles.display),
        Text(usuario.correo, textAlign: TextAlign.center, style: AppTextStyles.body),
        const SizedBox(height: AppSpacing.xl),
        Card(
          child: Column(
            children: [
              _profileTile(Icons.badge_outlined, 'Documento', perfil['documento']?.toString() ?? usuario.dni),
              _profileTile(Icons.phone_outlined, 'Telefono', perfil['telefono']?.toString() ?? 'No registrado'),
              _profileTile(Icons.email_outlined, 'Correo', perfil['correo']?.toString() ?? usuario.correo),
              _profileTile(Icons.storefront_outlined, 'Negocio', perfil['negocio_nombre']?.toString() ?? 'No registrado'),
              _profileTile(Icons.verified_user_outlined, 'Estado', perfil['activo'] == false ? 'Inactivo' : 'Activo'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(onPressed: _logout, icon: const Icon(Icons.logout), label: const Text('Cerrar sesion')),
      ],
    );
  }

  Widget _creditCard(Credito credito) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.brandWarmSoft,
          child: Icon(Icons.payments_outlined, color: AppColors.success),
        ),
        title: Text(credito.producto.isEmpty ? 'Credito BanBif' : credito.producto),
        subtitle: Text('Saldo: ${_format(credito.montoPendiente)} | ${credito.estado}'),
        trailing: const Icon(Icons.calendar_month_outlined),
        onTap: () => _showSchedule(credito),
      ),
    );
  }

  Future<void> _showSchedule(Credito credito) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => FutureBuilder<List<Map<String, dynamic>>>(
        future: viewModel.cargarCronograma(credito.id),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          return SafeArea(
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.72,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Cronograma ${credito.producto}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  ),
                  if (!snapshot.hasData) const Expanded(child: Center(child: CircularProgressIndicator())) else Expanded(
                    child: items.isEmpty
                        ? _state(Icons.event_busy, 'Sin cronograma', 'El cronograma se genera al desembolsar.')
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: items.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (_, index) {
                              final item = items[index];
                              return ListTile(
                                title: Text('Cuota ${item['numero_cuota']} - ${item['estado']}'),
                                subtitle: Text('Capital ${_formatNum(item['capital'])} | Interes ${_formatNum(item['interes'])}'),
                                trailing: Text(_formatNum(item['cuota']), style: const TextStyle(fontWeight: FontWeight.w800)),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _heroCard(String title, String value, String subtitle, IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: AppRadius.card,
        boxShadow: [
          BoxShadow(
            color: AppColors.brandMagenta.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.card,
        child: InkWell(
          borderRadius: AppRadius.card,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.caption.copyWith(color: Colors.white70)),
                      const SizedBox(height: AppSpacing.xs),
                      Text(value, style: AppTextStyles.display.copyWith(color: Colors.white)),
                      const SizedBox(height: AppSpacing.xs),
                      Text(subtitle, style: AppTextStyles.caption.copyWith(color: Colors.white70)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white70),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoCard({required String title, required String subtitle, required String value, required IconData icon, required Color color}) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.12), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _movementTile(Movimiento item) {
    final positive = item.monto >= 0 && item.tipo.toUpperCase() != 'EGRESO';
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: positive ? const Color(0xFFEAF8EF) : const Color(0xFFFDECEC),
          child: Icon(positive ? Icons.south_west : Icons.north_east, color: positive ? AppColors.success : AppColors.error),
        ),
        title: Text(item.descripcion, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(DateFormat('dd/MM/yyyy').format(item.fecha)),
        trailing: Text(_format(item.monto.abs()), style: TextStyle(fontWeight: FontWeight.w800, color: positive ? AppColors.success : AppColors.textPrimary)),
      ),
    );
  }

  Widget _profileTile(IconData icon, String title, String value) {
    return ListTile(leading: Icon(icon), title: Text(title), subtitle: Text(value));
  }

  Widget _compactEmpty(String text) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(text, style: AppTextStyles.body),
    );
  }

  Widget _state(IconData icon, String title, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: AppColors.textSecondary),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  String _mask(String value) => value.length <= 6 ? value : '**** ${value.substring(value.length - 4)}';
  String _format(double value) => _money.format(value);
  String _formatNum(Object? value) => _format((value as num?)?.toDouble() ?? 0);

  void _logout() {
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }
}

class _CreditRequestForm extends StatefulWidget {
  final HomeViewModel viewModel;
  final VoidCallback onDone;

  const _CreditRequestForm({required this.viewModel, required this.onDone});

  @override
  State<_CreditRequestForm> createState() => _CreditRequestFormState();
}

class _CreditRequestFormState extends State<_CreditRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final monto = TextEditingController(text: '10000');
  final plazo = TextEditingController(text: '12');
  final destino = TextEditingController(text: 'Capital de trabajo');
  final garantia = TextEditingController(text: 'Inventario del negocio');
  bool seguro = true;
  bool sent = false;

  @override
  void dispose() {
    monto.dispose();
    plazo.dispose();
    destino.dispose();
    garantia.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sim = widget.viewModel.ultimaSimulacion;
    final cuota = sim == null ? null : (sim['cuota'] as num?)?.toDouble();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Form(
          key: _formKey,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    controller: monto,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Monto solicitado'),
                    validator: (v) => (double.tryParse((v ?? '').replaceAll(',', '.')) ?? 0) > 0 ? null : 'Monto invalido',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: plazo,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Plazo en meses'),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      return n != null && n > 0 && n <= 60 ? null : 'Plazo invalido';
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: destino,
                    decoration: const InputDecoration(labelText: 'Destino'),
                    validator: (v) => (v ?? '').trim().length >= 3 ? null : 'Destino obligatorio',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: garantia,
                    decoration: const InputDecoration(labelText: 'Garantia'),
                    validator: (v) => (v ?? '').trim().isNotEmpty ? null : 'Garantia obligatoria',
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: seguro,
                    title: const Text('Seguro desgravamen'),
                    onChanged: (value) => setState(() => seguro = value),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _simulate,
                          icon: const Icon(Icons.calculate_outlined),
                          label: const Text('Simular'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.send_outlined),
                          label: const Text('Enviar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (cuota != null)
          Card(
            child: ListTile(
              leading: const Icon(Icons.payments_outlined, color: AppColors.success),
              title: const Text('Cuota estimada'),
              subtitle: Text('Sistema frances, TEA ${seguro ? '40.92%' : '43.92%'}'),
              trailing: Text(NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ').format(cuota), style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        if (sent)
          const Card(
            child: ListTile(
              leading: Icon(Icons.check_circle, color: AppColors.success),
              title: Text('Solicitud enviada'),
              subtitle: Text('El expediente fue registrado en el Core y enviado a cartera/comite.'),
            ),
          ),
      ],
    );
  }

  Future<void> _simulate() async {
    if (!_formKey.currentState!.validate()) return;
    await widget.viewModel.simularCredito(
      monto: double.parse(monto.text.replaceAll(',', '.')),
      plazoMeses: int.parse(plazo.text),
      tea: seguro ? 0.4092 : 0.4392,
    );
    if (mounted && widget.viewModel.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.viewModel.error!), backgroundColor: AppColors.error));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await widget.viewModel.crearSolicitudCredito(
      monto: double.parse(monto.text.replaceAll(',', '.')),
      plazoMeses: int.parse(plazo.text),
      destino: destino.text.trim(),
      garantia: garantia.text.trim(),
      seguroDesgravamen: seguro,
    );
    if (!mounted) return;
    setState(() => sent = ok);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Solicitud registrada en el Core BanBif' : widget.viewModel.error ?? 'No se pudo enviar'),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ),
    );
    if (ok) widget.onDone();
  }
}
