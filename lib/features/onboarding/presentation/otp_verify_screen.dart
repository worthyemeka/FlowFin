import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import '../../dashboard/presentation/dashboard_screen.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String phone;
  final String userId;

  const VerifyOtpScreen({
    super.key,
    required this.phone,
    required this.userId,
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  final client = Client()
  .setEndpoint('https://fra.cloud.appwrite.io/v1')
  .setProject('68359985001faec26b41') // your real project ID
  .setSelfSigned(status: true); // only if not in production

  late final Account account = Account(client);

  bool isVerifying = false;
  String? errorText;

  void _verifyOtp() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length != 4) return;

    setState(() => isVerifying = true);

    try {
      await account.updatePhoneSession(
        userId: widget.userId,
        secret: code,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } catch (e) {
      setState(() {
        errorText = e.toString();
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
            const Text(
              "Enter 4-digit OTP",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text("Check your phone: ${widget.phone}"),
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

                      if (_controllers.every((c) => c.text.isNotEmpty)) {
                        _verifyOtp();
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
                backgroundColor: isVerifying ? Colors.grey : const Color(0xFF7B44FF),
                minimumSize: const Size.fromHeight(50),
              ),
              child: isVerifying
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Verify OTP", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
