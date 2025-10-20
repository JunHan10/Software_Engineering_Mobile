import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import '../models/user.dart';
import 'api_service.dart';
import 'session_service.dart';

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
  Future<({User? user, int hippoBalanceCents, int transactionCount})> loadUserAndBalance() async {
    try {
      print('Loading user and balance...');
      final user = await SessionService.getCurrentUser();
      print('Current user: ${user?.email}');
      
      if (user == null) {
        print('No user found in session');
        return (user: null, hippoBalanceCents: 0, transactionCount: 0);
      }
      
      print('Getting balance for user ID: ${user.id}');
      final balance = await ApiService.getBalance(user.id!);
      print('Balance: $balance');
      
      final transactions = await ApiService.getTransactions(user.id!);
      print('Transactions count: ${transactions.length}');
      
      return (
        user: user,
        hippoBalanceCents: balance,
        transactionCount: transactions.length
      );
    } catch (e) {
      print('Error loading user and balance: $e');
      return (user: null, hippoBalanceCents: 0, transactionCount: 0);
    }
  }
  
  Future<Map<String, int>> loadUserStatistics() async {
    try {
      print('Loading user statistics...');
      final user = await SessionService.getCurrentUser();
      if (user == null) {
        print('No user for statistics');
        return {};
      }
      
      print('Getting assets for user: ${user.id}');
      final assets = await ApiService.getAssetsByOwner(user.id!);
      print('Assets count: ${assets.length}');
      
      final favorites = await ApiService.getFavorites(user.id!);
      print('Favorites count: ${favorites.length}');
      
      return {
        'items': assets.length,
        'favorites': favorites.length,
        'loans': 0, // TODO: implement loans count
      };
    } catch (e) {
      print('Error loading statistics: $e');
      return {};
    }
  }
  
  Future<File?> loadSavedImage() async {
    try {
      final user = await SessionService.getCurrentUser();
      if (user?.photoUrl != null && user!.photoUrl!.isNotEmpty) {
        // Convert base64 back to file for display
        final bytes = base64Decode(user.photoUrl!);
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/temp_profile_image.jpg');
        await file.writeAsBytes(bytes);
        return file;
      }
    } catch (e) {
      print('Error loading saved image: $e');
    }
    return null;
  }
  
  Future<File?> pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        
        // Compress image
        final bytes = await file.readAsBytes();
        final image = img.decodeImage(bytes);
        if (image != null) {
          // Resize to max 300x300 and compress
          final resized = img.copyResize(image, width: 300, height: 300);
          final compressedBytes = img.encodeJpg(resized, quality: 70);
          final base64Image = base64Encode(compressedBytes);
          
          final user = await SessionService.getCurrentUser();
          if (user?.id != null) {
            await ApiService.updateProfilePicture(user!.id!, base64Image);
          }
          
          // Save compressed image locally for display
          final directory = await getApplicationDocumentsDirectory();
          final compressedFile = File('${directory.path}/compressed_profile.jpg');
          await compressedFile.writeAsBytes(compressedBytes);
          return compressedFile;
        }
      }
    } catch (e) {
      print('Error picking image: $e');
    }
    return null;
  }
  
  Future<List<File>> pickMultipleImages() async {
    try {
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage();
      return pickedFiles.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      return [];
    }
  }
  
  Future<int> depositHippoBucks(String userId, String amountText) async {
    try {
      final amount = (double.parse(amountText) * 100).round();
      await ApiService.depositMoney(userId, amount);
      return await ApiService.getBalance(userId);
    } catch (e) {
      throw Exception('Invalid amount or deposit failed');
    }
  }
  
  Future<int> withdrawHippoBucks(String userId, String amountText) async {
    try {
      final amount = (double.parse(amountText) * 100).round();
      await ApiService.withdrawMoney(userId, amount);
      return await ApiService.getBalance(userId);
    } catch (e) {
      throw Exception('Invalid amount or withdrawal failed');
    }
  }
  
  Future<User?> updateUserProfile(User user, String firstName, String email) async {
    try {
      final updatedData = {
        'firstName': firstName,
        'lastName': user.lastName,
        'email': email,
        'phone': user.phone,
      };
      
      final result = await ApiService.updateUser(user.id!, updatedData);
      return result != null ? User.fromJson(result) : null;
    } catch (e) {
      throw Exception('Failed to update profile');
    }
  }
  
  String formatBalance(int cents) {
    return '\$${(cents / 100).toStringAsFixed(2)}';
  }
}