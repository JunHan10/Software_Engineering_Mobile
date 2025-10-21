/// High-level server-backed services used by UI components.
///
/// These services provide application-specific helpers that combine local
/// session data with calls to the API (via `ApiService`). Some services are
/// placeholders to allow the UI to function while the server-backed
/// implementation is added later.
import '../models/user.dart';
import '../models/loan.dart';
import 'api_service.dart';
import 'loan_service.dart';
import 'session_service.dart';

/// Placeholder vote service used by UI code. Implement server-backed vote
/// handling here when ready. Currently returns default values to keep UI
/// functional during development.
class ServerVoteService {
  Future<int> getScore(String itemId) async {
    // TODO: Implement server-backed logic to fetch score
    return 0;
  }

  Future<int> getUserVote(String itemId, String userId) async {
    // TODO: Implement server-backed logic to fetch user's vote
    return 0;
  }

  Future<int> setVote({
    required String itemId,
    required String userId,
    required int vote,
  }) async {
    // TODO: Implement server-backed logic to set a vote
    return 0;
  }
}

/// Placeholder favorite service. Implement server integration as needed. The
/// service keeps method signatures used by UI while returning default values.
class ServerFavoriteService {
  Future<bool> isFavorited(String itemId, String userId) async {
    // TODO: Implement real server check
    return false;
  }

  Future<void> toggleFavorite({
    required String itemId,
    required String userId,
  }) async {
    // TODO: Implement server toggle favorite
  }

  Future<List<String>> getUserFavorites(String userId) async {
    // TODO: Fetch user's favorites from server
    return [];
  }
}

class ServerProfileService {
  /// Load user data and balance from the database
  Future<Map<String, dynamic>> loadUserAndBalance() async {
    try {
      final user = await SessionService.getCurrentUser();
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Get user's balance from the API
      final balance = await ApiService.getBalance(user.id!);

      return {
        'user': user,
        'hippoBalanceCents': balance,
        'transactionCount': user.transactionCount,
      };
    } catch (e) {
      print('Error loading user and balance: $e');
      rethrow;
    }
  }

  /// Load user statistics from the database
  Future<Map<String, dynamic>> loadUserStatistics() async {
    try {
      final user = await SessionService.getCurrentUser();
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Fetch typed Loan objects for the user (both borrower and owner)
      final loans = await LoanService.getUserActiveLoans(user.id!);

      final totalLoans = loans.length;
      final activeLoans = loans
          .where((l) => l.status == LoanStatus.active)
          .length;
      final completedLoans = loans
          .where(
            (l) =>
                l.status == LoanStatus.completed ||
                l.status == LoanStatus.returned,
          )
          .length;

      // Sum earnings for completed/returned loans where the user is the owner
      double totalEarnings = loans
          .where(
            (l) =>
                (l.status == LoanStatus.completed ||
                    l.status == LoanStatus.returned) &&
                l.ownerId == user.id,
          )
          .fold(0.0, (acc, l) => acc + l.itemValue);

      return {
        'totalLoans': totalLoans,
        'activeLoans': activeLoans,
        'completedLoans': completedLoans,
        'totalEarnings': totalEarnings,
      };
    } catch (e) {
      print('Error loading user statistics: $e');
      rethrow;
    }
  }

  /// Load saved profile image (placeholder implementation)
  Future<dynamic> loadSavedImage() async {
    // For now, return null - you can implement image loading later
    return null;
  }

  /// Pick image from gallery/camera (placeholder implementation)
  Future<dynamic> pickImage() async {
    // For now, return null - you can implement image picking later
    return null;
  }

  /// Pick multiple images (placeholder implementation)
  Future<List<dynamic>> pickMultipleImages() async {
    return [];
  }

  /// Deposit Hippo Bucks
  Future<int> depositHippoBucks(String userId, String amount) async {
    try {
      final amountCents = (double.parse(amount) * 100).round();
      final success = await ApiService.depositMoney(userId, amountCents);
      if (success) {
        return await ApiService.getBalance(userId);
      }
      throw Exception('Failed to deposit money');
    } catch (e) {
      print('Error depositing money: $e');
      rethrow;
    }
  }

  /// Withdraw Hippo Bucks
  Future<int> withdrawHippoBucks(String userId, String amount) async {
    try {
      final amountCents = (double.parse(amount) * 100).round();
      final success = await ApiService.withdrawMoney(userId, amountCents);
      if (success) {
        return await ApiService.getBalance(userId);
      }
      throw Exception('Failed to withdraw money');
    } catch (e) {
      print('Error withdrawing money: $e');
      rethrow;
    }
  }

  /// Update user profile information
  Future<User?> updateUserProfile(
    User user,
    String firstName,
    String email,
  ) async {
    try {
      final updatedData = {'firstName': firstName, 'email': email};

      final result = await ApiService.updateUser(user.id!, updatedData);
      if (result != null) {
        return User.fromJson(result);
      }
      return null;
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  String formatBalance(int cents) {
    return '\$${(cents / 100).toStringAsFixed(2)}';
  }
}
