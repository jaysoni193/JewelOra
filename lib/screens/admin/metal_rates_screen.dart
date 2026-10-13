import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/utils/validators.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/app_card.dart';
import 'package:jewel_ora/core/widgets/app_snackbar.dart';
import 'package:jewel_ora/core/widgets/app_text_field.dart';
import 'package:jewel_ora/models/metal_rate_model.dart';
import 'package:jewel_ora/providers/metal_rate_provider.dart';
import 'package:provider/provider.dart';

class MetalRatesScreen extends StatefulWidget {
  const MetalRatesScreen({super.key});

  @override
  State<MetalRatesScreen> createState() => _MetalRatesScreenState();
}

class _MetalRatesScreenState extends State<MetalRatesScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _gold24kCtrl;
  late final TextEditingController _gold22kCtrl;
  late final TextEditingController _gold18kCtrl;
  late final TextEditingController _silver1gCtrl;
  late final TextEditingController _goldChangeCtrl;
  late final TextEditingController _silverChangeCtrl;
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    final r = context.read<MetalRateProvider>().rates;
    _gold24kCtrl = TextEditingController(text: r.gold24k.toStringAsFixed(0));
    _gold22kCtrl = TextEditingController(text: r.gold22k.toStringAsFixed(0));
    _gold18kCtrl = TextEditingController(text: r.gold18k.toStringAsFixed(0));
    _silver1gCtrl = TextEditingController(text: r.silver1g.toStringAsFixed(1));
    _goldChangeCtrl = TextEditingController(text: r.gold24kChange.toStringAsFixed(0));
    _silverChangeCtrl = TextEditingController(text: r.silverChange.toStringAsFixed(1));
    _isEnabled = r.isEnabled;
  }

  @override
  void dispose() {
    _gold24kCtrl.dispose();
    _gold22kCtrl.dispose();
    _gold18kCtrl.dispose();
    _silver1gCtrl.dispose();
    _goldChangeCtrl.dispose();
    _silverChangeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final updated = MetalRateModel(
      gold24k: double.tryParse(_gold24kCtrl.text.trim()) ?? 7650.0,
      gold22k: double.tryParse(_gold22kCtrl.text.trim()) ?? 7015.0,
      gold18k: double.tryParse(_gold18kCtrl.text.trim()) ?? 5740.0,
      silver1g: double.tryParse(_silver1gCtrl.text.trim()) ?? 92.0,
      gold24kChange: double.tryParse(_goldChangeCtrl.text.trim()) ?? 0.0,
      silverChange: double.tryParse(_silverChangeCtrl.text.trim()) ?? 0.0,
      updatedAt: DateTime.now(),
      isEnabled: _isEnabled,
    );

    final ok = await context.read<MetalRateProvider>().save(updated);
    if (!mounted) return;

    if (ok) {
      AppSnackbar.showSuccess(context, "Today's metal rates published successfully!");
      Navigator.pop(context);
    } else {
      AppSnackbar.showError(context, "Failed to update metal rates");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<MetalRateProvider>().isSaving;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daily Gold & Silver Rates'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.p20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderAccent),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Update today’s live market rates. Customers will see these rates on the Home screen in real time.',
                          style: TextStyle(fontSize: 12, color: AppColors.textDark, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Gold Rates Card
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.monetization_on_outlined, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Gold Rates (per gram)',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _gold24kCtrl,
                        label: '24 Karat Pure Gold (₹ / gram)',
                        hintText: 'e.g. 7650',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        prefixIcon: Icons.currency_rupee,
                        validator: (v) => Validators.required(v, '24K Rate'),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _gold22kCtrl,
                        label: '22 Karat Standard Jewellery (₹ / gram)',
                        hintText: 'e.g. 7015',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        prefixIcon: Icons.currency_rupee,
                        validator: (v) => Validators.required(v, '22K Rate'),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _gold18kCtrl,
                        label: '18 Karat Diamond Jewellery (₹ / gram)',
                        hintText: 'e.g. 5740',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        prefixIcon: Icons.currency_rupee,
                        validator: (v) => Validators.required(v, '18K Rate'),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _goldChangeCtrl,
                        label: 'Daily Gold Change (₹ vs yesterday, + or -)',
                        hintText: 'e.g. 25 or -15',
                        keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                        prefixIcon: Icons.trending_up,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Silver Rates Card
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.grain_rounded, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Silver Rates (per gram)',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _silver1gCtrl,
                        label: 'Silver Rate (₹ / gram)',
                        hintText: 'e.g. 92.0',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        prefixIcon: Icons.currency_rupee,
                        validator: (v) => Validators.required(v, 'Silver Rate'),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _silverChangeCtrl,
                        label: 'Daily Silver Change (₹ vs yesterday, + or -)',
                        hintText: 'e.g. 1.0 or -0.5',
                        keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                        prefixIcon: Icons.trending_up,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Visibility Toggle
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: AppColors.primary,
                    activeTrackColor: AppColors.primaryLight,
                    title: const Text(
                      "Show Today's Rates on Home Screen",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    subtitle: const Text(
                      'Turn off to temporarily hide the rates strip from customers',
                      style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                    ),
                    value: _isEnabled,
                    onChanged: (v) => setState(() => _isEnabled = v),
                  ),
                ),
                const SizedBox(height: 24),

                AppButton(
                  title: 'Publish Today’s Rates',
                  isLoading: isSaving,
                  icon: Icons.check_circle_outline,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
