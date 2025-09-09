// Flutter Material Design imports for UI components
import 'package:flutter/material.dart';
// Import specific loan-related pages for navigation
import 'package:software_engineering_mobile/Active_Loans.dart';
import 'login_screen.dart';
import 'Loaned_Items.dart';
// Import repository for debugging user data operations
import 'repositories/shared_prefs_user_repository.dart';

/**
 * DashboardPage - Main landing page after successful user authentication
 * 
 * This is a StatelessWidget because the dashboard doesn't need to maintain
 * any internal state - it's purely a navigation hub with static content.
 * 
 * Key Features:
 * - Clean AppBar with currency display and logout functionality
 * - Two main navigation buttons for core app features
 * - Debug buttons for development and testing (should be removed in production)
 * - Consistent theming with deep purple color scheme
 */
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar provides top navigation and branding
      appBar: AppBar(
        title: const Text('Dashboard'),
        // Deep purple theme maintains consistency across the app
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          // Currency display - shows the app's base currency (USD)
          // Positioned in AppBar for constant visibility across the dashboard
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: const Text(
              'Currency Here', // Static currency display - could be dynamic in future
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ),
          // Logout button - uses pushReplacement to prevent back navigation
          // This ensures users can't accidentally return to dashboard after logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // pushReplacement removes current route from navigation stack
              // This prevents users from using back button to return to dashboard
              Navigator.pushReplacement( 
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
      )]
      ),
      // SafeArea ensures content doesn't overlap with system UI (status bar, notch, etc.)
      body: SafeArea(
        child: Padding(
          // 16px padding provides comfortable spacing from screen edges
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Top spacing to create visual breathing room
              const SizedBox(height: 40),
              
              // Main Navigation Section
              // Uses Row layout to place buttons side-by-side for better UX
              Row(
                children: [
                  // First navigation button - Loaned Items
                  // Expanded ensures both buttons take equal width
                  Expanded(
                    child: SizedBox(
                      height: 60, // Fixed height for consistent button sizing
                      child: ElevatedButton(
                        onPressed: () {
                          // Standard navigation push - allows back navigation
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const Loaned_Items()),
                          );
                        },
                        // Consistent styling with app theme
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          // Rounded corners for modern UI appearance
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'View Loaned Items',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  // Spacing between buttons for visual separation
                  const SizedBox(width: 16),
                  // Second navigation button - Active Loans
                  Expanded(
                    child: SizedBox(
                      height: 60, // Matching height for visual consistency
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ActiveLoans()),
                          );
                        },
                        // Identical styling to first button for consistency
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'View Active Loans',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              // Spacing between main navigation and debug section
              const SizedBox(height: 40),
              
              // Debug Section - FOR DEVELOPMENT ONLY
              // These buttons should be removed or hidden in production builds
              
              // Debug Button 1: View All Users
              // Orange color indicates this is a debug/development feature
              ElevatedButton(
                onPressed: () async {
                  // Create repository instance to access user data
                  final repo = SharedPrefsUserRepository();
                  // Print all stored users to console for debugging
                  // This helps developers verify user registration and data storage
                  await repo.printAllUsers();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Orange = debug/warning
                  foregroundColor: Colors.white,
                ),
                child: const Text('Debug: View All Users'),
              ),
              const SizedBox(height: 10),
              
              // Debug Button 2: Clear All Data
              // Red color indicates destructive action
              ElevatedButton(
                onPressed: () async {
                  final repo = SharedPrefsUserRepository();
                  // Clear all stored user data from SharedPreferences
                  // This resets the app to initial state with only test data
                  await repo.clearAllData();
                  // Show user feedback via SnackBar
                  // SnackBar appears at bottom of screen temporarily
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All data cleared! App will reload original test data.'),
                      backgroundColor: Colors.red, // Red indicates destructive action
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Red = destructive action
                  foregroundColor: Colors.white,
                ),
                child: const Text('Clear All Data'),
              ),

            ],
          ),
        ),
      ),
    );
  }
}