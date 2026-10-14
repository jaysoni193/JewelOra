import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/app_card.dart';
import 'package:jewel_ora/core/widgets/app_dialog.dart';
import 'package:jewel_ora/providers/auth_provider.dart';
import 'package:jewel_ora/providers/locale_provider.dart';
import 'package:jewel_ora/providers/wishlist_provider.dart';
import 'package:jewel_ora/screens/user/book_visit_dialog.dart';
import 'package:jewel_ora/screens/user/change_password_screen.dart';
import 'package:jewel_ora/screens/user/custom_order_screen.dart';
import 'package:jewel_ora/screens/user/edit_profile_screen.dart';
import 'package:jewel_ora/screens/user/enquiry_history_screen.dart';
import 'package:jewel_ora/screens/user/store_info_screen.dart';
import 'package:jewel_ora/screens/user/widgets/jewellery_care_dialog.dart';
import 'package:jewel_ora/screens/user/widgets/ring_size_guide_dialog.dart';
import 'package:jewel_ora/screens/user/wishlist_screen.dart';
import 'package:provider/provider.dart';

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

  void _showLanguageDialog(BuildContext context) {
    final localeP = context.read<LocaleProvider>();
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Select Language / भाषा / ભાષા',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                ListTile(
                  title: const Text('English (Default)'),
                  trailing: localeP.locale == 'en'
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                      : null,
                  onTap: () {
                    localeP.setLocale('en');
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  title: const Text('हिंदी (Hindi)'),
                  trailing: localeP.locale == 'hi'
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                      : null,
                  onTap: () {
                    localeP.setLocale('hi');
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  title: const Text('ગુજરાતી (Gujarati)'),
                  trailing: localeP.locale == 'gu'
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                      : null,
                  onTap: () {
                    localeP.setLocale('gu');
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final wishlistCount = context.watch<WishlistProvider>().count;
    final initial =
        (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(AppStrings.myProfile)),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // User Avatar with CaratLane / GIVA Plum Halo
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primaryLight, AppColors.cardBackground],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
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
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              user?.name ?? AppStrings.valuedCustomer,
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
                  leading: const Icon(Icons.email_outlined, color: AppColors.primary),
                  title: Text(AppStrings.emailAddress, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text(user?.email ?? '', style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.phone_outlined, color: AppColors.primary),
                  title: Text(AppStrings.phoneNumber, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    (user?.phone.isNotEmpty ?? false) ? user!.phone : AppStrings.notProvided,
                    style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Services & Customer Tools Card
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary),
                  title: Text(AppStrings.enquiryHistory, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    AppStrings.enquiryHistorySubtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey),
                  onTap: () => _open(context, const EnquiryHistoryScreen()),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.auto_awesome_outlined, color: AppColors.primary),
                  title: Text(AppStrings.requestCustomJewellery, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    AppStrings.requestCustomSubtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey),
                  onTap: () => _open(context, const CustomOrderScreen()),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.calendar_month_outlined, color: AppColors.primary),
                  title: Text(AppStrings.bookShowroomVisit, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    AppStrings.bookVisitSubtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                  ),
                  onTap: () => BookVisitSheet.show(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.storefront_outlined, color: AppColors.primary),
                  title: Text(AppStrings.storeInfo, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    AppStrings.storeInfoSubtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey),
                  onTap: () => _open(context, const StoreInfoScreen()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Guides & Preferences Card
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.straighten_rounded, color: AppColors.primary),
                  title: Text(AppStrings.ringSizeGuide, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    AppStrings.ringSizeGuideSubtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey),
                  onTap: () => RingSizeGuideSheet.show(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.cleaning_services_outlined, color: AppColors.primary),
                  title: Text(AppStrings.jewelleryCare, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    AppStrings.jewelleryCareSubtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey),
                  onTap: () => JewelleryCareSheet.show(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language_rounded, color: AppColors.primary),
                  title: Text(AppStrings.changeLanguage, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    AppStrings.changeLanguageSubtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey),
                  onTap: () => _showLanguageDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.favorite_border_rounded, color: AppColors.primary),
                  title: Text(AppStrings.myWishlist, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    wishlistCount == 0 ? 'No items saved yet' : '$wishlistCount saved jewellery pieces',
                    style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey),
                  onTap: () => _open(context, const WishlistScreen()),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
                  title: const Text('Edit Profile', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey),
                  onTap: () => _open(context, const EditProfileScreen()),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
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