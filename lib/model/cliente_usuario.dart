class ClienteUsuario {
  final String id;
  final String dni;
  final String nombre;
  final String correo;

  const ClienteUsuario({
    required this.id,
    required this.dni,
    required this.nombre,
    required this.correo,
  });

  factory ClienteUsuario.fromMap(Map<String, dynamic> map) => ClienteUsuario(
        id: map['id'].toString(),
        dni: map['dni'] ?? '',
        nombre: map['nombre'] ?? '',
        correo: map['correo'] ?? '',
      );

  factory ClienteUsuario.fromCoreUser(Map<String, dynamic> map) =>
      ClienteUsuario(
        id: (map['cliente_id'] ?? map['user_id']).toString(),
        dni: map['documento']?.toString() ?? '',
        nombre: map['display_name']?.toString() ?? '',
        correo: map['email']?.toString() ?? '',
      );

  ClienteUsuario copyWith({String? nombre, String? correo}) => ClienteUsuario(
        id: id,
        dni: dni,
        nombre: nombre ?? this.nombre,
        correo: correo ?? this.correo,
      );
}
