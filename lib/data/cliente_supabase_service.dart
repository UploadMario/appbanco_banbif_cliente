import '../model/cliente_usuario.dart';
import '../model/credito.dart';
import '../model/cuenta.dart';
import '../model/movimiento.dart';
import 'cliente_core_service.dart';

/// Adaptador temporal para imports antiguos.
///
/// Las operaciones criticas de la app cliente ya no consultan Supabase directo:
/// pasan por el Core FastAPI para respetar JWT, RBAC y reglas bancarias.
class ClienteSupabaseService {
  final ClienteCoreService _core = ClienteCoreService();

  Future<ClienteUsuario?> login(String dni, String password) async {
    try {
      return await _core.login(dni, password);
    } catch (_) {
      return null;
    }
  }

  Future<List<Cuenta>> obtenerCuentas(String clienteId) => _core.obtenerCuentas();
  Future<List<Credito>> obtenerCreditos(String clienteId) => _core.obtenerCreditos();
  Future<List<Movimiento>> obtenerMovimientos(String clienteId) => _core.obtenerMovimientos();

  Future<Cuenta> crearCuenta(String clienteId, Cuenta cuenta) => _blocked();
  Future<void> actualizarCuenta(Cuenta cuenta) => _blocked();
  Future<void> eliminarCuenta(String id) => _blocked();
  Future<Credito> crearCredito(String clienteId, Credito credito) => _blocked();
  Future<void> actualizarCredito(Credito credito) => _blocked();
  Future<void> eliminarCredito(String id) => _blocked();
  Future<Movimiento> crearMovimiento(String clienteId, Movimiento movimiento) => _blocked();
  Future<void> actualizarMovimiento(Movimiento movimiento) => _blocked();
  Future<void> eliminarMovimiento(String id) => _blocked();
  Future<ClienteUsuario> actualizarPerfil(ClienteUsuario usuario) => _blocked();

  Future<T> _blocked<T>() {
    return Future<T>.error(
      UnsupportedError('Operacion critica bloqueada: usa endpoints del Core BanBif.'),
    );
  }
}
