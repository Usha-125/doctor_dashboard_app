// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import '../models/patient.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({Key? key}) : super(key: key);

  final List<Patient> patients = [
    Patient(
      name: "Rohan Sharma",
      age: 45,
      disorder: "Osteoporosis",
      medicalRecords: [
        "X-Ray shows reduced bone density",
        "Vitamin D deficiency level",
        "Follow-up scheduled next month",
      ],
      medicines: [
        {"name": "Calcium Tablets", "dosage": "500mg daily"},
        {"name": "Vitamin D3", "dosage": "2000 IU daily"},
      ],
      improvementStats: [10, 20, 30, 50, 60, 75],
    ),
    Patient(
      name: "Priya Verma",
      age: 32,
      disorder: "Fracture (Leg)",
      medicalRecords: [
        "Cast placed on left leg",
        "Swelling reduced",
        "Patient recovering well",
      ],
      medicines: [
        {"name": "Pain Relief", "dosage": "Two times a day"},
        {"name": "Bone Healing Syrup", "dosage": "Once after meals"},
      ],
      improvementStats: [5, 10, 20, 40, 50, 80],
    ),
    Patient(
      name: "Aditya Mehta",
      age: 60,
      disorder: "Arthritis",
      medicalRecords: [
        "Joint stiffness observed",
        "Anti-inflammatory treatment started",
        "Patient suggested yoga sessions",
      ],
      medicines: [
        {
          "name": "Anti-inflammatory tablets",
          "dosage": "Twice daily",
        },
        {"name": "Joint Supplement", "dosage": "One tablet daily"},
      ],
      improvementStats: [15, 18, 25, 35, 50, 65],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Dashboard"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 Animated Welcome Header
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.2),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "👋 Welcome Doctor",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.tealAccent,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Your patients are waiting. Heal with purpose 💙",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Patients List
            Expanded(
              child: ListView.builder(
                itemCount: patients.length,
                itemBuilder: (context, index) {
                  final patient = patients[index];

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patient.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text("Age: ${patient.age}"),
                          Text("Condition: ${patient.disorder}"),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/patientDetails',
                                  arguments: patient,
                                );
                              },
                              child: const Text("View Details"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
