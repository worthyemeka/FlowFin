// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/onboarding/presentation/splash_screen.dart';
import 'core/theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://vcciugkvxmxufirffqts.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZjY2l1Z2t2eG14dWZpcmZmcXRzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgyNjEyODcsImV4cCI6MjA2MzgzNzI4N30.Oo2jY-VgMdMZXESJRUpQng1ABJPd4pn7d3xT8xn4HCQ',
  );
  runApp(const ProviderScope(child: FlowFinApp()));
}

class FlowFinApp extends StatelessWidget {
  const FlowFinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlowFin',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.light,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        textTheme: GoogleFonts.urbanistTextTheme(),
      ),
      home: const SplashScreen(),
    );
  }
}