import 'package:flutter/material.dart';
import '../../core/models/user.dart';
import '../../core/services/server_auth_service.dart';
import '../../core/services/api_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  // ServerAuthService methods are used statically; no instance required.

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  User? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await ServerAuthService.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _user = user;
      _firstNameController.text = user?.firstName ?? '';
      _lastNameController.text = user?.lastName ?? '';
      _emailController.text = user?.email ?? '';
      _phoneController.text = user?.phone ?? '';
      _streetController.text = user?.streetAddress ?? '';
      _cityController.text = user?.city ?? '';
      _stateController.text = user?.state ?? '';
      _zipController.text = user?.zipcode ?? '';
      _bioController.text = user?.bio ?? '';
      _loading = false;
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_user == null) return;

    try {
      final updateData = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'streetAddress': _streetController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'zipcode': _zipController.text.trim(),
        'bio': _bioController.text.trim(),
      };

      await ApiService.updateUser(_user!.id!, updateData);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated')));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to update profile')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        appBar: _SimpleAppBar(title: 'Edit Profile'),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: const _SimpleAppBar(title: 'Edit Profile'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _firstNameController,
                      'First name',
                      TextInputType.name,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      _lastNameController,
                      'Last name',
                      TextInputType.name,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(
                _emailController,
                'Email',
                TextInputType.emailAddress,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                _phoneController,
                'Phone',
                TextInputType.phone,
                requiredField: false,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                _bioController,
                'Bio',
                TextInputType.multiline,
                requiredField: false,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                _streetController,
                'Street address',
                TextInputType.streetAddress,
                requiredField: false,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _cityController,
                      'City',
                      TextInputType.text,
                      requiredField: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      _stateController,
                      'State',
                      TextInputType.text,
                      requiredField: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      _zipController,
                      'ZIP',
                      TextInputType.number,
                      requiredField: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF87AE73),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    TextInputType type, {
    String? Function(String?)? validator,
    bool requiredField = true,
    int? maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator:
          validator ??
          (v) => requiredField && (v == null || v.trim().isEmpty)
              ? 'Required'
              : null,
    );
  }
}

class _SimpleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const _SimpleAppBar({required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: const Color(0xFF87AE73),
      foregroundColor: Colors.white,
    );
  }
}
