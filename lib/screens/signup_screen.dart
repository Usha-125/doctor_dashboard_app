import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final licenseController = TextEditingController();
  final treatmentController = TextEditingController();
  final otherHospitalsController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void _register() {
    // basic validation
    if (nameController.text.isEmpty ||
        licenseController.text.isEmpty ||
        treatmentController.text.isEmpty ||
        otherHospitalsController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    // TODO: add real register logic here
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFC107);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 1450),
            child: Row(
              children: [
                // ================= LEFT SIDE (LOGO + HAND) =================
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // BRAINI logo image
                      Image.asset(
                        "assets/images/braini_logo.png",
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),
                      // Hand illustration
                      Image.asset(
                        "assets/images/hand.png",
                        height: 480,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 40),

                // ================= RIGHT SIDE (FORM CARD) =================
                Expanded(
                  flex: 6,
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      border: Border.all(color: yellow, width: 1.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // BRAINI-X centered
                          Center(
                            child: Text(
                              "BRAINI-X",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: yellow,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // CREATE ACCOUNT centered
                          Center(
                            child: Text(
                              "CREATE ACCOUNT",
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.3,
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // ====== INPUT FIELDS (black background) ======
                          _inputBox("Full name", nameController, yellow),
                          const SizedBox(height: 22),

                          _inputBox("License number", licenseController, yellow),
                          const SizedBox(height: 22),

                          _inputBox(
                            "Hospital / Treatment",
                            treatmentController,
                            yellow,
                          ),
                          const SizedBox(height: 22),

                          _inputBox(
                            "Other hospitals working",
                            otherHospitalsController,
                            yellow,
                          ),
                          const SizedBox(height: 22),

                          _inputBox("Email", emailController, yellow),
                          const SizedBox(height: 22),

                          _inputBox(
                            "Password",
                            passwordController,
                            yellow,
                            obscure: true,
                          ),
                          const SizedBox(height: 22),

                          _inputBox(
                            "Confirm password",
                            confirmPasswordController,
                            yellow,
                            obscure: true,
                          ),

                          const SizedBox(height: 30),

                          // Register button
                          SizedBox(
                            width: 220,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: yellow,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _register,
                              child: const Text(
                                "Register",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Login link
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushReplacementNamed(context, '/login'),
                            child: Text(
                              "Already registered? Login",
                              style: TextStyle(
                                color: yellow,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =============== REUSABLE INPUT FIELD ===============
  Widget _inputBox(
    String label,
    TextEditingController controller,
    Color yellow, {
    bool obscure = false,
  }) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.black, // <-- input background BLACK (no grey)
        border: Border.all(color: yellow, width: 1.2),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle: TextStyle(
            color: yellow,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
