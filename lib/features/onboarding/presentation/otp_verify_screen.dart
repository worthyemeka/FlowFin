// otp_verify_screen.dart
// ignore_for_file: use_build_context_synchronously, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String email;
  const OtpVerifyScreen({super.key, required this.email});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final SupabaseClient supabase = Supabase.instance.client;
  bool isVerifying = false;
  String? errorText;

  void _verifyOtp() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length != 4) return;

    setState(() => isVerifying = true);

    final response = await supabase.auth.verifyOTP(
      type: OtpType.email,
      token: code,
      email: widget.email,
    );

    if (response.session != null) {
      // Navigate to dashboard or profile setup
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      setState(() {
        errorText = 'Invalid OTP. Please try again.';
        isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Enter 4-digit OTP",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text("Check your email: ${"****" + widget.email.substring(widget.email.length - 10)}"),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (i) {
                return SizedBox(
                  width: 60,
                  child: TextField(
                    controller: _controllers[i],
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      if (value.isNotEmpty && i < 3) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                    decoration: const InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            if (errorText != null)
              Text(errorText!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: isVerifying ? null : _verifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isVerifying ? Colors.grey : const Color(0xFF7B44FF),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text("Verify OTP",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
