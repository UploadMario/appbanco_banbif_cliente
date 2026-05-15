import 'package:flutter/foundation.dart';

import '../data/cliente_supabase_service.dart';
import '../model/cliente_usuario.dart';

class AuthViewModel extends ChangeNotifier {
  final ClienteSupabaseService _service = ClienteSupabaseService();

  bool loading = false;
  String? error;
  ClienteUsuario? usuario;

  Future<bool> login(String dni, String password) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      usuario = await _service.login(dni.trim(), password.trim());
      if (usuario == null) {
        error = 'Credenciales incorrectas o no registradas en Supabase Cliente';
        return false;
      }
      return true;
    } catch (_) {
      error = 'No se pudo conectar con Supabase Cliente';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
