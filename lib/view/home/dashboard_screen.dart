import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model/cliente_usuario.dart';
import '../../model/credito.dart';
import '../../model/cuenta.dart';
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
          _walletCard(cuenta, credito),
          const SizedBox(height: AppSpacing.lg),
          _shortcutGrid(),
          const SizedBox(height: AppSpacing.xl),
          const AppSectionTitle(
            title: 'Tus productos',
            subtitle: 'Resumen de tus productos bancarios',
          ),
          if (credito == null)
            _compactEmpty('Aun no tienes creditos activos. Solicita capital de trabajo desde la app.')
          else
            _creditCard(credito),
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

  Widget _walletCard(Cuenta? cuenta, Credito? credito) {
    final saldo = cuenta == null ? 'S/ 0.00' : _format(cuenta.saldo);
    final creditoLabel = credito == null ? 'Sin credito activo' : 'Credito: ${_format(credito.montoPendiente)}';
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: AppRadius.card,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.24),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                  ),
                  child: Text(
                    cuenta?.moneda ?? 'PEN',
                    style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Balance disponible', style: AppTextStyles.caption.copyWith(color: Colors.white.withValues(alpha: 0.92))),
            const SizedBox(height: AppSpacing.xs),
            Text(saldo, style: AppTextStyles.display.copyWith(color: Colors.white, fontSize: 34)),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Text(
                    cuenta == null ? 'Tus productos apareceran aqui' : '${cuenta.tipo} ${_mask(cuenta.numeroCuenta)}',
                    style: AppTextStyles.caption.copyWith(color: Colors.white.withValues(alpha: 0.92)),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    creditoLabel,
                    textAlign: TextAlign.end,
                    style: AppTextStyles.caption.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _shortcutGrid() {
    final items = [
      _Shortcut('Solicitar', Icons.add_card_outlined, () => setState(() => currentIndex = 2)),
      _Shortcut('Creditos', Icons.credit_score_outlined, () => setState(() => currentIndex = 1)),
      _Shortcut('Cronograma', Icons.event_note_outlined, () {
        final credito = viewModel.creditoPrincipal;
        if (credito == null) {
          _toast('No tienes creditos desembolsados todavia.', AppColors.warning);
          return;
        }
        _showSchedule(credito);
      }),
      _Shortcut('Movimientos', Icons.receipt_long_outlined, () => setState(() => currentIndex = 3)),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 360 ? 2 : 4;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: columns == 2 ? 1.55 : 0.86,
          ),
          itemBuilder: (context, index) => _shortcutCard(items[index]),
        );
      },
    );
  }

  Widget _shortcutCard(_Shortcut item) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.md),
      onTap: item.onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.brandWarmSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(item.icon, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(item.label, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.caption),
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
          const AppSectionTitle(
            title: 'Solicitudes',
            subtitle: 'Estado de tus expedientes de credito',
          ),
          if (viewModel.solicitudes.isEmpty)
            _compactEmpty('No hay solicitudes registradas')
          else
            ...viewModel.solicitudes.map(_solicitudTile),
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
          backgroundColor: AppColors.accentSoft,
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
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      onTap: () => _showSchedule(credito),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.payments_outlined, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(credito.producto.isEmpty ? 'Credito BanBif' : credito.producto, style: AppTextStyles.bodyStrong),
                    const SizedBox(height: 2),
                    const Text('Saldo pendiente', style: AppTextStyles.caption),
                  ],
                ),
              ),
              AppStatusChip(label: credito.estado, color: _statusColor(credito.estado), icon: _statusIcon(credito.estado)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(_format(credito.montoPendiente), style: AppTextStyles.display),
          const SizedBox(height: AppSpacing.sm),
          const Row(
            children: [
              Icon(Icons.calendar_month_outlined, size: 18, color: AppColors.textSecondary),
              SizedBox(width: AppSpacing.xs),
              Expanded(child: Text('Ver cronograma y pagar cuota')),
              Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ],
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
          final pending = _firstPending(items);
          return SafeArea(
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.72,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Cronograma ${credito.producto}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  ),
                  if (pending != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: FilledButton.icon(
                        onPressed: viewModel.saving ? null : () => _payInstallment(credito, pending),
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text('Pagar cuota ${pending['numero_cuota']} (${_formatNum(pending['cuota'])})'),
                      ),
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
                                title: Text('Cuota ${item['numero_cuota']} - ${_formatEstado(item['estado']?.toString() ?? '')}'),
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

  Future<void> _payInstallment(Credito credito, Map<String, dynamic> cuota) async {
    final amount = _toDouble(cuota['cuota']);
    final number = (cuota['numero_cuota'] as num?)?.toInt();
    Navigator.of(context).pop();
    final ok = await viewModel.pagarCredito(creditoId: credito.id, monto: amount, numeroCuota: number);
    if (!mounted) return;
    _toast(ok ? 'Pago registrado correctamente' : viewModel.error ?? 'No se pudo registrar el pago', ok ? AppColors.success : AppColors.error);
  }

  void _toast(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Map<String, dynamic>? _firstPending(List<Map<String, dynamic>> items) {
    for (final item in items) {
      if (item['estado'] != 'PAGADO') return item;
    }
    return null;
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
          backgroundColor: positive ? AppColors.success.withValues(alpha: 0.10) : AppColors.error.withValues(alpha: 0.10),
          child: Icon(positive ? Icons.south_west : Icons.north_east, color: positive ? AppColors.success : AppColors.error),
        ),
        title: Text(item.descripcion, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(DateFormat('dd/MM/yyyy').format(item.fecha)),
        trailing: Text(_format(item.monto.abs()), style: TextStyle(fontWeight: FontWeight.w800, color: positive ? AppColors.success : AppColors.textPrimary)),
      ),
    );
  }

  Widget _solicitudTile(Map<String, dynamic> item) {
    final estado = item['estado']?.toString() ?? 'ENVIADO';
    final Object? monto = item['monto_aprobado'] ?? item['monto'];
    final motivo = item['motivo_rechazo'] ?? item['condicion'];
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      onTap: () => _showSolicitudDetail(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item['expediente']?.toString() ?? 'Solicitud BanBif',
                  style: AppTextStyles.bodyStrong,
                ),
              ),
              AppStatusChip(
                label: _formatEstado(estado),
                color: _statusColor(estado),
                icon: _statusIcon(estado),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${_formatNum(monto)} | ${item['plazo_meses'] ?? 12} meses | ${item['destino'] ?? 'Capital de trabajo'}',
            style: AppTextStyles.body,
          ),
          if (motivo != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(motivo.toString(), style: AppTextStyles.caption),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showSolicitudDetail(item),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Ver estado'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (estado.toUpperCase() == 'DESEMBOLSADO')
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => setState(() => currentIndex = 1),
                    icon: const Icon(Icons.event_note_outlined),
                    label: const Text('Ver credito'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showSolicitudDetail(Map<String, dynamic> item) async {
    final estado = item['estado']?.toString().toUpperCase() ?? 'ENVIADO';
    final motivo = item['motivo_rechazo'] ?? item['condicion'];
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item['expediente']?.toString() ?? 'Solicitud BanBif',
                      style: AppTextStyles.display.copyWith(fontSize: 20),
                    ),
                  ),
                  AppStatusChip(label: _formatEstado(estado), color: _statusColor(estado), icon: _statusIcon(estado)),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _detailLine('Monto solicitado', _formatNum(item['monto'])),
              _detailLine('Monto aprobado', item['monto_aprobado'] == null ? 'Pendiente' : _formatNum(item['monto_aprobado'])),
              _detailLine('Plazo', '${item['plazo_meses'] ?? 12} meses'),
              _detailLine('Destino', item['destino']?.toString() ?? 'Capital de trabajo'),
              _detailLine('Garantia', item['garantia']?.toString() ?? 'No registrada'),
              if (motivo != null) _detailLine(estado == 'RECHAZADO' ? 'Motivo de rechazo' : 'Condicion', motivo.toString()),
              const SizedBox(height: AppSpacing.lg),
              if (estado == 'RECHAZADO')
                const AppEmptyState(
                  icon: Icons.cancel_outlined,
                  title: 'No se genera cronograma',
                  message: 'El expediente fue rechazado por comite y queda cerrado sin desembolso.',
                )
              else if (estado == 'CONDICIONADO')
                const AppCard(
                  child: Text(
                    'El comite aprobo un monto reducido. Revisa el monto aprobado y espera desembolso para ver cronograma.',
                    style: AppTextStyles.body,
                  ),
                )
              else if (estado == 'DESEMBOLSADO')
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() => currentIndex = 1);
                  },
                  icon: const Icon(Icons.credit_score_outlined),
                  label: const Text('Ver credito y cronograma'),
                )
              else
                const AppCard(
                  child: Text('Tu solicitud sigue en proceso. Actualiza la app para consultar cambios.', style: AppTextStyles.body),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: AppTextStyles.caption)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.bodyStrong,
            ),
          ),
        ],
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
  double _toDouble(Object? value) => (value as num?)?.toDouble() ?? 0;
  String _formatNum(Object? value) => _format((value as num?)?.toDouble() ?? 0);
  Color _statusColor(String estado) {
    switch (estado.toUpperCase()) {
      case 'APROBADO':
      case 'DESEMBOLSADO':
      case 'ACTIVO':
        return AppColors.success;
      case 'CONDICIONADO':
      case 'EN_EVALUACION':
      case 'RECIBIDO_COMITE':
        return AppColors.warning;
      case 'RECHAZADO':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  IconData _statusIcon(String estado) {
    switch (estado.toUpperCase()) {
      case 'DESEMBOLSADO':
        return Icons.payments_outlined;
      case 'APROBADO':
        return Icons.check_circle_outline;
      case 'RECHAZADO':
        return Icons.cancel_outlined;
      case 'CONDICIONADO':
        return Icons.rule_outlined;
      default:
        return Icons.schedule_outlined;
    }
  }

  String _formatEstado(String estado) {
    switch (estado.toUpperCase()) {
      case 'BORRADOR':
        return 'Borrador';
      case 'ENVIADO':
        return 'Enviado';
      case 'RECIBIDO_COMITE':
        return 'Recibido por comite';
      case 'EN_EVALUACION':
        return 'En evaluacion';
      case 'APROBADO':
        return 'Aprobado';
      case 'CONDICIONADO':
        return 'Condicionado';
      case 'RECHAZADO':
        return 'Rechazado';
      case 'DESEMBOLSADO':
        return 'Desembolsado';
      case 'PAGADO':
        return 'Pagado';
      default:
        return estado.isEmpty ? 'Pendiente' : estado;
    }
  }

  void _logout() {
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }
}

class _Shortcut {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _Shortcut(this.label, this.icon, this.onTap);
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
              subtitle: Text('El expediente fue registrado y enviado para evaluacion.'),
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
        content: Text(ok ? 'Solicitud enviada para evaluacion' : widget.viewModel.error ?? 'No se pudo enviar'),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ),
    );
    if (ok) widget.onDone();
  }
}
