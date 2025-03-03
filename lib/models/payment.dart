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
      'amount': amount,
      'payment_method': paymentMethod,
      'payment_date': paymentDate.toIso8601String(),
      'status': status,
      'details': details,
      'request_id': requestId,
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      amount: json['amount'].toDouble(),
      paymentMethod: json['payment_method'],
      paymentDate: DateTime.parse(json['payment_date']),
      status: json['status'],
      details: json['details'],
      requestId: json['request_id'],
    );
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}