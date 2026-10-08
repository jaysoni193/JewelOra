import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/constants/app_icon_options.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/utils/validators.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/app_card.dart';
import 'package:jewel_ora/core/widgets/app_dropdown.dart';
import 'package:jewel_ora/core/widgets/app_loader.dart';
import 'package:jewel_ora/core/widgets/app_text_field.dart';
import 'package:jewel_ora/core/widgets/single_image_uploader.dart';
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
      appBar: AppBar(
        title: const Text('Store & App Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Branding & Logo',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BrandingManagementScreen()),
            ),
          ),
        ],
      ),
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
  late final TextEditingController _nameCtrl;
  late final TextEditingController _whatsappCtrl;
  late final TextEditingController _welcomeCtrl;
  late String _logoUrl;
  late String _appIcon;

  @override
  void initState() {
    super.initState();
    final s = widget.initial;
    _nameCtrl = TextEditingController(text: s.appName);
    _whatsappCtrl = TextEditingController(text: s.whatsappNumber);
    _welcomeCtrl = TextEditingController(text: s.welcomeMessage);
    _logoUrl = s.logoUrl;
    _appIcon = s.appIcon;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _whatsappCtrl.dispose();
    _welcomeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<SettingsProvider>();
    final ok = await provider.save(
      AppSettingsModel(
        logoUrl: _logoUrl,
        appName: _nameCtrl.text.trim(),
        whatsappNumber: _whatsappCtrl.text.replaceAll(RegExp(r'\D'), ''),
        welcomeMessage: _welcomeCtrl.text.trim(),
        appIcon: _appIcon,
      ),
    );

    if (!mounted) return;
    showAppSnackBar(
      context,
      ok ? 'Settings saved successfully' : (provider.errorMessage ?? AppStrings.somethingWentWrong),
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
              // Dynamic Branding Quick Shortcut
              AppCard(
                padding: const EdgeInsets.all(16),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BrandingManagementScreen()),
                ),
                color: AppColors.primaryLight.withValues(alpha: 0.35),
                border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.6)),
                child: const Row(
                  children: [
                    Icon(Icons.palette_outlined, color: AppColors.primaryDark, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Branding & Logo Management',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Change logo, preview live customer header, and edit name',
                            style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: AppColors.primaryDark),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Logo section
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Store Logo', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 12),
                    SingleImageUploader(
                      label: '',
                      initialUrl: _logoUrl,
                      folder: 'jewel_ora/branding',
                      height: 120,
                      fit: BoxFit.contain,
                      onUploaded: (url) => setState(() => _logoUrl = url),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Store Identity
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('General Settings', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _nameCtrl,
                      label: 'Store Name',
                      prefixIcon: Icons.storefront_outlined,
                      validator: (v) => Validators.required(v, 'Store name'),
                    ),
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
                        style: TextStyle(fontSize: 11, color: AppColors.textGrey),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _welcomeCtrl,
                      label: 'Welcome Message',
                      prefixIcon: Icons.waving_hand_outlined,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Launcher Icon
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Launcher Icon Style', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 4),
                    const Text(
                      'Changes installed phone home-screen icon when the app restarts',
                      style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                    ),
                    const SizedBox(height: 14),
                    AppDropdown<String>(
                      label: 'App Launcher Icon',
                      value: AppIconOptions.byKey(_appIcon).key,
                      prefixIcon: Icons.apps_outlined,
                      items: [
                        for (final o in AppIconOptions.all)
                          DropdownMenuItem(value: o.key, child: Text(o.label)),
                      ],
                      onChanged: (v) => setState(() => _appIcon = v ?? 'default'),
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