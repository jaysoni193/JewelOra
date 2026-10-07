import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/utils/validators.dart';
import 'package:jewel_ora/core/widgets/app_text_field.dart';
import 'package:jewel_ora/core/widgets/loading_view.dart';
import 'package:jewel_ora/core/widgets/primary_button.dart';
import 'package:jewel_ora/core/widgets/single_image_uploader.dart';
import 'package:jewel_ora/models/app_settings_model.dart';
import 'package:jewel_ora/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_icon_options.dart';

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('App Settings')),
      body: provider.isLoading
          ? const LoadingView()
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
        // Keep digits only: wa.me links do not accept + or spaces.
        whatsappNumber: _whatsappCtrl.text.replaceAll(RegExp(r'\D'), ''),
        welcomeMessage: _welcomeCtrl.text.trim(),
        appIcon: _appIcon,
      ),
    );

    if (!mounted) return;
    showAppSnackBar(
      context,
      ok
          ? 'Settings saved'
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
              SingleImageUploader(
                label: 'App logo',
                initialUrl: _logoUrl,
                folder: 'jewel_ora/branding',
                height: 140,
                fit: BoxFit.contain,
                onUploaded: (url) => _logoUrl = url,
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _nameCtrl,
                label: 'App / shop name',
                prefixIcon: Icons.storefront_outlined,
                validator: (v) => Validators.required(v, 'App name'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _whatsappCtrl,
                label: 'WhatsApp number',
                prefixIcon: Icons.chat_outlined,
                keyboardType: TextInputType.phone,
                validator: Validators.whatsapp,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  'With country code, no + sign. Example: 919876543210',
                  style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _welcomeCtrl,
                label: 'Welcome message',
                prefixIcon: Icons.waving_hand_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: AppIconOptions.byKey(_appIcon).key,
                decoration: const InputDecoration(
                  labelText: 'Phone home-screen icon',
                  prefixIcon: Icon(Icons.apps_outlined),
                  helperText: 'Changes when customers next open the app',
                ),
                items: [
                  for (final o in AppIconOptions.all)
                    DropdownMenuItem(value: o.key, child: Text(o.label)),
                ],
                onChanged: (v) => setState(() => _appIcon = v ?? 'default'),
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                text: 'Save Settings',
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