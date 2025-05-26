// welcome_screen.dart
import './login_screen.dart';
import './signup_email_form.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool showEmailForm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: showEmailForm ? const SignUpEmailForm() : _buildWelcomeContent(context),
    );
  }

  Widget _buildWelcomeContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        const Icon(Icons.rocket_launch, size: 80, color: Color(0xFF7B44FF)),
        const SizedBox(height: 16),
        const Text(
          "Let’s Get Started!",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          "Let’s dive in into your account",
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 32),
        _customSocialButton("Continue with Google", "assets/icons/google.png"),
        _customSocialButton("Continue with Apple", "assets/icons/apple.png"),
        _customSocialButton("Continue with Facebook", "assets/icons/facebook.png"),
        _customSocialButton("Continue with X", "assets/icons/x.png"),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () => setState(() => showEmailForm = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B44FF),
                  minimumSize: const Size.fromHeight(50),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/email.png',
                      height: 20,
                      width: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Sign up with Email",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text.rich(
                  TextSpan(
                    text: "Already have an account? ",
                    style: TextStyle(color: Colors.black54),
                    children: [
                      TextSpan(
                        text: "Sign in",
                        style: TextStyle(
                          color: Color(0xFF7B44FF),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        const Text(
          "Privacy Policy  ·  Terms of Service",
          style: TextStyle(fontSize: 12, color: Colors.black45),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  static Widget _customSocialButton(String label, String imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6),
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 32, width: 32),
            const SizedBox(width: 12),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}