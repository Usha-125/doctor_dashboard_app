import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final nameController = TextEditingController();
  final licenseController = TextEditingController();
  final treatmentController = TextEditingController();
  final otherHospitalsController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  late AnimationController _animController;
  late Animation<double> _blurAnimation;
  late Animation<double> _opacityAnimation;

  bool _showForm = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _blurAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward();

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) setState(() => _showForm = true);
        });
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) return 'Email required';
    final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!re.hasMatch(email)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String password) {
    if (password.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> _register() async {
    final emailErr = _validateEmail(emailController.text.trim());
    final passErr = _validatePassword(passwordController.text);
    if (emailErr != null || passErr != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(emailErr ?? passErr!)),
      );
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final user = cred.user;
      if (user != null) {
        await _db.collection('doctors').doc(user.uid).set({
          'name': nameController.text.trim(),
          'license': licenseController.text.trim(),
          'treatment': treatmentController.text.trim(),
          'otherHospitals': otherHospitalsController.text.trim(),
          'email': emailController.text.trim(),
          'uid': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Authentication error')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/images/braini_logo.png", height: 120),
                      const SizedBox(height: 20),
                      Image.asset("assets/images/hand.png",
                          height: 480, fit: BoxFit.contain),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
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
                          Text("BRAINI-X",
                              style: TextStyle(
                                  fontSize: 24,
                                  color: yellow,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          const Text("CREATE ACCOUNT",
                              style: TextStyle(
                                  fontSize: 26,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 32),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 600),
                            child: _showForm
                                ? _buildForm(yellow)
                                : _buildAboutAnimation(),
                          ),
                          if (_loading) ...[
                            const SizedBox(height: 20),
                            const CircularProgressIndicator(),
                          ],
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutAnimation() {
    const aboutText =
        "SYNAPSE (Switch-Controlled Yoked Navigated & Adaptive Prosthetic Support Equipment) is an affordable and user-friendly wrist-hand orthosis designed to help individuals with upper-limb weakness regain functional independence. Using a simple three-state switch and smart sensor feedback, the device supports everyday hand movements like grasping and releasing while also assisting muscle rehabilitation. It features ESP32-based wireless control, adaptive grip force, and a lightweight cable-driven design, making it ideal for both home and clinical use.";

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
                sigmaX: _blurAnimation.value, sigmaY: _blurAnimation.value),
            child: child,
          ),
        );
      },
      child: const Text(
        aboutText,
        key: ValueKey("about"),
        textAlign: TextAlign.justify,
        style: TextStyle(fontSize: 16, color: Colors.white, height: 1.4),
      ),
    );
  }

  Widget _buildForm(Color yellow) {
    return Column(
      key: const ValueKey("form"),
      children: [
        _box("Full name", nameController, yellow),
        const SizedBox(height: 20),
        _box("License number", licenseController, yellow),
        const SizedBox(height: 20),
        _box("Hospital / Treatment", treatmentController, yellow),
        const SizedBox(height: 20),
        _box("Other hospitals working", otherHospitalsController, yellow),
        const SizedBox(height: 20),
        _box("Email", emailController, yellow),
        const SizedBox(height: 20),
        _box("Password", passwordController, yellow, obscure: true),
        const SizedBox(height: 20),
        _box("Confirm password", confirmPasswordController, yellow,
            obscure: true),
        const SizedBox(height: 28),
        SizedBox(
          width: 220,
          height: 52,
          child: ElevatedButton(
            onPressed: _register,
            style: ElevatedButton.styleFrom(
                backgroundColor: yellow,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text("Register",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/login'),
          child: Text("Already registered? Login",
              style: TextStyle(
                  color: yellow,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline)),
        )
      ],
    );
  }

  Widget _box(String label, TextEditingController controller, Color yellow,
      {bool obscure = false}) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: yellow, width: 1.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle: TextStyle(
              color: yellow, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
