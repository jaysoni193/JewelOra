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

  @override
  void initState() {
    super.initState();
    _whatsappCtrl = TextEditingController(text: widget.initial.whatsappNumber);
  }

  @override
  void dispose() {
    _whatsappCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<SettingsProvider>();
    // Only the WhatsApp number is changed here; everything else stays as saved.
    final ok = await provider.save(
      provider.settings.copyWith(
        whatsappNumber: _whatsappCtrl.text.replaceAll(RegExp(r'\D'), ''),
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
                    color: AppColors.borderGold.withValues(alpha: 0.6)),
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
              const SizedBox(height: 20),

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
