// lib/shared/widgets/settings_ui_api.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/models/user.dart';
import '../../core/services/session_service.dart';
import '../../core/services/api_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _streetAddressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipcodeController = TextEditingController();

  bool _isLoading = false;



  @override
  void initState() {
    super.initState();

    _loadCurrentUserData();
  }

  Future<void> _loadCurrentUserData() async {
    final currentUser = await SessionService.getCurrentUser();
    if (currentUser != null) {
      _firstNameController.text = currentUser.firstName;
      _lastNameController.text = currentUser.lastName;
      _phoneController.text = currentUser.phone ?? '';
      _emailController.text = currentUser.email;
      _streetAddressController.text = currentUser.streetAddress ?? '';
      _cityController.text = currentUser.city ?? '';
      _stateController.text = currentUser.state ?? '';
      _zipcodeController.text = currentUser.zipcode ?? '';
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = await SessionService.getCurrentUser();
      if (currentUser == null) {
        _showErrorSnackBar('No user logged in');
        return;
      }

      final updateData = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        'streetAddress': _streetAddressController.text.trim().isEmpty ? null : _streetAddressController.text.trim(),
        'city': _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
        'state': _stateController.text.trim().isEmpty ? null : _stateController.text.trim(),
        'zipcode': _zipcodeController.text.trim().isEmpty ? null : _zipcodeController.text.trim(),
      };

      await ApiService.updateUser(currentUser.id!, updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) _showErrorSnackBar('Failed to update profile. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: const Color(0xFFE53E3E)),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _streetAddressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 231, 228, 213),
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF87AE73),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader('Personal Information'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField(controller: _firstNameController, label: 'First Name', validator: (v) => v == null || v.trim().isEmpty ? 'First name is required' : null)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(controller: _lastNameController, label: 'Last Name', validator: (v) => v == null || v.trim().isEmpty ? 'Last name is required' : null)),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(controller: _phoneController, label: 'Phone Number', keyboardType: TextInputType.phone, inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ]),
              const SizedBox(height: 16),
              _buildTextField(controller: _emailController, label: 'Email', keyboardType: TextInputType.emailAddress, validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return 'Please enter a valid email';
                return null;
              }),
              const SizedBox(height: 24),
              _buildSectionHeader('Address'),
              const SizedBox(height: 16),
              _buildTextField(controller: _streetAddressController, label: 'Street Address'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(flex: 2, child: _buildTextField(controller: _cityController, label: 'City')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(controller: _stateController, label: 'State', inputFormatters: [
                    LengthLimitingTextInputFormatter(2),
                    UpperCaseTextFormatter(),
                  ])),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(controller: _zipcodeController, label: 'ZIP Code', keyboardType: TextInputType.number, inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ])),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF87AE73),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                    : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF87AE73)));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF87AE73))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF87AE73), width: 2)),
        labelStyle: const TextStyle(color: Color(0xFF87AE73)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}