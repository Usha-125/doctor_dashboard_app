// lib/models/patient.dart

class Patient {
  final String name;
  final int age;
  final String disorder;

  // New fields
  final List<String> medicalRecords;
  final List<Map<String, String>> medicines; // {name, dosage}
  final List<double> improvementStats; // Chart data points

  const Patient({
    required this.name,
    required this.age,
    required this.disorder,
    required this.medicalRecords,
    required this.medicines,
    required this.improvementStats,
  });
}
