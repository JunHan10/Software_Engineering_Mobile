import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'profile.dart';
import 'profile_ui.dart';
import 'profile_widget.dart';
import '../../../services/money_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileController()..init(),
      child: Consumer<ProfileController>(
        builder: (context, controller, _) {
          if (controller.loadingUser) {
            return const Scaffold(
              backgroundColor: Colors.teal,
              body: Center(
                  child: CircularProgressIndicator(color: Colors.white)),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Profile'),
              backgroundColor: Colors.teal.shade700,
              foregroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            backgroundColor: Colors.teal,
            body: Column(
              children: [
                // Top avatar section
                Container(
                  width: double.infinity,
                  height: 300,
                  color: Colors.black,
                  alignment: Alignment.center,
                  child: ProfileImageWidget(
                    pickedImage: controller.pickedImage,
                    displayName: controller.user?.firstName ?? 'User',
                    onTap: controller.pickImage,
                  ),
                ),

                const Divider(height: 0, thickness: 1, color: Colors.white),

                // Bottom section
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Colors.teal,
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton.icon(
                            onPressed: controller.pickMultipleImages,
                            icon: const Icon(Icons.add_photo_alternate),
                            label: const Text('Add Images'),
                          ),
                          const SizedBox(height: 10),

                          GalleryWidget(
                            images: controller.imageFiles,
                            onRemove: controller.removeImage,
                          ),

                          const SizedBox(height: 16),

                          // Wallet card
                          Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            color: Colors.white,
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hippo Bucks',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(color: Colors.black87),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    MoneyService.formatCents(
                                        controller.hippoBalanceCents),
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall
                                        ?.copyWith(color: Colors.black87),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 10,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () =>
                                            controller.deposit(context),
                                        icon: const Icon(Icons.add),
                                        label: const Text('Add'),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: () =>
                                            controller.withdraw(context),
                                        icon: const Icon(Icons.remove),
                                        label: const Text('Spend'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.check),
                              label: const Text('Done'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
