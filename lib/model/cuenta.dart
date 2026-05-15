class Cuenta {
  final String id;
  final String tipo;
  final String numeroCuenta;
  final double saldo;
  final String moneda;

  Cuenta({required this.id, required this.tipo, required this.numeroCuenta, required this.saldo, required this.moneda});

  factory Cuenta.fromMap(Map<String, dynamic> map) => Cuenta(
    id: map['id'].toString(),
    tipo: map['tipo'] ?? 'Cuenta de ahorros',
    numeroCuenta: map['numero_cuenta'] ?? '',
    saldo: (map['saldo'] as num?)?.toDouble() ?? 0,
    moneda: map['moneda'] ?? 'PEN',
  );
}
