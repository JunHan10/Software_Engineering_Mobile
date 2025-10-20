import 'dart:io';
import 'package:flutter/material.dart';

import 'profile_state.dart';
import '../../../core/services/server_services.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/user.dart';

/// Controller class that manages profile state and business logic
/// Separates state management from UI components
class ProfileController extends ChangeNotifier {
  final ServerProfileService _profileService = ServerProfileService();
  
  ProfileState _state = const ProfileState();
  ProfileState get state => _state;

  /// Initialize profile data
  Future<void> initialize() async {
    _updateState(_state.copyWith(isLoading: true, clearError: true));

    try {
      print('ProfileController: Starting profile initialization...');
      
      // Load user data and balance
      final userData = await _profileService.loadUserAndBalance();
      print('ProfileController: User data loaded: ${userData['user']?.firstName} ${userData['user']?.lastName}');
      print('ProfileController: Balance: ${userData['hippoBalanceCents']}');
      
      // Load statistics
      final statisticsData = await _profileService.loadUserStatistics();
      print('ProfileController: Statistics loaded: $statisticsData');
      
      // Load saved profile image
      final profileImage = await _profileService.loadSavedImage();

      // Load user's assets from the API
      final user = userData['user'] as User?;
      List<Asset> userAssets = [];
      if (user?.id != null) {
        try {
          final assetsData = await ApiService.getAssetsByOwner(user!.id!);
          userAssets = assetsData.map((assetJson) => Asset.fromJson(assetJson)).toList();
          print('ProfileController: Loaded ${userAssets.length} assets for user');
        } catch (e) {
          print('ProfileController: Error loading assets: $e');
        }
      }

      // Create ProfileStatistics object from the data
      final statistics = ProfileStatistics(
        totalLoans: statisticsData['totalLoans'] ?? 0,
        activeLoans: statisticsData['activeLoans'] ?? 0,
        completedLoans: statisticsData['completedLoans'] ?? 0,
        totalEarnings: (statisticsData['totalEarnings'] ?? 0.0).toDouble(),
      );

      print('ProfileController: Updating state with user: ${userData['user']?.email}');
      _updateState(_state.copyWith(
        user: userData['user'],
        hippoBalanceCents: userData['hippoBalanceCents'] ?? 0,
        transactionCount: userData['transactionCount'] ?? 0,
        statistics: statistics,
        profileImage: profileImage,
        userAssets: userAssets,
        isLoading: false,
      ));
      print('ProfileController: Profile initialization completed successfully');
    } catch (e) {
      print('ProfileController: Profile initialization error: $e');
      _updateState(_state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load profile data: $e',
      ));
    }
  }

  /// Pick and set profile image
  Future<void> pickProfileImage() async {
    if (_state.isPickingImage) return;
    
    _updateState(_state.copyWith(isPickingImage: true));
    
    try {
      final image = await _profileService.pickImage();
      if (image != null) {
        _updateState(_state.copyWith(
          profileImage: image,
          isPickingImage: false,
        ));
      } else {
        _updateState(_state.copyWith(isPickingImage: false));
      }
    } catch (e) {
      _updateState(_state.copyWith(
        isPickingImage: false,
        errorMessage: 'Failed to pick image: $e',
      ));
    }
  }

  /// Pick multiple images for gallery
  Future<void> pickGalleryImages() async {
    try {
      final images = await _profileService.pickMultipleImages();
      if (images.isNotEmpty) {
        final updatedGallery = List<File>.from(_state.galleryImages)..addAll(images.cast<File>());
        _updateState(_state.copyWith(galleryImages: updatedGallery));
      }
    } catch (e) {
      _updateState(_state.copyWith(
        errorMessage: 'Failed to pick gallery images: $e',
      ));
    }
  }

  /// Remove image from gallery
  void removeGalleryImage(int index) {
    if (index >= 0 && index < _state.galleryImages.length) {
      final updatedGallery = List<File>.from(_state.galleryImages)..removeAt(index);
      _updateState(_state.copyWith(galleryImages: updatedGallery));
    }
  }

  /// Deposit Hippo Bucks
  Future<void> depositHippoBucks(String amountText) async {
    if (!_state.isLoggedIn) {
      _updateState(_state.copyWith(
        errorMessage: 'No user available. Please log in first.',
      ));
      return;
    }

    try {
      final newBalance = await _profileService.depositHippoBucks(
        _state.user!.id!,
        amountText,
      );
      _updateState(_state.copyWith(
        hippoBalanceCents: newBalance,
        clearError: true,
      ));
    } catch (e) {
      _updateState(_state.copyWith(
        errorMessage: 'Failed to deposit: $e',
      ));
    }
  }

  /// Withdraw Hippo Bucks
  Future<void> withdrawHippoBucks(String amountText) async {
    if (!_state.isLoggedIn) {
      _updateState(_state.copyWith(
        errorMessage: 'No user available. Please log in first.',
      ));
      return;
    }

    try {
      final newBalance = await _profileService.withdrawHippoBucks(
        _state.user!.id!,
        amountText,
      );
      _updateState(_state.copyWith(
        hippoBalanceCents: newBalance,
        clearError: true,
      ));
    } catch (e) {
      _updateState(_state.copyWith(
        errorMessage: 'Failed to withdraw: $e',
      ));
    }
  }

  /// Update user profile information
  Future<void> updateProfile(String firstName, String email) async {
    if (!_state.isLoggedIn) {
      _updateState(_state.copyWith(
        errorMessage: 'No user available. Please log in first.',
      ));
      return;
    }

    try {
      final updatedUser = await _profileService.updateUserProfile(
        _state.user!,
        firstName,
        email,
      );
      if (updatedUser != null) {
        _updateState(_state.copyWith(
          user: updatedUser,
          clearError: true,
        ));
      }
    } catch (e) {
      _updateState(_state.copyWith(
        errorMessage: 'Failed to update profile: $e',
      ));
    }
  }

  /// Get formatted balance string
  String getFormattedBalance() {
    return _profileService.formatBalance(_state.hippoBalanceCents);
  }

  /// Clear error message
  void clearError() {
    _updateState(_state.copyWith(clearError: true));
  }

  /// Update state and notify listeners
  void _updateState(ProfileState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}