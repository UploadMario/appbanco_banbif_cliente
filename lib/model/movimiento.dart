class Movimiento {
  final String id;
  final String descripcion;
  final double monto;
  final String tipo;
  final DateTime fecha;

  const Movimiento({
    required this.id,
    required this.descripcion,
    required this.monto,
    required this.tipo,
    required this.fecha,
  });

  factory Movimiento.fromMap(Map<String, dynamic> map) => Movimiento(
        id: map['id'].toString(),
        descripcion: map['descripcion'] ?? '',
        monto: (map['monto'] as num?)?.toDouble() ?? 0,
        tipo: map['tipo'] ?? '',
        fecha:
            DateTime.tryParse(map['fecha']?.toString() ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toMap(String clienteId) => {
        'cliente_id': clienteId,
        'descripcion': descripcion,
        'monto': monto,
        'tipo': tipo,
        'fecha': fecha.toIso8601String(),
      };
}
