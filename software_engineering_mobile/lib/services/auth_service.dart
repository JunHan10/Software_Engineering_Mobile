// Import the User model for type definitions
import '../models/user.dart';
// Import the abstract repository interface for dependency injection
import '../repositories/user_repository.dart';

/**
 * AuthService - Handles all authentication-related business logic
 * 
 * This service acts as the business logic layer between the UI and data storage.
 * It implements the authentication workflow while remaining agnostic about
 * the actual storage mechanism (JSON, SharedPreferences, Database, etc.)
 * 
 * Key Design Patterns:
 * - Dependency Injection: Takes UserRepository interface, not concrete implementation
 * - Singleton Pattern: Static _currentUser maintains session state
 * - Service Layer: Encapsulates business logic away from UI components
 * - Error Handling: Graceful failure with boolean returns instead of exceptions
 * 
 * Benefits:
 * - Easy to test (can inject mock repositories)
 * - Easy to switch storage systems (just change repository implementation)
 * - Centralized authentication logic
 * - Consistent error handling
 */
class AuthService {
  // Private repository instance - injected via constructor
  // This allows us to swap different storage implementations without changing this code
  final UserRepository _userRepository;
  
  // Static current user maintains session state across the app
  // Static because we want one global authentication state
  // Nullable because user might not be logged in
  static User? _currentUser;
  
  /**
   * Constructor uses dependency injection pattern
   * This allows us to pass different repository implementations:
   * - SharedPrefsUserRepository for local storage
   * - DatabaseUserRepository for database storage
   * - MockUserRepository for testing
   */
  AuthService(this._userRepository);
  
  /**
   * Getter for current authenticated user
   * Static so it can be accessed from anywhere in the app
   * Returns null if no user is logged in
   */
  static User? get currentUser => _currentUser;

  // Allows updating the in-memory current user after profile/data changes
  static void loginStateUpdate(User user) {
    _currentUser = user;
  }

  /**
   * Login method - authenticates user with email and password
   * 
   * Process:
   * 1. Query repository for user with matching email and password
   * 2. If found, set as current user and return success
   * 3. If not found or error occurs, return failure
   * 
   * Returns boolean instead of throwing exceptions for simpler UI handling
   * UI can show generic "invalid credentials" message on false return
   */
  Future<bool> login(String email, String password) async {
    try {
      // Delegate actual data lookup to repository layer
      final user = await _userRepository.findByEmailAndPassword(email, password);
      
      if (user != null) {
        // Set global authentication state
        _currentUser = user;
        return true; // Success
      }
      
      return false; // User not found or password incorrect
    } catch (e) {
      // Catch any repository errors (network, storage, etc.)
      // Return false for consistent error handling
      return false;
    }
  }

  /**
   * Logout method - clears current user session
   * 
   * Simple method that resets the global authentication state
   * Could be extended to:
   * - Clear stored tokens
   * - Send logout request to server
   * - Clear cached data
   */
  Future<void> logout() async {
    _currentUser = null;
  }

  /**
   * Utility method to find user by email
   * 
   * Useful for:
   * - Checking if email exists during registration
   * - User lookup functionality
   * - Password reset flows (future feature)
   */
  Future<User?> getUserByEmail(String email) async {
    return await _userRepository.findByEmail(email);
  }

  /**
   * Registration method - creates new user account
   * 
   * Process:
   * 1. Check if email already exists (prevent duplicates)
   * 2. If email is unique, save new user to storage
   * 3. Return success/failure status
   * 
   * Business Rules:
   * - Email must be unique across all users
   * - User data validation should happen in UI layer
   * - New users start with generated ID (handled by repository)
   * 
   * Returns boolean for consistent error handling pattern
   */
  Future<bool> register(User user) async {
    try {
      // Business rule: Check for duplicate email addresses
      final existingUser = await _userRepository.findByEmail(user.email);
      if (existingUser != null) {
        return false; // Email already exists - registration failed
      }
      
      // Save new user to storage via repository
      // Repository handles ID generation and actual storage
      await _userRepository.save(user);
      return true; // Registration successful
    } catch (e) {
      // Handle any storage errors gracefully
      return false; // Registration failed due to technical error
    }
  }
}