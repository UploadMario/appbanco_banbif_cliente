import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/cliente_usuario.dart';
import '../model/cuenta.dart';
import '../model/credito.dart';
import '../model/movimiento.dart';

class ClienteSupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<ClienteUsuario?> login(String dni, String password) async {
    final data = await _client
        .from('cliente_usuarios')
        .select()
        .eq('dni', dni)
        .eq('password_demo', password)
        .maybeSingle();

    if (data == null) return null;
    return ClienteUsuario.fromMap(data);
  }

  Future<Cuenta?> obtenerCuentaPrincipal(String clienteId) async {
    final data = await _client
        .from('cliente_cuentas')
        .select()
        .eq('cliente_id', clienteId)
        .limit(1)
        .maybeSingle();

    if (data == null) return null;
    return Cuenta.fromMap(data);
  }

  Future<Credito?> obtenerCreditoActivo(String clienteId) async {
    final data = await _client
        .from('cliente_creditos')
        .select()
        .eq('cliente_id', clienteId)
        .limit(1)
        .maybeSingle();

    if (data == null) return null;
    return Credito.fromMap(data);
  }

  Future<List<Movimiento>> obtenerMovimientos(String clienteId) async {
    final data = await _client
        .from('cliente_movimientos')
        .select()
        .eq('cliente_id', clienteId)
        .order('fecha', ascending: false)
        .limit(5);

    return (data as List).map((item) => Movimiento.fromMap(item)).toList();
  }
}
