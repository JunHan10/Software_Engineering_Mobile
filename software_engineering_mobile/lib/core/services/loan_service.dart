import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/loan.dart';

/// LoanService - Handles all loan-related API calls
/// 
/// This service manages active loans between users for the borrowing system.
/// It provides methods to create, retrieve, update, and manage loan records.
class LoanService {
  static const String baseUrl = 'http://192.168.1.144:3000/api';

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
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/loans'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
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
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Loan.fromJson(data);
      }
      print('Failed to create loan: ${response.statusCode} ${response.body}');
      return null;
    } catch (e) {
      print('Error creating loan: $e');
      return null;
    }
  }

  /// Get all loans for a specific user (as borrower)
  static Future<List<Loan>> getBorrowerLoans(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/loans/borrower/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((json) => Loan.fromJson(json)).toList();
      }
      print('Failed to get borrower loans: ${response.statusCode} ${response.body}');
      return [];
    } catch (e) {
      print('Error getting borrower loans: $e');
      return [];
    }
  }

  /// Get all loans for a specific user (as owner)
  static Future<List<Loan>> getOwnerLoans(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/loans/owner/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((json) => Loan.fromJson(json)).toList();
      }
      print('Failed to get owner loans: ${response.statusCode} ${response.body}');
      return [];
    } catch (e) {
      print('Error getting owner loans: $e');
      return [];
    }
  }

  /// Get all active loans for a user (both as borrower and owner)
  static Future<List<Loan>> getUserActiveLoans(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/loans/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((json) => Loan.fromJson(json)).toList();
      }
      print('Failed to get user loans: ${response.statusCode} ${response.body}');
      return [];
    } catch (e) {
      print('Error getting user loans: $e');
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
      final response = await http.put(
        Uri.parse('$baseUrl/loans/$loanId/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'status': status.toString().split('.').last,
          'notes': notes,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating loan status: $e');
      return false;
    }
  }

  /// Mark loan as returned
  static Future<bool> markLoanAsReturned(String loanId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/loans/$loanId/return'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error marking loan as returned: $e');
      return false;
    }
  }

  /// Get loan by ID
  static Future<Loan?> getLoanById(String loanId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/loans/$loanId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Loan.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting loan by ID: $e');
      return null;
    }
  }

  /// Check if a loan exists for a specific item and borrower
  static Future<Loan?> findExistingLoan({
    required String itemId,
    required String borrowerId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/loans/find?itemId=$itemId&borrowerId=$borrowerId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data != null ? Loan.fromJson(data) : null;
      }
      return null;
    } catch (e) {
      print('Error finding existing loan: $e');
      return null;
    }
  }
}
