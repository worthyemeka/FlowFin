// signup_email_form.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './otp_verify_screen.dart';
import 'package:email_validator/email_validator.dart';

class SignUpEmailForm extends StatefulWidget {
  const SignUpEmailForm({super.key});

  @override
  State<SignUpEmailForm> createState() => _SignUpEmailFormState();
}

class _SignUpEmailFormState extends State<SignUpEmailForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool isEmailValid = false;
  bool showPasswordFields = false;
  bool obscurePassword = true;
  bool isChecked = false;

  double passwordStrength = 0;

  void checkPasswordStrength(String password) {
    double strength = 0;
    if (password.length >= 8) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.25;
    setState(() {
      passwordStrength = strength;
    });
  }

  bool get isFormValid =>
      isEmailValid &&
      _passwordController.text.isNotEmpty &&
      _passwordController.text == _confirmPasswordController.text &&
      isChecked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            size: 80,
            color: Color(0xFF7B44FF),
          ),
          const SizedBox(height: 16),
          const Text(
            "Sign up with Email",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Create your account below",
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              errorText: _emailController.text.isNotEmpty && !isEmailValid
                  ? 'Please enter a valid email'
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                isEmailValid = EmailValidator.validate(value);
                if (isEmailValid) showPasswordFields = true;
              });
            },
          ),
          if (showPasswordFields) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: obscurePassword,
              onChanged: (val) => checkPasswordStrength(val),
              decoration: InputDecoration(
                labelText: 'Create Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() => obscurePassword = !obscurePassword);
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: passwordStrength,
              backgroundColor: Colors.grey[300],
              color: passwordStrength < 0.5
                  ? Colors.red
                  : passwordStrength < 0.75
                  ? Colors.orange
                  : Colors.green,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: obscurePassword,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                errorText:
                    _confirmPasswordController.text.isNotEmpty &&
                        _confirmPasswordController.text !=
                            _passwordController.text
                    ? 'Passwords do not match'
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: (value) {
                    setState(() => isChecked = value ?? false);
                  },
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: "I agree to FlowFin's ",
                      style: const TextStyle(color: Colors.black87),
                      children: [
                        TextSpan(
                          text: 'Terms of Service',
                          style: const TextStyle(
                            color: Color(0xFF7B44FF),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: const TextStyle(
                            color: Color(0xFF7B44FF),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isFormValid
                  ? () async {
                      final email = _emailController.text.trim();
                      final password = _passwordController.text.trim();

                      try {
                        final response = await Supabase.instance.client.auth
                            .signUp(email: email, password: password);

                        if (response.user != null) {
                          if (!mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OtpVerifyScreen(email: email),
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Sign up failed: $e')),
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isFormValid
                    ? const Color(0xFF7B44FF)
                    : const Color(0xFFE0D7FF),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text(
                "Create Account",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
