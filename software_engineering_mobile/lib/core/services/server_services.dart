import '../models/user.dart';
import 'api_service.dart';

class ServerVoteService {
  Future<int> getScore(String itemId) async {
    return 0;
  }

  Future<int> getUserVote(String itemId, String userId) async {
    return 0;
  }

  Future<int> setVote({
    required String itemId,
    required String userId,
    required int vote,
  }) async {
    return 0;
  }
}

class ServerFavoriteService {
  Future<bool> isFavorited(String itemId, String userId) async {
    return false;
  }

  Future<void> toggleFavorite({
    required String itemId,
    required String userId,
  }) async {
    // TODO: Implement
  }

  Future<List<String>> getUserFavorites(String userId) async {
    return [];
  }
}

class ServerProfileService {
  Future<dynamic> loadUserAndBalance() async {
    return null;
  }
  
  Future<dynamic> loadUserStatistics() async {
    return null;
  }
  
  Future<dynamic> loadSavedImage() async {
    return null;
  }
  
  Future<dynamic> pickImage() async {
    return null;
  }
  
  Future<List<dynamic>> pickMultipleImages() async {
    return [];
  }
  
  Future<int> depositHippoBucks(String userId, String amount) async {
    return 0;
  }
  
  Future<int> withdrawHippoBucks(String userId, String amount) async {
    return 0;
  }
  
  Future<dynamic> updateUserProfile(dynamic user, String firstName, String email) async {
    return null;
  }
  
  String formatBalance(int cents) {
    return '\$${(cents / 100).toStringAsFixed(2)}';
  }
}