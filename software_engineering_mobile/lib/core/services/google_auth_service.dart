import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // Check if user exists in database
      final existingUser = await ApiService.getUserByEmail(googleUser.email);
      
      if (existingUser != null) {
        // User exists, log them in
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('activeUserId', existingUser['_id']);
        return User.fromJson(existingUser);
      } else {
        // Create new user
        final userData = {
          'email': googleUser.email,
          'firstName': googleUser.displayName?.split(' ').first ?? '',
          'lastName': googleUser.displayName?.split(' ').skip(1).join(' ') ?? '',
          'password': 'google_auth_${DateTime.now().millisecondsSinceEpoch}',
          'phone': '',
        };
        
        final newUser = await ApiService.createUser(userData);
        if (newUser != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('activeUserId', newUser['_id']);
          return User.fromJson(newUser);
        }
      }
      return null;
    } catch (e) {
      print('Google sign-in error: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('activeUserId');
  }
}