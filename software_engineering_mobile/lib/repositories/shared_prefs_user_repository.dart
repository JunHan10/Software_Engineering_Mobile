// Dart core library for JSON encoding/decoding
import 'dart:convert';
// Flutter services for reading asset files
import 'package:flutter/services.dart';
// SharedPreferences for local key-value storage
import 'package:shared_preferences/shared_preferences.dart';
// Import User model and repository interface
import '../models/user.dart';
import 'user_repository.dart';

/// SharedPrefsUserRepository - Concrete implementation of UserRepository using SharedPreferences
/// 
/// This class implements the Repository pattern for user data storage using Flutter's
/// SharedPreferences, which provides persistent key-value storage on the device.
/// 
/// Why SharedPreferences?
/// - Simple key-value storage perfect for user data
/// - Persistent across app restarts
/// - Cross-platform (iOS, Android, Web, Desktop)
/// - No external dependencies or setup required
/// - Good performance for small to medium datasets
/// 
/// Architecture Benefits:
/// - Implements UserRepository interface (can be swapped with database implementation)
/// - Caches data in memory for performance
/// - Initializes from assets/test_data.json on first run
/// - Handles JSON serialization/deserialization automatically
/// 
/// Storage Strategy:
/// - All users stored as single JSON string under 'users_data' key
/// - Data structure: {"users": [{user1}, {user2}, ...]}
/// - In-memory caching prevents repeated SharedPreferences reads
/// - Lazy loading - data only loaded when first accessed
class SharedPrefsUserRepository implements UserRepository {
  // Key used to store user data in SharedPreferences
  // Static const ensures consistency across all instances
  static const String _usersKey = 'users_data';
  
  // In-memory cache of user data for performance
  // Nullable - null means data hasn't been loaded yet
  // Once loaded, prevents repeated SharedPreferences reads
  List<User>? _cachedUsers;

  /// Find user by email address
  /// 
  /// Used for:
  /// - Checking if email exists during registration
  /// - User lookup functionality
  /// - Password reset flows (future)
  /// 
  /// Email Comparison:
  /// - Case-insensitive: converts both stored and input emails to lowercase
  /// - This allows users to login with any case variation of their email
  /// 
  /// Returns null if user not found (rather than throwing exception)
  /// This makes error handling simpler in the service layer
  @override
  Future<User?> findByEmail(String email) async {
    final users = await _loadUsers();
    try {
      // Convert input email to lowercase for case-insensitive comparison
      final emailLower = email.toLowerCase();
      // firstWhere throws StateError if no match found
      return users.firstWhere((user) => user.email.toLowerCase() == emailLower);
    } catch (e) {
      // Convert exception to null for consistent error handling
      return null;
    }
  }

  /// Find user by email and password combination
  /// 
  /// Primary method for user authentication
  /// Checks both email and password in single query for efficiency
  /// 
  /// Email Comparison:
  /// - Case-insensitive: converts both stored and input emails to lowercase
  /// - Password remains case-sensitive for security
  /// 
  /// Security Note: In production, passwords should be hashed
  /// and this would compare hashed values
  @override
  Future<User?> findByEmailAndPassword(String email, String password) async {
    final users = await _loadUsers();
    try {
      // Convert input email to lowercase for case-insensitive comparison
      final emailLower = email.toLowerCase();
      return users.firstWhere(
        (user) => user.email.toLowerCase() == emailLower && user.password == password,
      );
    } catch (e) {
      // Return null if no matching user found
      return null;
    }
  }

  /// Save user to storage (create or update)
  /// 
  /// Handles both new user creation and existing user updates:
  /// - New users (id == null): Generate timestamp-based ID
  /// - Existing users (id != null): Update existing record
  /// 
  /// ID Generation Strategy:
  /// - Uses current timestamp in milliseconds
  /// - Provides unique IDs without requiring external ID service
  /// - Simple and sufficient for local storage
  /// 
  /// Update Strategy:
  /// - Find existing user by ID
  /// - Replace if found, add if not found
  /// - Update both persistent storage and memory cache
  @override
  Future<User> save(User user) async {
    final users = await _loadUsers();
    
    // Generate ID for new users using timestamp
    // This ensures unique IDs without requiring a separate ID service
    final newUser = user.id == null 
        ? User(
            // Timestamp-based ID generation
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            email: user.email,
            password: user.password,
            firstName: user.firstName,
            lastName: user.lastName,
            age: user.age,
            phone: user.phone,
            streetAddress: user.streetAddress,
            city: user.city,
            state: user.state,
            zipcode: user.zipcode,
            currency: user.currency,
            assets: user.assets,
          )
        : user; // Use existing user if ID already exists
    
    // Update or insert logic
    final existingIndex = users.indexWhere((u) => u.id == newUser.id);
    if (existingIndex >= 0) {
      // Update existing user
      users[existingIndex] = newUser;
    } else {
      // Add new user
      users.add(newUser);
    }
    
    // Persist to storage and update cache
    await _saveUsers(users);
    _cachedUsers = users; // Update memory cache
    
    return newUser;
  }

