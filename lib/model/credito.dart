class Credito {
  final String id;
  final String producto;
  final double montoPendiente;
  final double cuotaMensual;
  final String estado;

  const Credito({
    required this.id,
    required this.producto,
    required this.montoPendiente,
    required this.cuotaMensual,
    required this.estado,
  });

  factory Credito.fromMap(Map<String, dynamic> map) => Credito(
        id: map['id'].toString(),
        producto: map['producto'] ?? '',
        montoPendiente: (map['monto_pendiente'] as num?)?.toDouble() ?? 0,
        cuotaMensual: (map['cuota_mensual'] as num?)?.toDouble() ?? 0,
        estado: map['estado'] ?? '',
      );

  Map<String, dynamic> toMap(String clienteId) => {
        'cliente_id': clienteId,
        'producto': producto,
        'monto_pendiente': montoPendiente,
        'cuota_mensual': cuotaMensual,
        'estado': estado,
      };
}
