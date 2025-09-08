import '../models/user.dart';
import '../repositories/user_repository.dart';

class AuthService {
  final UserRepository _userRepository;
  static User? _currentUser;
  
  AuthService(this._userRepository);
  
  static User? get currentUser => _currentUser;

  Future<bool> login(String email, String password) async {
    try {
      final user = await _userRepository.findByEmailAndPassword(email, password);
      
      if (user != null) {
        _currentUser = user;
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
  }

  Future<User?> getUserByEmail(String email) async {
    return await _userRepository.findByEmail(email);
  }

  Future<bool> register(User user) async {
    try {
      // Check if email already exists
      final existingUser = await _userRepository.findByEmail(user.email);
      if (existingUser != null) {
        return false; // Email already exists
      }
      
      // Save new user
      await _userRepository.save(user);
      return true;
    } catch (e) {
      return false;
    }
  }
}