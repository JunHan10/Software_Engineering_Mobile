// Flutter Material Design imports for UI components
import 'package:flutter/material.dart';
// Import authentication service for user registration
import 'services/auth_service.dart';
// Import repository for data storage
import 'repositories/shared_prefs_user_repository.dart';
// Import User model for creating user objects
import 'models/user.dart';

/**
 * RegistrationPage - User account creation form
 * 
 * This is a StatefulWidget because it needs to manage:
 * - Form input state (text controllers)
 * - Loading state during registration
 * - Password visibility toggles
 * - Form validation state
 * 
 * Key Features:
 * - Comprehensive user data collection (personal info + address)
 * - Real-time form validation with user feedback
 * - Password confirmation with visibility toggles
 * - Loading state management during async operations
 * - Error handling with user-friendly messages
 * - Responsive layout with grouped fields
 */
class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage>{
  // Form key for validation - allows us to validate all fields at once
  final _formKey = GlobalKey<FormState>();
  
  // Loading state to show progress indicator during registration
  bool _isLoading = false;
  
  // Text controllers for form inputs - manage text field state
  // Each controller is tied to a specific input field
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _streetAddressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipcodeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Password visibility toggles for better UX
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  
  // Age selection - nullable because user might not select initially
  int? _selectedAge;

  /**
   * Dispose method - Clean up resources when widget is destroyed
   * 
   * CRITICAL: TextEditingControllers must be disposed to prevent memory leaks
   * Each controller creates listeners and holds references that need cleanup
   * 
   * This is called automatically when the widget is removed from the widget tree
   */
  @override
  void dispose() {
    // Dispose all text controllers to prevent memory leaks
    _firstNameController.dispose();
    _lastNameController.dispose();
    _streetAddressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipcodeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    // Always call super.dispose() last
    super.dispose();
  }

  /**
   * Handle user registration process
   * 
   * Registration Flow:
   * 1. Validate all form fields using Flutter's built-in validation
   * 2. Show loading indicator to provide user feedback
   * 3. Create User object from form data
   * 4. Call AuthService to register user (handles business logic)
   * 5. Show success/error message and navigate accordingly
   * 
   * Error Handling:
   * - Form validation prevents submission of invalid data
   * - Try-catch handles unexpected errors gracefully
   * - 'mounted' checks prevent setState calls on disposed widgets
   * - User-friendly error messages via SnackBar
   * 
   * UX Considerations:
   * - Loading state disables button and shows progress indicator
   * - Success navigates back to login screen
   * - Errors keep user on form to fix issues
   */
  Future<void> _handleRegistration() async{
    // Validate all form fields before proceeding
    if(_formKey.currentState!.validate()) {
      // Show loading state - disables button and shows progress indicator
      setState(() {
        _isLoading = true;
      });

      try {
        // Create User object from form data
        // .trim() removes leading/trailing whitespace from text inputs
        final newUser = User(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          age: _selectedAge, // Can be null if not selected
          streetAddress: _streetAddressController.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          zipcode: _zipcodeController.text.trim(),
          currency: 0.0, // New users start with no money
          assets: [], // New users start with no assets
        );

        // Create AuthService with repository dependency injection
        final authService = AuthService(SharedPrefsUserRepository());
        // Attempt to register user - returns boolean for success/failure
        final success = await authService.register(newUser);

        // Hide loading state
        setState(() {
          _isLoading = false;
        });

        // Handle registration result
        if (success && mounted) {
          // Success: Show confirmation and return to login
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful!'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate back to login screen
          Navigator.pop(context);
        } else if (mounted) {
          // Failure: Show error message (likely duplicate email)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email already exists or registration failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Handle unexpected errors (network, storage, etc.)
        setState(() {
          _isLoading = false;
        });
        
        // Show technical error message for debugging
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
    backgroundColor: Colors.grey[50],
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 60),
            
            // Header
            const Icon(
              Icons.person_add_outlined,
              size: 80,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Create Account',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 48),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  // First Name, Last Name, and Age Row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'First Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your first name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'Last Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your last name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _selectedAge,
                          decoration: const InputDecoration(
                            labelText: 'Age',
                            border: OutlineInputBorder(),
                          ),
                          menuMaxHeight: 200,
                          isExpanded: true,
                          items: List.generate(100, (index) => index + 13)
                              .map((age) => DropdownMenuItem(
                                    value: age,
                                    child: Text(age.toString()),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedAge = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select your age';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Street Address Field
                  TextFormField(
                    controller: _streetAddressController,
                    decoration: const InputDecoration(
                      labelText: 'Street Address',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your street address';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // City, State and Zipcode Row
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(
                            labelText: 'City',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your city';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _stateController,
                          decoration: const InputDecoration(
                            labelText: 'State',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your state';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _zipcodeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Zipcode',
                            border: OutlineInputBorder(),
                          ),
                          onFieldSubmitted: (value) {
                            _handleRegistration();
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your zipcode';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegistration,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Create Account',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sign In Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Sign In'),
                      ),
                    ],
                  ),

                ],
              ),
            ),

          ],
        ),
      ),
    ),
    );
  }
}