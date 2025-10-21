import 'dart:io';
import '../../../core/models/user.dart';

/// State class that holds all profile-related data
/// Immutable state object that can be easily tested and managed
class ProfileState {
  final User? user;
  final int hippoBalanceCents;
  final int transactionCount;
  final ProfileStatistics statistics;
  final File? profileImage;
  final List<File> galleryImages;
  final List<Asset> userAssets;
  final bool isLoading;
  final bool isPickingImage;
  final String? errorMessage;

  const ProfileState({
    this.user,
    this.hippoBalanceCents = 0,
    this.transactionCount = 0,
    this.statistics = const ProfileStatistics(
      totalLoans: 0,
      activeLoans: 0,
      completedLoans: 0,
      totalEarnings: 0.0,
    ),
    this.profileImage,
    this.galleryImages = const [],
    this.userAssets = const [],
    this.isLoading = false,
    this.isPickingImage = false,
    this.errorMessage,
  });

  /// Create a copy of the state with updated values
  ProfileState copyWith({
    User? user,
    int? hippoBalanceCents,
    int? transactionCount,
    ProfileStatistics? statistics,
    File? profileImage,
    List<File>? galleryImages,
    List<Asset>? userAssets,
    bool? isLoading,
    bool? isPickingImage,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileState(
      user: user ?? this.user,
      hippoBalanceCents: hippoBalanceCents ?? this.hippoBalanceCents,
      transactionCount: transactionCount ?? this.transactionCount,
      statistics: statistics ?? this.statistics,
      profileImage: profileImage ?? this.profileImage,
      galleryImages: galleryImages ?? this.galleryImages,
      userAssets: userAssets ?? this.userAssets,
      isLoading: isLoading ?? this.isLoading,
      isPickingImage: isPickingImage ?? this.isPickingImage,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  /// Get user's display name
  String get displayName {
    final u = user;
    if (u != null) {
      final first = u.firstName;
      final last = u.lastName;
      final display =
          '${first.isNotEmpty ? first : ''}${last.isNotEmpty ? ' $last' : ''}'
              .trim();
      return display.isNotEmpty ? display : 'User';
    }
    return 'User';
  }

  /// Get user's email or default
  String get displayEmail {
    final u = user;
    if (u != null) {
      final e = u.email;
      return e.isNotEmpty ? e : 'user@example.com';
    }
    return 'user@example.com';
  }

  /// Check if user is logged in
  bool get isLoggedIn => user?.id?.isNotEmpty == true;
}

/// Profile-specific statistics data class
class ProfileStatistics {
  final int totalLoans;
  final int activeLoans;
  final int completedLoans;
  final double totalEarnings;

  const ProfileStatistics({
    required this.totalLoans,
    required this.activeLoans,
    required this.completedLoans,
    required this.totalEarnings,
  });

  ProfileStatistics copyWith({
    int? totalLoans,
    int? activeLoans,
    int? completedLoans,
    double? totalEarnings,
  }) {
    return ProfileStatistics(
      totalLoans: totalLoans ?? this.totalLoans,
      activeLoans: activeLoans ?? this.activeLoans,
      completedLoans: completedLoans ?? this.completedLoans,
      totalEarnings: totalEarnings ?? this.totalEarnings,
    );
  }
}
