import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_images.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/utils/image_url.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/utils/validators.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/app_card.dart';
import 'package:jewel_ora/core/widgets/app_loader.dart';
import 'package:jewel_ora/core/widgets/app_text_field.dart';
import 'package:jewel_ora/core/widgets/single_image_uploader.dart';
import 'package:jewel_ora/models/app_settings_model.dart';
import 'package:jewel_ora/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class BrandingManagementScreen extends StatefulWidget {
  const BrandingManagementScreen({super.key});

  @override
  State<BrandingManagementScreen> createState() => _BrandingManagementScreenState();
}

class _BrandingManagementScreenState extends State<BrandingManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _welcomeCtrl;
  late String _logoUrl;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final s = context.read<SettingsProvider>().settings;
      _nameCtrl = TextEditingController(text: s.appName);
      _welcomeCtrl = TextEditingController(text: s.welcomeMessage);
      _logoUrl = s.logoUrl;
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
    final current = provider.settings;

    final updated = AppSettingsModel(
      logoUrl: _logoUrl,
      appName: _nameCtrl.text.trim(),
      whatsappNumber: current.whatsappNumber,
      welcomeMessage: _welcomeCtrl.text.trim(),
      appIcon: current.appIcon,
    );

    final ok = await provider.save(updated);
    if (!mounted) return;

    showAppSnackBar(
      context,
      ok ? 'Branding updated successfully' : (provider.errorMessage ?? AppStrings.somethingWentWrong),
      isError: !ok,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    final isSaving = provider.isSaving;

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Branding & Logo'),
      ),
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
                      // Header Explainer
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        color: AppColors.primaryLight.withValues(alpha: 0.3),
                        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
                        child: const Row(
                          children: [
                            Icon(Icons.palette_outlined, color: AppColors.primaryDark, size: 28),
                            SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dynamic In-App Branding',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    'Update your logo and store identity. Changes update across all customer screens in real-time.',
                                    style: TextStyle(fontSize: 12, color: AppColors.textGrey, height: 1.3),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Logo Uploader Card
                      AppCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Store Logo',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Upload a PNG or JPG with a transparent or clean background.',
                              style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                            ),
                            const SizedBox(height: 16),
                            SingleImageUploader(
                              label: '',
                              initialUrl: _logoUrl,
                              folder: 'jewel_ora/branding',
                              height: 140,
                              fit: BoxFit.contain,
                              onUploaded: (url) {
                                setState(() => _logoUrl = url);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Live Customer Preview Card
                      AppCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.visibility_outlined, size: 18, color: AppColors.primary),
                                SizedBox(width: 8),
                                Text(
                                  'Customer App Header Preview',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  if (_logoUrl.isNotEmpty)
                                    CachedNetworkImage(
                                      imageUrl: ImageUrl.optimized(_logoUrl, width: 200),
                                      height: 36,
                                      fit: BoxFit.contain,
                                      errorWidget: (context, url, error) => Image.asset(
                                        AppImages.logo,
                                        height: 36,
                                      ),
                                    )
                                  else
                                    Image.asset(
                                      AppImages.logo,
                                      height: 36,
                                    ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _nameCtrl.text.isEmpty ? AppStrings.appName : _nameCtrl.text,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.shopping_bag_outlined, color: AppColors.textDark),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Store Identity Details
                      AppCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Store Details',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _nameCtrl,
                              label: 'Brand / Store Name',
                              prefixIcon: Icons.storefront_outlined,
                              onChanged: (_) => setState(() {}),
                              validator: (v) => Validators.required(v, 'Store name'),
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _welcomeCtrl,
                              label: 'Customer Welcome Tagline',
                              prefixIcon: Icons.waving_hand_outlined,
                              maxLines: 2,
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