  /// Delete user by ID
  /// 
  /// Removes user from both persistent storage and memory cache
  /// Uses removeWhere for safe deletion (no error if ID not found)
  @override
  Future<void> delete(String id) async {
    final users = await _loadUsers();
    // removeWhere is safe - won't error if ID doesn't exist
    users.removeWhere((user) => user.id == id);
    // Update both storage and cache
    await _saveUsers(users);
    _cachedUsers = users;
  }

  /// Load users from storage with caching
  /// 
  /// Loading Strategy:
  /// 1. Return cached data if available (performance optimization)
  /// 2. Try to load from SharedPreferences
  /// 3. If no data exists, initialize from assets/test_data.json
  /// 4. Cache the loaded data for future requests
  /// 
  /// This lazy loading approach means data is only loaded when first needed,
  /// and subsequent requests use the cached version for better performance.
  Future<List<User>> _loadUsers() async {
    // Return cached data if available (performance optimization)
    if (_cachedUsers != null) return _cachedUsers!;

    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    
    if (usersJson != null) {
      // Data exists in SharedPreferences - deserialize it
      final jsonData = json.decode(usersJson);
      _cachedUsers = (jsonData['users'] as List)
          .map((userJson) => User.fromJson(userJson))
          .toList();
    } else {
      // No data in SharedPreferences - initialize from test data
      await _initializeFromAssets();
    }
    
    // Return cached data or empty list if initialization failed
    return _cachedUsers ?? [];
  }

  /// Save users list to SharedPreferences
  /// 
  /// Serialization Process:
  /// 1. Convert List<User> to List<Map<String, dynamic>> using toJson()
  /// 2. Wrap in object structure: {"users": [...]}
  /// 3. Encode to JSON string
  /// 4. Store in SharedPreferences
  /// 
  /// This maintains the same JSON structure as assets/test_data.json
  /// for consistency and easier debugging.
  Future<void> _saveUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    // Create JSON structure matching assets/test_data.json format
    final jsonData = {
      'users': users.map((user) => user.toJson()).toList(),
    };
    // Encode to JSON string and store
    await prefs.setString(_usersKey, json.encode(jsonData));
  }

  /// Initialize user data from assets/test_data.json
  /// 
  /// This method runs on first app launch when no user data exists
  /// in SharedPreferences. It:
  /// 1. Loads test_data.json from app assets
  /// 2. Parses JSON and creates User objects
  /// 3. Saves to SharedPreferences for future use
  /// 4. Caches in memory
  /// 
  /// This provides a seamless transition from static test data
  /// to dynamic user-generated data.
  Future<void> _initializeFromAssets() async {
    try {
      // Load JSON file from app assets (bundled with app)
      final jsonString = await rootBundle.loadString('assets/test_data.json');
      final jsonData = json.decode(jsonString);
      
      // Parse JSON into User objects
      _cachedUsers = (jsonData['users'] as List)
          .map((userJson) => User.fromJson(userJson))
          .toList();
      
      // Save to SharedPreferences so future app launches use this data
      await _saveUsers(_cachedUsers!);
    } catch (e) {
      // If asset loading fails, start with empty user list
      // This prevents app crashes if test_data.json is missing or malformed
      _cachedUsers = [];
    }
  }

  /// DEBUG METHOD: Print all stored users to console
  /// 
  /// Development utility for:
  /// - Verifying user registration worked correctly
  /// - Checking data integrity after operations
  /// - Debugging authentication issues
  /// - Viewing complete user profiles including assets
  /// 
  /// Should be removed or disabled in production builds
  /// for security (exposes passwords and personal data)
  Future<void> printAllUsers() async {
    final users = await _loadUsers();
    print('=== ALL STORED USERS ===');
    for (int i = 0; i < users.length; i++) {
      final user = users[i];
      print('User ${i + 1}:');
      print('  ID: ${user.id}');
      print('  Email: ${user.email}');
      print('  Password: ${user.password}'); // WARNING: Exposes passwords!
      print('  Name: ${user.firstName} ${user.lastName}');
      print('  Age: ${user.age ?? "Not provided"}');
      print('  Address: ${user.streetAddress ?? ""}, ${user.city ?? ""}, ${user.state ?? ""} ${user.zipcode ?? ""}');
      print('  Currency: \$${user.currency}');
      print('  Assets: ${user.assets.length} items');
      // List all user assets with values
      for (var asset in user.assets) {
        print('    - ${asset.name}: \$${asset.value}');
      }
      print('---');
    }
    print('=== END OF USERS ===');
  }

  /// DEBUG METHOD: Clear all stored user data
  /// 
  /// Development utility for:
  /// - Resetting app to initial state during testing
  /// - Clearing test data between development sessions
  /// - Debugging data persistence issues
  /// 
  /// WARNING: This is destructive and cannot be undone!
  /// Should be removed or protected in production builds
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    // Remove the users data key from SharedPreferences
    await prefs.remove(_usersKey);
    // Clear memory cache so next load will reinitialize from assets
    _cachedUsers = null;
    print('All SharedPreferences data cleared!');
  }
}