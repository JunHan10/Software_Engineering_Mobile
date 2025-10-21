/// Central API client used across the app.
///
/// This file defines `ApiService` which centralizes the app's HTTP calls.
/// It uses `AppConfig.baseUrl` from `config.dart` so the app can switch
/// between emulator and physical device environments without changing
/// multiple files.
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../utils/network_utils.dart';
import '../models/connection_result.dart';

class ApiService {
  static String get baseUrl => AppConfig.baseUrl;

  /// Tests connection to the server and internet
  static Future<ConnectionResult> testConnection() async {
    return NetworkUtils.testConnection();
  }

  // Internal helper to perform HTTP requests with timeout and consistent error messages
  static Future<http.Response> _request(
    Future<http.Response> Function() fn,
  ) async {
    // First ensure network + server reachable
    final result = await testConnection();
    if (!result.success) {
      throw Exception('Connection error: ${result.message}');
    }

    try {
      final response = await fn().timeout(const Duration(seconds: 8));
      return response;
    } on SocketException {
      throw Exception('Network socket error');
    } on TimeoutException {
      throw Exception('Request timed out');
    } catch (e) {
      throw Exception('Request failed: $e');
    }
  }

  static Future<List<dynamic>> getUsers() async {
    final response = await _request(
      () => http.get(Uri.parse('$baseUrl/api/users')),
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : [];
  }

  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final response = await _request(
      () => http.get(Uri.parse('$baseUrl/api/users/$email')),
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }

  static Future<Map<String, dynamic>?> getUserById(String id) async {
    final response = await _request(
      () => http.get(Uri.parse('$baseUrl/api/users/id/$id')),
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }

  static Future<List<dynamic>> getAssets() async {
    final response = await _request(
      () => http.get(Uri.parse('$baseUrl/api/assets')),
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : [];
  }

  static Future<List<dynamic>> getAssetsByOwner(String ownerId) async {
    final response = await _request(
      () => http.get(Uri.parse('$baseUrl/api/assets/owner/$ownerId')),
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : [];
  }

  static Future<List<dynamic>> getVotes(String itemId) async {
    final response = await _request(
      () => http.get(Uri.parse('$baseUrl/api/votes/$itemId')),
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : [];
  }

  static Future<bool> createVote(Map<String, dynamic> voteData) async {
    final response = await _request(
      () => http.post(
        Uri.parse('$baseUrl/api/votes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(voteData),
      ),
    );
    return response.statusCode == 201;
  }

  static Future<List<dynamic>> getNotifications(String userId) async {
    final response = await _request(
      () => http.get(Uri.parse('$baseUrl/api/notifications/$userId')),
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : [];
  }

  static Future<List<dynamic>> getFavorites(String userId) async {
    final response = await _request(
      () => http.get(Uri.parse('$baseUrl/api/favorites/$userId')),
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : [];
  }

  static Future<bool> createFavorite(Map<String, dynamic> favoriteData) async {
    final response = await _request(
      () => http.post(
        Uri.parse('$baseUrl/api/favorites'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(favoriteData),
      ),
    );
    return response.statusCode == 201;
  }

  static Future<bool> createNotification(
    Map<String, dynamic> notificationData,
  ) async {
    final response = await _request(
      () => http.post(
        Uri.parse('$baseUrl/api/notifications'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(notificationData),
      ),
    );
    return response.statusCode == 201;
  }

  static Future<Map<String, dynamic>?> createUser(
    Map<String, dynamic> userData,
  ) async {
    final response = await _request(
      () => http.post(
        Uri.parse('$baseUrl/api/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      ),
    );
    return response.statusCode == 201 ? jsonDecode(response.body) : null;
  }

  static Future<Map<String, dynamic>?> updateUser(
    String id,
    Map<String, dynamic> userData,
  ) async {
    final response = await _request(
      () => http.put(
        Uri.parse('$baseUrl/api/users/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      ),
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }

  static Future<Map<String, dynamic>?> login(
    String email,
    String password,
  ) async {
    final response = await _request(
      () => http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ),
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }

  static Future<Map<String, dynamic>?> createAsset(
    Map<String, dynamic> assetData,
  ) async {
    final response = await _request(
      () => http.post(
        Uri.parse('$baseUrl/api/assets'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(assetData),
      ),
    );
    return response.statusCode == 201 ? jsonDecode(response.body) : null;
  }

  static Future<bool> updateAsset(
    String id,
    Map<String, dynamic> assetData,
  ) async {
    final response = await _request(
      () => http.put(
        Uri.parse('$baseUrl/api/assets/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(assetData),
      ),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteAsset(String id) async {
    final response = await _request(
      () => http.delete(Uri.parse('$baseUrl/api/assets/$id')),
    );
    return response.statusCode == 204;
  }

  static Future<bool> depositMoney(String userId, int amount) async {
    final response = await _request(
      () => http.post(
        Uri.parse('$baseUrl/api/users/$userId/deposit'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': amount}),
      ),
    );
    return response.statusCode == 200;
  }

  static Future<bool> withdrawMoney(String userId, int amount) async {
    final response = await _request(
      () => http.post(
        Uri.parse('$baseUrl/api/users/$userId/withdraw'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': amount}),
      ),
    );
    return response.statusCode == 200;
  }

  static Future<int> getBalance(String userId) async {
    final response = await _request(
      () => http.get(Uri.parse('$baseUrl/api/users/$userId/balance')),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['balance'];
    }
    return 0;
  }

  static Future<bool> removeFavorite(String userId, String assetId) async {
    final response = await _request(
      () => http.delete(Uri.parse('$baseUrl/api/favorites/$userId/$assetId')),
    );
    return response.statusCode == 204;
  }

  static Future<List<dynamic>> getTransactions(String userId) async {
    final response = await _request(
      () => http.get(Uri.parse('$baseUrl/api/transactions/$userId')),
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : [];
  }

  static Future<bool> createTransaction(
    Map<String, dynamic> transactionData,
  ) async {
    final response = await _request(
      () => http.post(
        Uri.parse('$baseUrl/api/transactions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(transactionData),
      ),
    );
    return response.statusCode == 201;
  }

  static Future<bool> updateTransaction(
    String id,
    Map<String, dynamic> transactionData,
  ) async {
    final response = await _request(
      () => http.put(
        Uri.parse('$baseUrl/api/transactions/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(transactionData),
      ),
    );
    return response.statusCode == 200;
  }

  // -------------------- Loans --------------------

  static Future<List<dynamic>> getUserLoans(String userId) async {
    final response = await _request(
      () => http.get(Uri.parse('$baseUrl/api/loans/user/$userId')),
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : [];
  }

  static Future<Map<String, dynamic>?> getLoanById(String loanId) async {
    final response = await _request(
      () => http.get(Uri.parse('$baseUrl/api/loans/$loanId')),
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }

  static Future<Map<String, dynamic>?> createLoan(
    Map<String, dynamic> loanData,
  ) async {
    final response = await _request(
      () => http.post(
        Uri.parse('$baseUrl/api/loans'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(loanData),
      ),
    );
    return response.statusCode == 201 ? jsonDecode(response.body) : null;
  }

  static Future<bool> updateLoanStatus(
    String loanId,
    String status, {
    String? notes,
  }) async {
    final response = await _request(
      () => http.put(
        Uri.parse('$baseUrl/api/loans/$loanId/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status, 'notes': notes}),
      ),
    );
    return response.statusCode == 200;
  }

  static Future<bool> returnLoan(String loanId) async {
    final response = await _request(
      () => http.put(
        Uri.parse('$baseUrl/api/loans/$loanId/return'),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    if (response.statusCode != 200) {
      // Provide better diagnostics for failing real-user scenarios
      try {
        final body = response.body;
        print('returnLoan failed: ${response.statusCode} $body');
      } catch (_) {}
    }

    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>?> findExistingLoan(
    String itemId,
    String borrowerId,
  ) async {
    final response = await _request(
      () => http.get(
        Uri.parse(
          '$baseUrl/api/loans/find?itemId=$itemId&borrowerId=$borrowerId',
        ),
      ),
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }
}
