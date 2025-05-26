// check_inbox_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckInboxScreen extends StatefulWidget {
  final String email;
  const CheckInboxScreen({super.key, required this.email});

  @override
  State<CheckInboxScreen> createState() => _CheckInboxScreenState();
}

class _CheckInboxScreenState extends State<CheckInboxScreen> {
  int _seconds = 30;
  late Timer _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        setState(() => _canResend = true);
        timer.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _resendMagicLink() async {
    try {
      await Supabase.instance.client.auth.signUp(
        email: widget.email,
        password: '', // No password needed if user already exists
        emailRedirectTo: 'flowfin://kyc-start',
      );
      setState(() {
        _seconds = 30;
        _canResend = false;
      });
      _startTimer();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to resend: $e')),
      );
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
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mark_email_read_rounded, size: 64, color: Color(0xFF7B44FF)),
            const SizedBox(height: 24),
            const Text(
              "We’ve sent you something!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              "Please check your inbox and confirm your email to continue.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            Text.rich(
              TextSpan(
                text: "Haven’t seen it yet? ",
                style: const TextStyle(color: Colors.black87),
                children: [
                  _canResend
                      ? TextSpan(
                          text: "Resend magic link",
                          style: const TextStyle(
                            color: Color(0xFF7B44FF),
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = _resendMagicLink,
                        )
                      : TextSpan(
                          text: "Resend in $_seconds s",
                          style: const TextStyle(color: Colors.black54),
                        ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
