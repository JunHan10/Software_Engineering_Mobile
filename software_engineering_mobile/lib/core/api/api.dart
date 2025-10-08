// lib/core/api/api.dart
//
// API configuration and endpoints for the application

class ApiConfig {
  // Base URL for your API server
  static const String baseUrl = 'https://api.example.com';
  
  // API endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String userEndpoint = '/users';
  static const String profileEndpoint = '/profile';
  
  // Legacy endpoint getters for backward compatibility
  static String get login => buildUrl(loginEndpoint);
  static String get register => buildUrl(registerEndpoint);
  
  // API headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Helper method to build full URL
  static String buildUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}