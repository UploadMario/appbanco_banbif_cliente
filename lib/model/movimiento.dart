class Movimiento {
  final String descripcion;
  final double monto;
  final String tipo;
  final DateTime fecha;

  Movimiento({required this.descripcion, required this.monto, required this.tipo, required this.fecha});

  factory Movimiento.fromMap(Map<String, dynamic> map) => Movimiento(
    descripcion: map['descripcion'] ?? '',
    monto: (map['monto'] as num?)?.toDouble() ?? 0,
    tipo: map['tipo'] ?? '',
    fecha: DateTime.tryParse(map['fecha']?.toString() ?? '') ?? DateTime.now(),
  );
}
