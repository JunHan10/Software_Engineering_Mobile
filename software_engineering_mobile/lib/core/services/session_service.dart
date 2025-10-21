import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'server_auth_service.dart';

class SessionService {
  static Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('activeUserId');
  }

  static Future<User?> getCurrentUser() async {
    final userId = await getCurrentUserId();
    if (userId == null) return null;

    try {
      return await ServerAuthService.getCurrentUser();
    } catch (e) {
      return null;
    }
  }
}
