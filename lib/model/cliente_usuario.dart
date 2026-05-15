class ClienteUsuario {
  final String id;
  final String dni;
  final String nombre;
  final String correo;

  ClienteUsuario({required this.id, required this.dni, required this.nombre, required this.correo});

  factory ClienteUsuario.fromMap(Map<String, dynamic> map) => ClienteUsuario(
    id: map['id'].toString(),
    dni: map['dni'] ?? '',
    nombre: map['nombre'] ?? '',
    correo: map['correo'] ?? '',
  );
}
