class Cuenta {
  final String id;
  final String tipo;
  final String numeroCuenta;
  final double saldo;
  final String moneda;

  const Cuenta({
    required this.id,
    required this.tipo,
    required this.numeroCuenta,
    required this.saldo,
    required this.moneda,
  });

  factory Cuenta.fromMap(Map<String, dynamic> map) => Cuenta(
        id: map['id'].toString(),
        tipo: map['tipo'] ?? 'Cuenta de ahorros',
        numeroCuenta: map['numero_cuenta'] ?? '',
        saldo: (map['saldo'] as num?)?.toDouble() ?? 0,
        moneda: map['moneda'] ?? 'PEN',
      );

  Map<String, dynamic> toMap(String clienteId) => {
        'cliente_id': clienteId,
        'tipo': tipo,
        'numero_cuenta': numeroCuenta,
        'saldo': saldo,
        'moneda': moneda,
      };
}
