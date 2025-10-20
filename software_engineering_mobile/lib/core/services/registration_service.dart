import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class RegistrationService {
  static const String baseUrl = 'http://192.168.50.158:3000/api';

  static Future<User?> register(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data);
        
        // Save user ID to local storage for session management
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('activeUserId', user.id!);
        
        return user;
      } else {
        return null;
      }
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }
}