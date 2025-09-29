import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;
  final logger = Logger();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Phase 1: Validate email input
  bool _validateEmail() {
    if (!(_formKey.currentState?.validate() ?? false)) return false;
    return true;
  }

  /// Phase 2: Send password reset email
  Future<void> _sendPasswordResetEmail() async {
    if (!_validateEmail()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Implement actual password reset API call
      // Example: await AuthService().sendPasswordResetEmail(_emailController.text.trim());

      logger.i(
        'Sending password reset email to: ${_emailController.text.trim()}',
      );

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Handle actual response from server
      // if (response.success) {
      //   setState(() => _emailSent = true);
      // } else {
      //   _showErrorSnackBar(response.error);
      // }

      // For now, simulate success
      setState(() => _emailSent = true);
    } catch (e) {
      logger.e('Error sending password reset email: $e');
      _showErrorSnackBar('Failed to send reset email. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Phase 3: Show error message
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// Phase 4: Navigate back to login
  void _goBackToLogin() {
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 231, 228, 213),
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: const Color(0xFF87AE73),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Header Section
              Center(
                child: Icon(
                  Icons.lock_reset,
                  size: 80,
                  color: const Color(0xFF87AE73),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Reset Your Password',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),

              Text(
                _emailSent
                    ? 'Check your email for reset instructions'
                    : 'Enter your email address and we\'ll send you a link to reset your password',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),

              if (!_emailSent) ...[
                // Email Input Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email address';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _sendPasswordResetEmail(),
                      ),
                      const SizedBox(height: 24),

                      // Send Reset Email Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : _sendPasswordResetEmail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF87AE73),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Send Reset Email',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Success State
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    border: Border.all(color: Colors.green.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 60,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Email Sent Successfully!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please check your email and follow the instructions to reset your password.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.green.shade600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Resend Email Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _emailSent = false);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF87AE73),
                      side: const BorderSide(color: Color(0xFF87AE73)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Send Another Email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Back to Login Button
              TextButton(
                onPressed: _goBackToLogin,
                child: const Text(
                  'Back to Login',
                  style: TextStyle(
                    color: Color(0xFF87AE73),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
