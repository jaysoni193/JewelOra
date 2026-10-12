import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_icon_options.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/utils/validators.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/app_card.dart';
import 'package:jewel_ora/core/widgets/app_icon_picker.dart';
import 'package:jewel_ora/core/widgets/app_loader.dart';
import 'package:jewel_ora/core/widgets/app_text_field.dart';
import 'package:jewel_ora/core/widgets/brand_logo.dart';
import 'package:jewel_ora/providers/settings_provider.dart';
import 'package:provider/provider.dart';

/// One place to choose the app icon. The icon you pick is used as:
///  - the phone home-screen icon (switches when customers leave the app), and
///  - the logo on the login page, home screen and admin console (instantly).
class BrandingManagementScreen extends StatefulWidget {
  const BrandingManagementScreen({super.key});

  @override
  State<BrandingManagementScreen> createState() =>
      _BrandingManagementScreenState();
}

class _BrandingManagementScreenState extends State<BrandingManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _welcomeCtrl;
  late String _icon;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final s = context.read<SettingsProvider>().settings;
      _nameCtrl = TextEditingController(text: s.appName);
      _welcomeCtrl = TextEditingController(text: s.welcomeMessage);
      _icon = AppIconOptions.byKey(s.appIcon).key;
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _welcomeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<SettingsProvider>();
    // Start from the CURRENT saved settings, so nothing else is overwritten.
    final updated = provider.settings.copyWith(
      appName: _nameCtrl.text.trim(),
      welcomeMessage: _welcomeCtrl.text.trim(),
      appIcon: _icon,
    );

    final ok = await provider.save(updated);
    if (!mounted) return;

    showAppSnackBar(
      context,
      ok
          ? 'Saved. The logo is updated everywhere in the app.'
          : (provider.errorMessage ?? AppStrings.somethingWentWrong),
      isError: !ok,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    final isSaving = provider.isSaving;

    return Scaffold(
      appBar: AppBar(title: const Text('App Branding')),
      body: provider.isLoading
          ? const Center(child: AppLoader())
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ---------- Explainer ----------
                AppCard(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.primaryLight.withValues(alpha: 0.5),
                  border: Border.all(
                      color: AppColors.borderAccent.withValues(alpha: 0.7)),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.auto_awesome_outlined,
                          color: AppColors.primaryDark, size: 26),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'One icon, everywhere',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'The icon you choose becomes the logo on the '
                                  'login page, home screen and admin console, '
                                  'and the icon on customers\' phones.',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textGrey,
                                  height: 1.35),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ---------- Icon picker ----------
                AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'App Icon',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tap an icon, check the preview, then press Save.',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textGrey),
                      ),
                      const SizedBox(height: 16),
                      AppIconPicker(
                        selectedKey: _icon,
                        onChanged: (k) => setState(() => _icon = k),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Phone home-screen icon: changes after customers '
                            'next close the app. The in-app logo changes at once.',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textGrey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ---------- Live preview ----------
                AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.visibility_outlined,
                              size: 18, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text(
                            'Customer header preview',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(
                              AppSizes.radiusMedium),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            BrandLogo(size: 44, iconKey: _icon),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _nameCtrl.text.isEmpty
                                        ? AppStrings.appName
                                        : _nameCtrl.text,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  Text(
                                    _welcomeCtrl.text.isEmpty
                                        ? AppStrings.appTagline
                                        : _welcomeCtrl.text,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textGrey),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.shopping_bag_outlined,
                                color: AppColors.textDark),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ---------- Store details ----------
                AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Store Details',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _nameCtrl,
                        label: 'Brand / Store Name',
                        prefixIcon: Icons.storefront_outlined,
                        onChanged: (_) => setState(() {}),
                        validator: (v) =>
                            Validators.required(v, 'Store name'),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _welcomeCtrl,
                        label: 'Customer Welcome Tagline',
                        prefixIcon: Icons.waving_hand_outlined,
                        maxLines: 2,
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                AppButton(
                  title: 'Save Branding',
                  isLoading: isSaving,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
