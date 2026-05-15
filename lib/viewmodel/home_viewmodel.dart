import 'package:flutter/foundation.dart';

import '../data/cliente_supabase_service.dart';
import '../model/cliente_usuario.dart';
import '../model/cuenta.dart';
import '../model/credito.dart';
import '../model/movimiento.dart';

class HomeViewModel extends ChangeNotifier {
  final ClienteSupabaseService _service = ClienteSupabaseService();

  Cuenta? cuenta;
  Credito? credito;
  List<Movimiento> movimientos = [];
  bool loading = false;
  String? error;

  Future<void> cargarDatos(ClienteUsuario usuario) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      cuenta = await _service.obtenerCuentaPrincipal(usuario.id);
      credito = await _service.obtenerCreditoActivo(usuario.id);
      movimientos = await _service.obtenerMovimientos(usuario.id);
    } catch (_) {
      error = 'No se pudieron cargar los datos desde Supabase Cliente';
    }

    loading = false;
    notifyListeners();
  }
}
