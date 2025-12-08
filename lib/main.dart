import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/patient_details_screen.dart';
import 'models/patient.dart';

void main() {
  runApp(const DoctorDashboardApp());
}

class DoctorDashboardApp extends StatelessWidget {
  const DoctorDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doctor Dashboard',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0E1B1E),
        fontFamily: "Poppins",

        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.tealAccent,
          brightness: Brightness.dark,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.tealAccent.shade400,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white10,
          labelStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      initialRoute: '/',

      routes: {
        '/': (context) => const SignupScreen(),

  
        // Make sure your class name in signup_screen.dart is `SignupScreen`
        '/login': (context) => const LoginScreen(),

        // ❌ no const here because DashboardScreen has non-const fields
        '/dashboard': (context) => DashboardScreen(),

        // Patient details route – receives Patient via arguments
        '/patientDetails': (context) {
          final patient =
              ModalRoute.of(context)!.settings.arguments as Patient;
          return PatientDetailsScreen(patient: patient);
        },
      },
    );
  }
}
