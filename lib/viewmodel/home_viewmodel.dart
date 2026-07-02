import 'package:flutter/foundation.dart';

import '../data/cliente_core_service.dart';
import '../model/cliente_usuario.dart';
import '../model/cuenta.dart';
import '../model/credito.dart';
import '../model/movimiento.dart';

class HomeViewModel extends ChangeNotifier {
  final ClienteCoreService _service = ClienteCoreService();

  ClienteUsuario? usuario;
  List<Cuenta> cuentas = [];
  List<Credito> creditos = [];
  List<Movimiento> movimientos = [];
  List<Map<String, dynamic>> tarjetas = [];
  List<Map<String, dynamic>> notificaciones = [];
  List<Map<String, dynamic>> solicitudes = [];
  Map<String, dynamic>? perfil;
  Map<String, dynamic>? ultimaSimulacion;
  bool loading = false;
  bool saving = false;
  String? error;

  Cuenta? get cuentaPrincipal => cuentas.isEmpty ? null : cuentas.first;
  Credito? get creditoPrincipal => creditos.isEmpty ? null : creditos.first;

  Future<void> cargarDatos(ClienteUsuario cliente) async {
    usuario = cliente;
    loading = true;
    error = null;
    notifyListeners();

    try {
      await _reloadLists();
    } catch (e) {
      error = 'No se pudieron cargar los datos desde el Core BanBif: $e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> guardarCuenta(Cuenta cuenta, {required bool nueva}) =>
      _blockedMutation('Las cuentas se administran desde el Core.');

  Future<bool> eliminarCuenta(String id) =>
      _blockedMutation('Las cuentas no se eliminan desde la app cliente.');

  Future<bool> guardarCredito(Credito credito, {required bool nuevo}) =>
      _blockedMutation('Los creditos nacen por solicitud y desembolso del Core.');

  Future<bool> eliminarCredito(String id) =>
      _blockedMutation('Los creditos no se eliminan desde la app cliente.');

  Future<bool> guardarMovimiento(
    Movimiento movimiento, {
    required bool nuevo,
  }) =>
      _blockedMutation('Los movimientos los registra el Core.');

  Future<bool> eliminarMovimiento(String id) =>
      _blockedMutation('Los movimientos no se eliminan desde la app cliente.');

  Future<bool> guardarPerfil(String nombre, String correo) async {
    usuario = usuario?.copyWith(nombre: nombre, correo: correo);
    notifyListeners();
    return true;
  }

  Future<bool> crearSolicitudCredito({
    required double monto,
    required int plazoMeses,
    required String destino,
    String? garantia,
    bool seguroDesgravamen = true,
  }) async {
    saving = true;
    error = null;
    notifyListeners();
    try {
      await _service.crearSolicitudCredito(
        monto: monto,
        plazoMeses: plazoMeses,
        destino: destino,
        garantia: garantia,
        seguroDesgravamen: seguroDesgravamen,
      );
      await _reloadLists();
      return true;
    } catch (e) {
      error = 'No se pudo registrar la solicitud en el Core BanBif: $e';
      return false;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  Future<bool> simularCredito({
    required double monto,
    required int plazoMeses,
    double tea = 0.4092,
  }) async {
    saving = true;
    error = null;
    notifyListeners();
    try {
      ultimaSimulacion = await _service.simularCredito(monto, plazoMeses, tea);
      return true;
    } catch (e) {
      error = 'No se pudo simular el credito: $e';
      return false;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> cargarCronograma(String creditoId) {
    return _service.obtenerCronograma(creditoId);
  }

  Future<bool> _blockedMutation(String message) async {
    error = message;
    notifyListeners();
    return false;
  }

  Future<void> _reloadLists() async {
    final resultados = await Future.wait([
      _service.obtenerPerfil(),
      _service.obtenerCuentas(),
      _service.obtenerTarjetas(),
      _service.obtenerCreditos(),
      _service.obtenerMovimientos(),
      _service.obtenerNotificaciones(),
      _service.obtenerSolicitudes(),
    ]);
    perfil = resultados[0] as Map<String, dynamic>;
    cuentas = resultados[1] as List<Cuenta>;
    tarjetas = resultados[2] as List<Map<String, dynamic>>;
    creditos = resultados[3] as List<Credito>;
    movimientos = resultados[4] as List<Movimiento>;
    notificaciones = resultados[5] as List<Map<String, dynamic>>;
    solicitudes = resultados[6] as List<Map<String, dynamic>>;
  }
}
