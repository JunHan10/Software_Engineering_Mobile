// lib/registration_page.dart
//
// Registers a user by saving it into SharedPreferences via the repository,
// then sets the activeUserId so the session is "logged in".
// Only logic was changed to remove calls to an old AuthService.register API.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

import 'main_navigation.dart'; // or wherever you go after registration
import 'api/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();

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
    "age": int.tryParse(_ageCtrl.text.trim()),
    "streetAddress": _streetCtrl.text.trim(),
    "city": _cityCtrl.text.trim(),
    "state": _stateCtrl.text.trim(),
    "zipcode": _zipCtrl.text.trim(),
    "currency": 0.0,
    "assets": [],
    "hippoBalanceCents": 0
  };

  logger.i("Starting registration with payload: $userPayload");

  try {
    final response = await http.post(
      Uri.parse(ApiConfig.register),
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
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _ageCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _zipCtrl.dispose();
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
                        Icon(Icons.error_outline, color: Colors.red.shade700),
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
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Email required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                  (v == null || v.isEmpty) ? 'Password required' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'First name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Last name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _ageCtrl,
                  keyboardType:
                  const TextInputType.numberWithOptions(signed: false),
                  decoration: const InputDecoration(
                    labelText: 'Age (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _streetCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Street address (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cityCtrl,
                        decoration: const InputDecoration(
                          labelText: 'City (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _stateCtrl,
                        decoration: const InputDecoration(
                          labelText: 'State (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _zipCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Zip (optional)',
                    border: OutlineInputBorder(),
                  ),
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
