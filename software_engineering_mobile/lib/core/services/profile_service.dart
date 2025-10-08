import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user.dart';
import '../repositories/shared_prefs_user_repository.dart';
import 'auth_service.dart';
import 'money_service.dart';
import '../../features/profile/models/profile_state.dart';

/// Service class that handles all profile-related backend operations
/// Separates business logic from UI components
class ProfileService {
  final SharedPrefsUserRepository _repo = SharedPrefsUserRepository();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  /// Load user data and balance from storage
  Future<ProfileUserData> loadUserAndBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('activeUserId');
    
    if (userId == null || userId.isEmpty) {
      return ProfileUserData(
        user: null,
        hippoBalanceCents: 0,
        transactionCount: 0,
      );
    }

    // Get full user data
    final user = await _authService.getCurrentUser();
    final bal = await _repo.getHippoBalanceCents(userId);
    final txns = await _repo.getTransactionCount(userId);

    return ProfileUserData(
      user: user ?? User(
        id: userId,
        email: '',
        password: '',
        firstName: 'Profile',
        lastName: '',
        currency: 0.0,
        assets: const [],
        hippoBalanceCents: bal,
      ),
      hippoBalanceCents: bal,
      transactionCount: txns,
    );
  }

  /// Load user statistics (loans, earnings, etc.)
  Future<ProfileStatistics> loadUserStatistics() async {
    // Simulate loading user statistics
    // In a real app, this would fetch from a database
    await Future.delayed(const Duration(milliseconds: 500));
    
    return const ProfileStatistics(
      totalLoans: 12,
      activeLoans: 3,
      completedLoans: 9,
      totalEarnings: 1250.75,
    );
  }

  /// Load saved profile image from local storage
  Future<File?> loadSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString('profile_image_path');
    if (savedPath != null && File(savedPath).existsSync()) {
      return File(savedPath);
    }
    return null;
  }

  /// Pick a single image from gallery
  Future<File?> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        final path = pickedFile.path;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_path', path);
        return File(path);
      }
    } catch (e) {
      // Handle error silently
    }
    return null;
  }

  /// Pick multiple images from gallery
  Future<List<File>> pickMultipleImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      return pickedFiles.map((xfile) => File(xfile.path)).toList();
    } catch (e) {
      // Handle error silently
      return [];
    }
  }

  /// Deposit Hippo Bucks
  Future<int> depositHippoBucks(String userId, String amountText) async {
    final cents = MoneyService.parseToCents(amountText);
    await _repo.depositHippoCents(userId, cents);
    return await _repo.getHippoBalanceCents(userId);
  }

  /// Withdraw Hippo Bucks
  Future<int> withdrawHippoBucks(String userId, String amountText) async {
    final cents = MoneyService.parseToCents(amountText);
    await _repo.withdrawHippoCents(userId, cents);
    return await _repo.getHippoBalanceCents(userId);
  }

  /// Get formatted balance string
  String formatBalance(int balanceCents) {
    return MoneyService.formatCents(balanceCents);
  }

  /// Update user profile information
  Future<User?> updateUserProfile(User user, String firstName, String email) async {
    final updatedUser = user.copyWith(
      firstName: firstName,
      email: email,
    );
    await _repo.save(updatedUser);
    return updatedUser;
  }
}

/// Data class for user-related information
class ProfileUserData {
  final User? user;
  final int hippoBalanceCents;
  final int transactionCount;

  const ProfileUserData({
    required this.user,
    required this.hippoBalanceCents,
    required this.transactionCount,
  });
}

