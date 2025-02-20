import 'package:flutter/material.dart';

class Service {
  final String id;
  final String title;
  final String description;
  final double price;
  final String createdAt;
  final String createdBy;

  Service({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    String? createdAt,
    String? createdBy,
  })  : createdAt = createdAt ?? '2025-02-19 04:10:37',
        createdBy = createdBy ?? 'ArellanoMadrigal';

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: json['price'] as double,
      createdAt: json['created_at'] as String?,
      createdBy: json['created_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'created_at': createdAt,
      'created_by': createdBy,
    };
  }
}

class ServiceCategory {
  final String id;
  final String title;
  final List<Service> services;
  final String createdAt;
  final String createdBy;

  ServiceCategory({
    required this.id,
    required this.title,
    required this.services,
    String? createdAt,
    String? createdBy,
  })  : createdAt = createdAt ?? '2025-02-19 04:10:37',
        createdBy = createdBy ?? 'ArellanoMadrigal';

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] as String,
      title: json['title'] as String,
      services: (json['services'] as List)
          .map((service) => Service.fromJson(service))
          .toList(),
      createdAt: json['created_at'] as String?,
      createdBy: json['created_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'services': services.map((service) => service.toJson()).toList(),
      'created_at': createdAt,
      'created_by': createdBy,
    };
  }
}

enum PaymentMethod { 
  card, 
  cash 
}

class PaymentInfo {
  final PaymentMethod method;
  final Map<String, String>? cardInfo;
  final String createdAt;
  final String createdBy;

  PaymentInfo({
    required this.method,
    this.cardInfo,
    String? createdAt,
    String? createdBy,
  })  : createdAt = createdAt ?? '2025-02-19 04:10:37',
        createdBy = createdBy ?? 'ArellanoMadrigal';

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      method: PaymentMethod.values.firstWhere(
        (e) => e.toString() == 'PaymentMethod.${json['method']}',
      ),
      cardInfo: json['card_info'] != null
          ? Map<String, String>.from(json['card_info'])
          : null,
      createdAt: json['created_at'] as String?,
      createdBy: json['created_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method.toString().split('.').last,
      'card_info': cardInfo,
      'created_at': createdAt,
      'created_by': createdBy,
    };
  }
}

class MedicalRequest {
  final String id;
  final Service service;
  final DateTime date;
  final TimeOfDay time;
  final Map<String, dynamic> patient;
  final Map<String, dynamic> location;
  final PaymentInfo payment;
  final String status;
  final String createdAt;
  final String createdBy;

  MedicalRequest({
    required this.id,
    required this.service,
    required this.date,
    required this.time,
    required this.patient,
    required this.location,
    required this.payment,
    required this.status,
    String? createdAt,
    String? createdBy,
  })  : createdAt = createdAt ?? '2025-02-19 04:10:37',
        createdBy = createdBy ?? 'ArellanoMadrigal';

  factory MedicalRequest.fromJson(Map<String, dynamic> json) {
    return MedicalRequest(
      id: json['id'] as String,
      service: Service.fromJson(json['service']),
      date: DateTime.parse(json['date']),
      time: TimeOfDay(
        hour: int.parse(json['time'].split(':')[0]),
        minute: int.parse(json['time'].split(':')[1]),
      ),
      patient: json['patient'] as Map<String, dynamic>,
      location: json['location'] as Map<String, dynamic>,
      payment: PaymentInfo.fromJson(json['payment']),
      status: json['status'] as String,
      createdAt: json['created_at'] as String?,
      createdBy: json['created_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service': service.toJson(),
      'date': date.toIso8601String(),
      'time': '${time.hour}:${time.minute}',
      'patient': patient,
      'location': location,
      'payment': payment.toJson(),
      'status': status,
      'created_at': createdAt,
      'created_by': createdBy,
    };
  }
}

class Constants {
  static const String currentDateTime = '2025-02-19 04:10:37';
  static const String currentUser = 'ArellanoMadrigal';
  
  static const Map<String, double> defaultPrices = {
    'Sutura de heridas': 400.00,
    'Curación básica': 250.00,
    'Inyección': 150.00,
    'Consulta general': 300.00,
  };
}


