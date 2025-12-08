import 'package:flutter/material.dart';
import '../models/patient.dart';

class PatientDetailsScreen extends StatelessWidget {
  final Patient patient;
  const PatientDetailsScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(patient.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Name: ${patient.name}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 12),
            Text('Age: ${patient.age ?? '—'}'),
            const SizedBox(height: 12),
            Text('Raw data: ${patient.extra ?? {}}'),
          ],
        ),
      ),
    );
  }
}
