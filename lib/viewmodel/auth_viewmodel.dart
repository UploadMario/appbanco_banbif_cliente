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
      error = 'No se pudo iniciar sesion. Verifica tus credenciales.';
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
    coreStatus = 'Sesion limpiada correctamente.';
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
          ? 'Servicio disponible.'
          : 'El servicio esta disponible, pero algunos datos pueden tardar en cargar.';
    } catch (e) {
      error = 'No pudimos conectar con el servicio. Intenta nuevamente.';
      coreStatus = null;
    } finally {
      checkingCore = false;
      notifyListeners();
    }
  }
}
