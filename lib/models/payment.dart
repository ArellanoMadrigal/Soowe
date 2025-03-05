import 'dart:convert';

class Payment {
  final double amount;
  final String paymentMethod;
  final DateTime paymentDate;
  final String status;
  final String? details;
  final int requestId;

  Payment({
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    required this.status,
    this.details,
    required this.requestId,
  });

  Map<String, dynamic> toJson() {
    return {
      'monto': amount,
      'metodo_pago': paymentMethod,
      'fecha_pago': paymentDate.toIso8601String(),
      'estado': status,
      'detalles': details,
      'solicitud_id': requestId,
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      amount: json['monto'] ?? 0.0,
      paymentMethod: json['metodo_pago'] ?? '',
      paymentDate: DateTime.parse(json['fecha_pago'] ?? DateTime.now().toIso8601String()),
      status: json['estado'] ?? '',
      details: json['detalles'] ?? '',
      requestId: json['solicitud_id'] ?? '',
    );
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}