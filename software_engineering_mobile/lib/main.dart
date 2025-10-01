import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_screen.dart'; // Import your login screen
import 'repositories/shared_prefs_user_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp();
  // Initialize test data
  final repo = SharedPrefsUserRepository();
  await repo.findByEmail('john.doe@example.com'); // This will trigger initialization
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HippoExchange',
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFF87AE73, <int, Color>{
          50: Color(0xFFE8F3E7),
          100: Color(0xFFC5E1C0),
          200: Color(0xFFA0CE98),
          300: Color(0xFF7BBC71),
          400: Color(0xFF5FAF54),
          500: Color(0xFF87AE73), // Main green
          600: Color(0xFF6B8E5B),
          700: Color(0xFF4F6E43),
          800: Color(0xFF334E2B),
          900: Color(0xFF172E13),
        }),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: MaterialColor(0xFF87AE73, <int, Color>{
            50: Color(0xFFE8F3E7),
            100: Color(0xFFC5E1C0),
            200: Color(0xFFA0CE98),
            300: Color(0xFF7BBC71),
            400: Color(0xFF5FAF54),
            500: Color(0xFF87AE73),
            600: Color(0xFF6B8E5B),
            700: Color(0xFF4F6E43),
            800: Color(0xFF334E2B),
            900: Color(0xFF172E13),
          }),
        ).copyWith(
          secondary: Color(0xFF87AE73),
        ),
        scaffoldBackgroundColor: Color.fromARGB(255, 231, 228, 213),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginScreen(), // Set login screen as home
      debugShowCheckedModeBanner: false,
    );
  }
}