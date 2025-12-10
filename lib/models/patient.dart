// lib/models/patient.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  final String id;
  final String name;
  final int? age;
  final Timestamp? createdAt;
  final Map<String, dynamic>? extra;

  Patient({
    required this.id,
    required this.name,
    this.age,
    this.createdAt,
    this.extra,
  });

  factory Patient.fromDoc(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return Patient(
      id: doc.id,
      name: data['name']?.toString() ?? '—',
      age: data['age'] is int
          ? data['age'] as int
          : (data['age'] != null ? int.tryParse(data['age'].toString()) : null),
      createdAt: data['createdAt'] as Timestamp?,
      extra: data,
    );
  }
}
