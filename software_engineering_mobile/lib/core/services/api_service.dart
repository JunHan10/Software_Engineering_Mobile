import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.50.158:3000';
  
  static Future<List<dynamic>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/api/users'));
    return response.statusCode == 200 ? jsonDecode(response.body) : [];
  }

  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final response = await http.get(Uri.parse('$baseUrl/api/users/$email'));
    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }

  static Future<Map<String, dynamic>?> getUserById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/users/id/$id'));
    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }

  static Future<List<dynamic>> getAssets() async {
    final response = await http.get(Uri.parse('$baseUrl/api/assets'));
    return response.statusCode == 200 ? jsonDecode(response.body) : [];
  }

  static Future<List<dynamic>> getAssetsByOwner(String ownerId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/assets/owner/$ownerId'));
    return response.statusCode == 200 ? jsonDecode(response.body) : [];
  }

  static Future<List<dynamic>> getVotes(String itemId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/votes/$itemId'));
    return response.statusCode == 200 ? jsonDecode(response.body) : [];
  }

  static Future<bool> createVote(Map<String, dynamic> voteData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/votes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(voteData),
    );
    return response.statusCode == 201;
  }

  static Future<List<dynamic>> getNotifications(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/notifications/$userId'));
    return response.statusCode == 200 ? jsonDecode(response.body) : [];
  }

  static Future<List<dynamic>> getFavorites(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/favorites/$userId'));
    return response.statusCode == 200 ? jsonDecode(response.body) : [];
  }

  static Future<bool> createFavorite(Map<String, dynamic> favoriteData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/favorites'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(favoriteData),
    );
    return response.statusCode == 201;
  }

  static Future<bool> createNotification(Map<String, dynamic> notificationData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/notifications'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(notificationData),
    );
    return response.statusCode == 201;
  }

  static Future<Map<String, dynamic>?> createUser(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );
    return response.statusCode == 201 ? jsonDecode(response.body) : null;
  }

  static Future<Map<String, dynamic>?> updateUser(String id, Map<String, dynamic> userData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/users/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }

  static Future<Map<String, dynamic>?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }

  static Future<Map<String, dynamic>?> createAsset(Map<String, dynamic> assetData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/assets'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(assetData),
    );
    return response.statusCode == 201 ? jsonDecode(response.body) : null;
  }

  static Future<bool> updateAsset(String id, Map<String, dynamic> assetData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/assets/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(assetData),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteAsset(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/api/assets/$id'));
    return response.statusCode == 204;
  }

  static Future<bool> depositMoney(String userId, int amount) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users/$userId/deposit'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'amount': amount}),
    );
    return response.statusCode == 200;
  }

  static Future<bool> withdrawMoney(String userId, int amount) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users/$userId/withdraw'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'amount': amount}),
    );
    return response.statusCode == 200;
  }

  static Future<int> getBalance(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/users/$userId/balance'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['balance'];
    }
    return 0;
  }

  static Future<bool> removeFavorite(String userId, String assetId) async {
    final response = await http.delete(Uri.parse('$baseUrl/api/favorites/$userId/$assetId'));
    return response.statusCode == 204;
  }

  static Future<List<dynamic>> getTransactions(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/transactions/$userId'));
    return response.statusCode == 200 ? jsonDecode(response.body) : [];
  }

  static Future<bool> createTransaction(Map<String, dynamic> transactionData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/transactions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(transactionData),
    );
    return response.statusCode == 201;
  }

  static Future<bool> updateTransaction(String id, Map<String, dynamic> transactionData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/transactions/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(transactionData),
    );
    return response.statusCode == 200;
  }
}