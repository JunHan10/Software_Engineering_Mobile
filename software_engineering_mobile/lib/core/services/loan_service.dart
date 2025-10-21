// Networking delegated to ApiService
import '../models/loan.dart';
import 'api_service.dart';

/// LoanService - Handles all loan-related API calls
///
/// This service manages active loans between users for the borrowing system.
/// It provides methods to create, retrieve, update, and manage loan records.
/// LoanService - Handles loan-related API calls.
///
/// All network calls should use `ApiService` or its `baseUrl` so the
/// environment (emulator vs device) is honored. This service provides
/// convenience methods for creating and managing loans.
class LoanService {
  static String get baseUrl => ApiService.baseUrl + '/api';

  /// Create a new loan when a borrow request is approved
  static Future<Loan?> createLoan({
    required String itemId,
    required String itemName,
    required String itemDescription,
    required String itemImagePath,
    required String ownerId,
    required String ownerName,
    required String borrowerId,
    required String borrowerName,
    required double itemValue,
    DateTime? expectedReturnDate,
    String? notes,
  }) async {
    final loanData = {
      'itemId': itemId,
      'itemName': itemName,
      'itemDescription': itemDescription,
      'itemImagePath': itemImagePath,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'borrowerId': borrowerId,
      'borrowerName': borrowerName,
      'itemValue': itemValue,
      'expectedReturnDate': expectedReturnDate?.toIso8601String(),
      'notes': notes,
    };

    try {
      final resp = await ApiService.createLoan(loanData);
      return resp != null ? Loan.fromJson(resp) : null;
    } catch (e) {
      print('Error creating loan via ApiService: $e');
      return null;
    }
  }

  /// Get all loans for a specific user (as borrower)
  static Future<List<Loan>> getBorrowerLoans(String userId) async {
    try {
      final data = await ApiService.getUserLoans(userId);
      return data.map((json) => Loan.fromJson(json)).toList();
    } catch (e) {
      print('Error getting borrower loans via ApiService: $e');
      return [];
    }
  }

  /// Get all loans for a specific user (as owner)
  static Future<List<Loan>> getOwnerLoans(String userId) async {
    try {
      final data = await ApiService.getUserLoans(userId);
      return data.map((json) => Loan.fromJson(json)).toList();
    } catch (e) {
      print('Error getting owner loans via ApiService: $e');
      return [];
    }
  }

  /// Get all active loans for a user (both as borrower and owner)
  static Future<List<Loan>> getUserActiveLoans(String userId) async {
    try {
      final data = await ApiService.getUserLoans(userId);
      return data.map((json) => Loan.fromJson(json)).toList();
    } catch (e) {
      print('Error getting user loans via ApiService: $e');
      return [];
    }
  }

  /// Update loan status
  static Future<bool> updateLoanStatus({
    required String loanId,
    required LoanStatus status,
    String? notes,
  }) async {
    try {
      final statusStr = status.toString().split('.').last;
      return await ApiService.updateLoanStatus(loanId, statusStr, notes: notes);
    } catch (e) {
      print('Error updating loan status via ApiService: $e');
      return false;
    }
  }

  /// Mark loan as returned
  static Future<bool> markLoanAsReturned(String loanId) async {
    try {
      final success = await ApiService.returnLoan(loanId);
      if (!success) {
        print(
          'markLoanAsReturned: ApiService.returnLoan returned false for loanId=$loanId',
        );
      }
      return success;
    } catch (e, st) {
      print(
        'Error marking loan as returned via ApiService for loanId=$loanId: $e',
      );
      print(st);
      return false;
    }
  }

  /// End a loan term (alias for markLoanAsReturned).
  ///
  /// This will call the server endpoint that sets the loan's status to
  /// 'returned' and records an endDate. Returns true on success.
  static Future<bool> endLoanTerm(String loanId) async {
    return await markLoanAsReturned(loanId);
  }

  /// Get loan by ID
  static Future<Loan?> getLoanById(String loanId) async {
    try {
      final data = await ApiService.getLoanById(loanId);
      return data != null ? Loan.fromJson(data) : null;
    } catch (e) {
      print('Error getting loan by ID via ApiService: $e');
      return null;
    }
  }

  /// Check if a loan exists for a specific item and borrower
  static Future<Loan?> findExistingLoan({
    required String itemId,
    required String borrowerId,
  }) async {
    try {
      final body = await ApiService.findExistingLoan(itemId, borrowerId);
      return body != null ? Loan.fromJson(body) : null;
    } catch (e) {
      print('Error finding existing loan via ApiService: $e');
      return null;
    }
  }
}
