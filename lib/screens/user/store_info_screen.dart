import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_icons.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/app_card.dart';
import 'package:jewel_ora/core/widgets/brand_logo.dart';
import 'package:jewel_ora/providers/settings_provider.dart';
import 'package:jewel_ora/services/whatsapp_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreInfoScreen extends StatelessWidget {
  const StoreInfoScreen({super.key});

  Future<void> _launchExternal(BuildContext context, String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri == null) {
      showAppSnackBar(context, 'Invalid link', isError: true);
      return;
    }
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        showAppSnackBar(context, 'Could not open link', isError: true);
      }
    } catch (_) {
      if (context.mounted) {
        showAppSnackBar(context, 'Could not open link', isError: true);
      }
    }
  }

  Future<void> _makeCall(BuildContext context, String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (clean.isEmpty) {
      showAppSnackBar(context, 'Phone number not available', isError: true);
      return;
    }
    final uri = Uri.parse('tel:$clean');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        showAppSnackBar(context, 'Could not initiate call', isError: true);
      }
    }
  }

  Future<void> _sendEmail(BuildContext context, String email) async {
    if (email.isEmpty) return;
    final uri = Uri.parse('mailto:$email?subject=Jewellery%20Enquiry');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        showAppSnackBar(context, 'Could not open email client', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.storeInfo),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Hero Experience Banner (CaratLane & GIVA luxury style)
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.plumDeep],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const BrandLogo(size: 46),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            settings.appName.isNotEmpty
                                ? settings.appName
                                : AppStrings.appName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Flagship Experience Boutique',
                            style: TextStyle(
                              color: AppColors.secondaryLilac,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded,
                              size: 14, color: AppColors.accentRose),
                          SizedBox(width: 4),
                          Text(
                            'CERTIFIED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  settings.welcomeMessage.isNotEmpty
                      ? settings.welcomeMessage
                      : 'Experience our hallmark craftsmanship in person with personalized gemologist styling.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Quick Action Hub (Call, WhatsApp, Maps, Instagram)
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: AppIcons.phone,
                  label: AppStrings.callStore,
                  color: AppColors.primary,
                  onTap: () => _makeCall(context, settings.storePhone),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionButton(
                  icon: AppIcons.whatsapp,
                  label: 'WhatsApp',
                  color: const Color(0xFF25D366),
                  onTap: () {
                    WhatsAppService.open(
                      phone: settings.whatsappNumber,
                      message:
                          'Hello! I would like to visit the store / enquire about jewellery pieces.',
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionButton(
                  icon: AppIcons.directions,
                  label: AppStrings.getDirections,
                  color: AppColors.accentRose,
                  onTap: () => _launchExternal(context, settings.mapUrl),
                ),
              ),
              if (settings.instagramHandle.isNotEmpty) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickActionButton(
                    icon: AppIcons.instagram,
                    label: 'Instagram',
                    color: const Color(0xFFE1306C),
                    onTap: () => _launchExternal(
                      context,
                      'https://instagram.com/${settings.instagramHandle}',
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),

          // Address Card
          AppCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        AppIcons.location,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppStrings.storeAddress,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: const Icon(Icons.copy_rounded, size: 14),
                      label: const Text('Copy', style: TextStyle(fontSize: 12)),
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: settings.storeAddress),
                        );
                        showAppSnackBar(context, 'Address copied to clipboard');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  settings.storeAddress,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                AppButton.outlined(
                  title: 'Open in Google Maps',
                  icon: AppIcons.directions,
                  onPressed: () => _launchExternal(context, settings.mapUrl),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Timings & Working Hours Card
          AppCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        AppIcons.time,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Store Hours',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 3,
                            backgroundColor: Color(0xFF10B981),
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Open Today',
                            style: TextStyle(
                              color: Color(0xFF047857),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  settings.storeTimings,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textDark,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Contact Directory Card
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(AppIcons.phone, color: AppColors.primary),
                  title: const Text('Direct Phone',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text(settings.storePhone,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textGrey)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: AppColors.textGrey),
                  onTap: () => _makeCall(context, settings.storePhone),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(AppIcons.email, color: AppColors.primary),
                  title: const Text('Customer Care Email',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text(settings.storeEmail,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textGrey)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: AppColors.textGrey),
                  onTap: () => _sendEmail(context, settings.storeEmail),
                ),
                if (settings.instagramHandle.isNotEmpty) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(AppIcons.instagram,
                        color: Color(0xFFE1306C)),
                    title: const Text('Instagram Page',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: Text('@${settings.instagramHandle}',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textGrey)),
                    trailing: const Icon(Icons.open_in_new_rounded,
                        size: 16, color: AppColors.textGrey),
                    onTap: () => _launchExternal(
                      context,
                      'https://instagram.com/${settings.instagramHandle}',
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),

          // In-Store Experience Perks (GIVA & CaratLane style)
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              'Exclusive In-Store Services',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
          _ExperiencePerk(
            icon: Icons.diamond_outlined,
            title: 'Try 1000+ Designs',
            subtitle:
                'Explore our latest collections of 18K/22K gold & 925 sterling silver.',
          ),
          _ExperiencePerk(
            icon: Icons.cleaning_services_outlined,
            title: 'Free Jewellery Spa & Polish',
            subtitle:
                'Complimentary ultrasonic cleaning and checkup for all your jewellery.',
          ),
          _ExperiencePerk(
            icon: Icons.verified_user_outlined,
            title: '100% Certified & Hallmarked',
            subtitle:
                'Every jewel comes with authentic BIS Hallmark and SGL/IGI certificate.',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExperiencePerk extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ExperiencePerk({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
