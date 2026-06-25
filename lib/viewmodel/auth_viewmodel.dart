import 'package:flutter/foundation.dart';

import '../data/cliente_core_service.dart';
import '../model/cliente_usuario.dart';

class AuthViewModel extends ChangeNotifier {
  final ClienteCoreService _service = ClienteCoreService();

  bool loading = false;
  bool checkingCore = false;
  String? error;
  String? coreStatus;
  ClienteUsuario? usuario;

  Future<bool> login(String dni, String password) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      usuario = await _service.login(dni.trim(), password.trim());
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() => _service.logout();

  Future<void> limpiarSesion() async {
    await _service.limpiarSesion();
    usuario = null;
    error = null;
    coreStatus = 'Sesion local limpiada.';
    notifyListeners();
  }

  Future<void> probarConexionCore() async {
    checkingCore = true;
    error = null;
    coreStatus = null;
    notifyListeners();
    try {
      final data = await _service.probarConexion();
      final ok = data['database_ok'] == true;
      coreStatus = ok
          ? 'Core conectado correctamente.'
          : 'Core responde, pero alguna BD no esta disponible.';
    } catch (e) {
      error = e.toString();
      coreStatus = 'No se pudo conectar al Core. Verifica backend, IP, firewall o adb reverse.';
    } finally {
      checkingCore = false;
      notifyListeners();
    }
  }
}
