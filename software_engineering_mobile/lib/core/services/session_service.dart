import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class SessionService {
  static const String baseUrl = 'http://localhost:3000/api';

  static Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('activeUserId');
  }

  static Future<User?> getCurrentUser() async {
    final userId = await getCurrentUserId();
    if (userId == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/id/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}