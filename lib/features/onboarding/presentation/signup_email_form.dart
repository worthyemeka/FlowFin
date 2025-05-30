// ignore_for_file: await_only_futures, unused_import

import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import '../../onboarding/presentation/welcome_screen.dart';
import 'package:appwrite/appwrite.dart';
import '../../onboarding/presentation/check_inbox_screen.dart';
import '../../../appwrite/appwrite_service.dart';

class SignUpEmailForm extends StatefulWidget {
  const SignUpEmailForm({super.key});

  @override
  State<SignUpEmailForm> createState() => _SignUpEmailFormState();
}

class _SignUpEmailFormState extends State<SignUpEmailForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool isEmailValid = false;
  bool showPasswordFields = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isChecked = false;
  bool isLoading = false;
  double passwordStrength = 0;

  final client = Client()
  .setEndpoint('https://fra.cloud.appwrite.io/v1')
  .setProject('68359985001faec26b41') // your real project ID
  .setSelfSigned(status: true); // only if not in production
  late final Account account = Account(client);

  void checkPasswordStrength(String password) {
    double strength = 0;
    if (password.length >= 8) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[!@#\\$%^&*(),.?":{}|<>]').hasMatch(password)) {
      strength += 0.25;
    }
    setState(() => passwordStrength = strength);
  }

  bool get isFormValid =>
      isEmailValid &&
      _passwordController.text.isNotEmpty &&
      _passwordController.text == _confirmPasswordController.text &&
      isChecked;

  void showEmailExistsModal() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Email Already Exists"),
        content: const Text("An account with this email already exists. Please log in or use another email."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK", style: TextStyle(color: Color(0xFF7B44FF))),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const WelcomeScreen()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.lock_outline_rounded, size: 80, color: Color(0xFF7B44FF)),
            const SizedBox(height: 16),
            const Text("Sign up with Email", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Create your account below", style: TextStyle(color: Colors.black54)),
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
                onChanged: checkPasswordStrength,
                decoration: InputDecoration(
                  labelText: 'Create Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() => obscurePassword = !obscurePassword),
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
                obscureText: obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  errorText: _confirmPasswordController.text.isNotEmpty &&
                          _confirmPasswordController.text != _passwordController.text
                      ? 'Passwords do not match'
                      : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() => obscureConfirmPassword = !obscureConfirmPassword),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: isChecked,
                    onChanged: (value) => setState(() => isChecked = value ?? false),
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
                onPressed: isFormValid && !isLoading
                    ? () async {
                        FocusScope.of(context).unfocus();
                        setState(() => isLoading = true);
                        final email = _emailController.text.trim();
                        final password = _passwordController.text.trim();

                        try {
                          await account.create(
                            userId: ID.unique(),
                            email: email,
                            password: password,
                          );

                          await account.createVerification(
                            url: 'https://profile-confirmation-message.vercel.app/',
                          );

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CheckEmailScreen(email: email),
                            ),
                          );
                        } on AppwriteException catch (e) {
                          if (e.code == 409) {
                            showEmailExistsModal();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Sign up failed: ${e.message}')),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => isLoading = false);
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFormValid ? const Color(0xFF7B44FF) : const Color(0xFFE0D7FF),
                  minimumSize: const Size.fromHeight(50),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Create Account", style: TextStyle(color: Colors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
