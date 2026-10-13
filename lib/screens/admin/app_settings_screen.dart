import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/utils/validators.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/app_card.dart';
import 'package:jewel_ora/core/widgets/app_loader.dart';
import 'package:jewel_ora/core/widgets/app_text_field.dart';
import 'package:jewel_ora/core/widgets/brand_logo.dart';
import 'package:jewel_ora/models/app_settings_model.dart';
import 'package:jewel_ora/providers/settings_provider.dart';
import 'package:jewel_ora/screens/admin/branding_management_screen.dart';
import 'package:provider/provider.dart';

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Store Settings')),
      body: provider.isLoading
          ? const Center(child: AppLoader())
          : _SettingsForm(initial: provider.settings),
    );
  }
}

class _SettingsForm extends StatefulWidget {
  final AppSettingsModel initial;
  const _SettingsForm({required this.initial});

  @override
  State<_SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<_SettingsForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _whatsappCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _mapUrlCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _instagramCtrl;
  late final TextEditingController _timingsCtrl;
  late final TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    _whatsappCtrl = TextEditingController(text: widget.initial.whatsappNumber);
    _addressCtrl = TextEditingController(text: widget.initial.storeAddress);
    _mapUrlCtrl = TextEditingController(text: widget.initial.mapUrl);
    _phoneCtrl = TextEditingController(text: widget.initial.storePhone);
    _instagramCtrl = TextEditingController(text: widget.initial.instagramHandle);
    _timingsCtrl = TextEditingController(text: widget.initial.storeTimings);
    _emailCtrl = TextEditingController(text: widget.initial.storeEmail);
  }

  @override
  void dispose() {
    _whatsappCtrl.dispose();
    _addressCtrl.dispose();
    _mapUrlCtrl.dispose();
    _phoneCtrl.dispose();
    _instagramCtrl.dispose();
    _timingsCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<SettingsProvider>();
    final ok = await provider.save(
      provider.settings.copyWith(
        whatsappNumber: _whatsappCtrl.text.replaceAll(RegExp(r'\D'), ''),
        storeAddress: _addressCtrl.text.trim(),
        mapUrl: _mapUrlCtrl.text.trim(),
        storePhone: _phoneCtrl.text.trim(),
        instagramHandle: _instagramCtrl.text.trim().replaceAll('@', ''),
        storeTimings: _timingsCtrl.text.trim(),
        storeEmail: _emailCtrl.text.trim(),
      ),
    );

    if (!mounted) return;
    showAppSnackBar(
      context,
      ok
          ? 'Settings saved successfully'
          : (provider.errorMessage ?? AppStrings.somethingWentWrong),
      isError: !ok,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<SettingsProvider>().isSaving;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Shortcut: icon, logo, name and tagline all live in Branding.
              AppCard(
                padding: const EdgeInsets.all(16),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const BrandingManagementScreen()),
                ),
                color: AppColors.primaryLight.withValues(alpha: 0.35),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3)),
                child: const Row(
                  children: [
                    BrandLogo(size: 44),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'App icon, store name & tagline',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Choose the icon used on phones and as the logo everywhere',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textGrey),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: AppColors.primaryDark),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Orders & WhatsApp
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Orders & Enquiries',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _whatsappCtrl,
                      label: 'WhatsApp Business Number',
                      prefixIcon: Icons.chat_outlined,
                      keyboardType: TextInputType.phone,
                      validator: Validators.whatsapp,
                      hintText: 'e.g. 919876543210',
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 4, left: 4),
                      child: Text(
                        'Include country code without + or spaces (e.g. 919876543210)',
                        style:
                        TextStyle(fontSize: 11, color: AppColors.textGrey),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Store Location & Info
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Store Info & Contact',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _addressCtrl,
                      label: 'Store Physical Address',
                      prefixIcon: Icons.location_on_outlined,
                      maxLines: 2,
                      hintText: 'e.g. 108, Jewel Boulevard, Zaveri Bazaar, Mumbai 400002',
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _mapUrlCtrl,
                      label: 'Google Maps Link / URL',
                      prefixIcon: Icons.map_outlined,
                      keyboardType: TextInputType.url,
                      hintText: 'e.g. https://maps.google.com/?q=...',
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _phoneCtrl,
                      label: 'Calling Phone Number',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      hintText: 'e.g. +91 98765 43210',
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _instagramCtrl,
                      label: 'Instagram Username / Handle',
                      prefixIcon: Icons.camera_alt_outlined,
                      hintText: 'e.g. jewelora.jewels (without @)',
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _timingsCtrl,
                      label: 'Store Operating Timings',
                      prefixIcon: Icons.access_time_rounded,
                      hintText: 'e.g. Mon - Sat: 10:30 AM - 8:30 PM | Sun: Closed',
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _emailCtrl,
                      label: 'Customer Support Email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      hintText: 'e.g. support@jewelora.com',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              AppButton(
                title: 'Save Settings',
                isLoading: isSaving,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
