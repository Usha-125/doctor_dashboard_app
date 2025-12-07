// lib/screens/patient_details_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/patient.dart';

class PatientDetailsScreen extends StatelessWidget {
  final Patient patient;

  const PatientDetailsScreen({
    Key? key,
    required this.patient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Details"),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------- Patient Identity Card --------
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Age: ${patient.age}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Condition: ${patient.disorder}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // -------- Medical Records --------
              const Text(
                "Medical Records",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              ...patient.medicalRecords.map(
                (record) => Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      "• $record",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // -------- Medicines List --------
              const Text(
                "Prescribed Medicines",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              ...patient.medicines.map(
                (med) => ListTile(
                  leading: const Icon(
                    Icons.medical_services,
                    color: Colors.blue,
                  ),
                  title: Text(
                    med['name'] ?? '',
                    style: const TextStyle(fontSize: 16),
                  ),
                  subtitle: Text("Dosage: ${med['dosage'] ?? ''}"),
                ),
              ),

              const SizedBox(height: 30),

              // -------- Chart Section --------
              const Text(
                "Improvement Progress",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Container(
                height: 250,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.blueAccent.withOpacity(0.05),
                ),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                        ),
                      ),
                      // Hide top & right titles
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: const Border(
                        left: BorderSide(color: Colors.grey),
                        bottom: BorderSide(color: Colors.grey),
                        right: BorderSide(color: Colors.transparent),
                        top: BorderSide(color: Colors.transparent),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        spots: patient.improvementStats
                            .asMap()
                            .entries
                            .map(
                              (e) => FlSpot(
                                e.key.toDouble(), // x = index
                                e.value,          // y = value
                              ),
                            )
                            .toList(),
                        barWidth: 4,
                        color: Colors.blueAccent,
                        dotData: FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
