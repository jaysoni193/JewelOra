import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/app_card.dart';
import 'package:jewel_ora/core/widgets/app_dialog.dart';
import 'package:jewel_ora/providers/auth_provider.dart';
import 'package:jewel_ora/screens/user/change_password_screen.dart';
import 'package:jewel_ora/screens/user/edit_profile_screen.dart';
import 'package:jewel_ora/screens/user/wishlist_screen.dart';
import 'package:provider/provider.dart';

import '../../providers/wishlist_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _logout(BuildContext context) async {
    final ok = await AppDialog.logout(context);
    if (ok && context.mounted) {
      await context.read<AuthProvider>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final wishlistCount = context.watch<WishlistProvider>().count;
    final initial =
        (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Profile')),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // User Avatar with Gold Halo
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF9EFCF), Color(0xFFE4D1A4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: AppColors.borderGold, width: 2.0),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              user?.name ?? 'Valued Customer',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
          Center(
            child: Text(
              user?.email ?? '',
              style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
            ),
          ),
          const SizedBox(height: 24),

          // User Contact Info Card
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.email_outlined, color: AppColors.primaryDark),
                  title: const Text('Email Address', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text(user?.email ?? '', style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.phone_outlined, color: AppColors.primaryDark),
                  title: const Text('Phone Number', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    (user?.phone.isNotEmpty ?? false) ? user!.phone : 'Not provided',
                    style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Actions Card
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.favorite_border_rounded, color: AppColors.primaryDark),
                  title: const Text('My Wishlist', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    wishlistCount == 0 ? 'No items saved yet' : '$wishlistCount saved jewellery pieces',
                    style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey),
                  onTap: () => _open(context, const WishlistScreen()),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.person_outline_rounded, color: AppColors.primaryDark),
                  title: const Text('Edit Profile', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey),
                  onTap: () => _open(context, const EditProfileScreen()),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_outline_rounded, color: AppColors.primaryDark),
                  title: const Text('Change Password', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey),
                  onTap: () => _open(context, const ChangePasswordScreen()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          AppButton.outlined(
            title: AppStrings.logout,
            icon: Icons.logout_rounded,
            foregroundColor: AppColors.error,
            onPressed: () => _logout(context),
          ),
        ],
      ),
    );
  }
}