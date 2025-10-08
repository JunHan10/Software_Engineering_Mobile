import 'package:flutter/material.dart';

import 'models/profile_controller.dart';
import 'widgets/profile_app_bar.dart';
import 'widgets/statistics_section.dart';
import 'widgets/wallet_card.dart';
import 'widgets/gallery_section.dart';
import 'widgets/activity_section.dart';
import 'ui/profile_dialogs.dart';

/// ProfileV2 Main Page
/// Orchestrates all profile components and manages state through ProfileController
/// Separates UI from business logic following clean architecture principles
class ProfilePageV2 extends StatefulWidget {
  const ProfilePageV2({super.key});

  @override
  State<ProfilePageV2> createState() => _ProfilePageV2State();
}

class _ProfilePageV2State extends State<ProfilePageV2> {
  late final ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController();
    _controller.addListener(_onStateChanged);
    _initializeProfile();
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeProfile() async {
    await _controller.initialize();
  }

  void _onStateChanged() {
    // Handle error messages
    if (_controller.state.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ProfileDialogs.showErrorDialog(context, _controller.state.errorMessage!);
        _controller.clearError();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 231, 228, 213),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final state = _controller.state;
          
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF87AE73),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // Profile App Bar
              ProfileAppBar(
                displayName: state.displayName,
                displayEmail: state.displayEmail,
                profileImage: state.profileImage,
                onProfileImageTap: _controller.pickProfileImage,
                isPickingImage: state.isPickingImage,
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Statistics Cards
                      StatisticsSection(statistics: state.statistics),
                      const SizedBox(height: 20),

                      // Hippo Bucks Card
                      WalletCard(
                        formattedBalance: _controller.getFormattedBalance(),
                        onDeposit: _handleDeposit,
                        onWithdraw: _handleWithdraw,
                        onShowHistory: () => ProfileDialogs.showTransactionHistory(context),
                      ),
                      const SizedBox(height: 20),

                      // Image Gallery
                      GallerySection(
                        images: state.galleryImages,
                        onAddImages: _controller.pickGalleryImages,
                        onRemoveImage: _controller.removeGalleryImage,
                      ),
                      const SizedBox(height: 20),

                      // Recent Activity
                      const ActivitySection(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handleDeposit() async {
    final amount = await ProfileDialogs.showTransactionDialog(
      context: context,
      title: 'Add Hippo Bucks',
      action: 'Add',
    );
    
    if (amount != null && amount.isNotEmpty) {
      await _controller.depositHippoBucks(amount);
      if (mounted && _controller.state.errorMessage == null) {
        ProfileDialogs.showSuccessSnackbar(context, 'Money added successfully!');
      }
    }
  }

  Future<void> _handleWithdraw() async {
    final amount = await ProfileDialogs.showTransactionDialog(
      context: context,
      title: 'Spend Hippo Bucks',
      action: 'Spend',
    );
    
    if (amount != null && amount.isNotEmpty) {
      await _controller.withdrawHippoBucks(amount);
      if (mounted && _controller.state.errorMessage == null) {
        ProfileDialogs.showSuccessSnackbar(context, 'Money spent successfully!');
      }
    }
  }
}