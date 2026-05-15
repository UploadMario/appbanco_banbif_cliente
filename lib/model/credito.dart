class Credito {
  final String producto;
  final double montoPendiente;
  final double cuotaMensual;
  final String estado;

  Credito({required this.producto, required this.montoPendiente, required this.cuotaMensual, required this.estado});

  factory Credito.fromMap(Map<String, dynamic> map) => Credito(
    producto: map['producto'] ?? '',
    montoPendiente: (map['monto_pendiente'] as num?)?.toDouble() ?? 0,
    cuotaMensual: (map['cuota_mensual'] as num?)?.toDouble() ?? 0,
    estado: map['estado'] ?? '',
  );
}
