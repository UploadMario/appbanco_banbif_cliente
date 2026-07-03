import '../model/cliente_usuario.dart';
import '../model/credito.dart';
import '../model/cuenta.dart';
import '../model/movimiento.dart';
import 'api_client.dart';

class ClienteCoreService {
  final ApiClient _api = ApiClient();

  Future<Map<String, dynamic>> probarConexion() => _api.health();

  Future<ClienteUsuario> login(String dni, String password) async {
    final response = await _api.post('/auth/login', body: {'identifier': dni, 'username': dni, 'password': password});
    final user = Map<String, dynamic>.from(response['user'] as Map);
    if (user['role'] != 'CLIENTE') {
      throw const ApiException(403, 'Este usuario no tiene acceso a la App Cliente');
    }
    await _api.saveToken(response['access_token'].toString());
    return ClienteUsuario.fromCoreUser(user);
  }

  Future<List<Cuenta>> obtenerCuentas() async {
    final response = await _api.get('/clientes/me/cuentas');
    return _items(response).map(Cuenta.fromMap).toList();
  }

  Future<Map<String, dynamic>> obtenerPerfil() async {
    final response = await _api.get('/clientes/me/perfil');
    return Map<String, dynamic>.from(response['data'] as Map);
  }

  Future<List<Map<String, dynamic>>> obtenerTarjetas() async {
    final response = await _api.get('/clientes/me/tarjetas');
    return _items(response);
  }

  Future<List<Credito>> obtenerCreditos() async {
    final response = await _api.get('/clientes/me/creditos');
    return _items(response).map((item) {
      return Credito.fromMap({
        ...item,
        'monto_pendiente': item['saldo_pendiente'] ?? item['monto_aprobado'],
        'cuota_mensual': item['cuota_mensual'] ?? 0,
      });
    }).toList();
  }

  Future<List<Movimiento>> obtenerMovimientos() async {
    final response = await _api.get('/clientes/me/movimientos');
    return _items(response).map(Movimiento.fromMap).toList();
  }

  Future<List<Map<String, dynamic>>> obtenerNotificaciones() async {
    final response = await _api.get('/clientes/me/notificaciones');
    return _items(response);
  }

  Future<List<Map<String, dynamic>>> obtenerSolicitudes() async {
    final response = await _api.get('/clientes/me/solicitudes-credito');
    return _items(response);
  }

  Future<List<Map<String, dynamic>>> obtenerCronograma(String creditoId) async {
    final response = await _api.get('/clientes/me/creditos/$creditoId/cronograma');
    return _items(response);
  }

  Future<Map<String, dynamic>> pagarCredito({
    required String creditoId,
    required double monto,
    int? numeroCuota,
  }) {
    return _api.post('/clientes/me/pagos-credito', body: {
      'credito_id': creditoId,
      'monto': monto,
      if (numeroCuota != null) 'numero_cuota': numeroCuota,
    });
  }

  Future<Map<String, dynamic>> simularCredito(double monto, int plazoMeses, double tea) {
    return _api.post('/creditos/simular', body: {'monto': monto, 'plazo_meses': plazoMeses, 'tea': tea});
  }

  Future<Map<String, dynamic>> crearSolicitudCredito({
    required double monto,
    required int plazoMeses,
    required String destino,
    String? garantia,
    bool seguroDesgravamen = true,
  }) {
    final tea = seguroDesgravamen ? 0.4092 : 0.4392;
    return _api.post('/clientes/me/solicitudes-credito', body: {
      'monto': monto,
      'plazo_meses': plazoMeses,
      'destino': destino,
      'garantia': garantia,
      'seguro_desgravamen': seguroDesgravamen,
      'producto_codigo': 'MICRO_CAPITAL',
      'tea': tea,
    });
  }

  Future<void> logout() => _api.clearToken();
  Future<void> limpiarSesion() => _api.clearToken();

  List<Map<String, dynamic>> _items(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is List) {
      return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
    }
    return const [];
  }
}
