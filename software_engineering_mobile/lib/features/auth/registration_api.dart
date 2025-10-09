// lib/registration_page.dart
//
// Registers a user by saving it into SharedPreferences via the repository,
// then sets the activeUserId so the session is "logged in".
// Only logic was changed to remove calls to an old AuthService.register API.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../shared/widgets/main_navigation.dart'; // or wherever you go after registration
import '../../core/api/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _busy = false;
  String? _error;

final logger = Logger();

Future<void> _register() async {
  if (_busy) return;
  if (!(_formKey.currentState?.validate() ?? false)) return;

  setState(() {
    _busy = true;
    _error = null;
  });

  final userPayload = {
    "email": _emailCtrl.text.trim(),
    "password": _passwordCtrl.text, // hash in production!
    "firstName": _firstNameCtrl.text.trim(),
    "lastName": _lastNameCtrl.text.trim(),
    "phone": _phoneCtrl.text.trim(),
    "currency": 0.0,
    "assets": [],
    "hippoBalanceCents": 0
  };

  logger.i("Starting registration with payload: $userPayload");

  try {
    final response = await http.post(
      Uri.parse(ApiConfig.buildUrl(ApiConfig.registerEndpoint)),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(userPayload),
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw Exception('Registration timeout. Please check your connection and try again.');
      },
    );

    logger.i("Received response with status: ${response.statusCode}");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('activeUserId', body['id']);
      logger.i("Registration successful. User ID: ${body['id']}");

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
        (route) => false,
      );
    } else {
      final error = jsonDecode(response.body)['error'];
      if (mounted) {
        setState(() => _error = error ?? 'Registration failed.');
      }
      logger.w("Registration failed: $_error");
    }
  } catch (e, stackTrace) {
    if (mounted) {
      setState(() => _error = e.toString().contains('timeout') 
          ? e.toString() 
          : 'Registration failed. Please try again.');
    }
    logger.e("Exception during registration", error: e, stackTrace: stackTrace);
  } finally {
    if (mounted) {
      setState(() => _busy = false);
    }
    logger.i("Registration process ended");
  }
}


  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keep simple look; copy the colors you use elsewhere.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: const Color(0xFF87AE73),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        FaIcon(FontAwesomeIcons.triangleExclamation, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'First name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'First name required'
                                : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Last name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Last name required'
                                : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email required';
                    final ok = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$')
                        .hasMatch(v.trim());
                    return ok ? null : 'Enter a valid email';
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[0-9+\-\s\(\)]'),
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    hintText: '+1 (555) 123-4567 or (555) 123-4567',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Phone number required';
                    }
                    final input = v.trim();
                    final digitsOnly = input.replaceAll(RegExp(r'[^0-9]'), '');

                    // If input includes country code (e.g., starts with '+'),
                    // require total digits to be 11-13, with the last 10 as national number.
                    if (input.startsWith('+')) {
                      if (digitsOnly.length < 11 || digitsOnly.length > 13) {
                        return 'Include country code (+XX) and 10-digit number';
                      }
                      final national = digitsOnly.substring(digitsOnly.length - 10);
                      if (national.length != 10) {
                        return 'National number must be 10 digits';
                      }
                      return null;
                    }

                    // No country code provided: require exactly 10 digits (national number).
                    if (digitsOnly.length != 10) {
                      return 'Enter a 10-digit number; country code optional';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password required';
                    if (v.length < 6) return 'Min 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmPasswordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (v != _passwordCtrl.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _busy ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF87AE73),
                      foregroundColor: Colors.white,
                    ),
                    child: _busy
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text('Creating account...'),
                            ],
                          )
                        : const Text('Create account'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
