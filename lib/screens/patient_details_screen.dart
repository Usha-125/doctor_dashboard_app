// lib/screens/patient_details_screen.dart
import 'package:flutter/material.dart';

class PatientDetailsScreen extends StatelessWidget {
  const PatientDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (args == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Details')),
        body: const Center(child: Text('No data provided')),
      );
    }

    final id = args['id'] as String? ?? 'Unknown ID';
    final data = (args['data'] as Map<String, dynamic>?) ?? {};

    return Scaffold(
      appBar: AppBar(title: Text(data['name']?.toString() ?? 'Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("User ID: $id", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ..._buildFieldsList(data),
            ],
          ),
        ),
      ),
    );
  }

  // Convert the data map into a list of widgets.
  static List<Widget> _buildFieldsList(Map<String, dynamic> data) {
    if (data.isEmpty) {
      return [const Text('No fields available')];
    }

    final List<Widget> rows = [];
    data.forEach((key, value) {
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$key: ', style: const TextStyle(fontWeight: FontWeight.bold)),
              Expanded(child: Text(value?.toString() ?? '')),
            ],
          ),
        ),
      );
    });
    return rows;
  }
}
