import 'dart:io';
import 'package:flutter/material.dart';

import 'profile_state.dart';
import '../../../core/services/profile_service.dart';

/// Controller class that manages profile state and business logic
/// Separates state management from UI components
class ProfileController extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  
  ProfileState _state = const ProfileState();
  ProfileState get state => _state;

  /// Initialize profile data
  Future<void> initialize() async {
    _updateState(_state.copyWith(isLoading: true, clearError: true));

    try {
      // Load user data and balance
      final userData = await _profileService.loadUserAndBalance();
      
      // Load statistics
      final statistics = await _profileService.loadUserStatistics();
      
      // Load saved profile image
      final profileImage = await _profileService.loadSavedImage();

      _updateState(_state.copyWith(
        user: userData.user,
        hippoBalanceCents: userData.hippoBalanceCents,
        transactionCount: userData.transactionCount,
        statistics: statistics,
        profileImage: profileImage,
        isLoading: false,
      ));
    } catch (e) {
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
        final updatedGallery = List<File>.from(_state.galleryImages)..addAll(images);
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