import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/theme/app_decoration.dart';
import 'package:jewel_ora/core/utils/responsive.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/utils/validators.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/app_card.dart';
import 'package:jewel_ora/core/widgets/app_dropdown.dart';
import 'package:jewel_ora/core/widgets/app_text_field.dart';
import 'package:jewel_ora/core/widgets/single_image_uploader.dart';
import 'package:jewel_ora/models/enquiry_model.dart';
import 'package:jewel_ora/providers/auth_provider.dart';
import 'package:jewel_ora/providers/enquiry_provider.dart';
import 'package:jewel_ora/providers/settings_provider.dart';
import 'package:jewel_ora/services/whatsapp_service.dart';
import 'package:provider/provider.dart';

class CustomOrderScreen extends StatefulWidget {
  const CustomOrderScreen({super.key});

  @override
  State<CustomOrderScreen> createState() => _CustomOrderScreenState();
}

class _CustomOrderScreenState extends State<CustomOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _budgetCtrl = TextEditingController();
  final _sizeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String? _selectedMetal = '22K Hallmark Gold';
  String? _referenceImageUrl;
  bool _isSubmitting = false;

  static const _metalOptions = [
    '22K Hallmark Gold',
    '24K Pure Gold',
    '18K Diamond Jewellery Gold',
    '925 Sterling Silver',
    '950 Platinum',
    'Rose Gold (18K)',
  ];

  @override
  void dispose() {
    _budgetCtrl.dispose();
    _sizeCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitCustomOrder() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final phone = context.read<SettingsProvider>().settings.whatsappNumber;
    final user = context.read<AuthProvider>().user;
    final customerName = user?.name ?? '';

    setState(() => _isSubmitting = true);

    try {
      final message = WhatsAppService.buildCustomOrderMessage(
        metal: _selectedMetal ?? '22K Gold',
        budget: _budgetCtrl.text.trim(),
        size: _sizeCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        imageUrl: _referenceImageUrl ?? '',
        customerName: customerName,
      );

      // Record in Enquiry History if logged in
      if (user != null) {
        context.read<EnquiryProvider>().recordEnquiry(
          EnquiryModel(
            id: '',
            userId: user.uid,
            userName: user.name,
            userPhone: user.phone,
            userEmail: user.email,
            items: [
              EnquiryItemModel(
                productId: 'custom_order',
                productName: 'Custom Order: ${_selectedMetal ?? 'Jewellery'}',
                productPrice: 0.0,
                productImage: _referenceImageUrl ?? '',
                quantity: 1,
                size: _sizeCtrl.text.trim(),
              ),
            ],
            totalAmount: 0.0,
            message: 'Custom order request: ${_descCtrl.text.trim()}',
            status: 'submitted',
            createdAt: DateTime.now(),
          ),
        );
      }

      await WhatsAppService.open(phone: phone, message: message);

      if (mounted) {
        showAppSnackBar(context, 'Custom order request sent to WhatsApp!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, 'Could not open WhatsApp. Please try again.', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.customOrder),
      ),
      body: ResponsiveContentWrapper(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveHorizontalPadding,
            vertical: 16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppSizes.radiusCard),
                    boxShadow: AppDecoration.luxuryShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.design_services_outlined, color: Colors.white, size: 24),
                          const SizedBox(width: 10),
                          Text(
                            AppStrings.customOrder,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppStrings.requestCustomSubtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Reference Photo Upload
                AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.referencePhotoTitle,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.referencePhotoDesc,
                        style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                      ),
                      const SizedBox(height: 14),
                      SingleImageUploader(
                        label: 'Reference Photo',
                        folder: 'custom_orders',
                        initialUrl: _referenceImageUrl ?? '',
                        onUploaded: (url) => setState(() => _referenceImageUrl = url),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Metal & Specifications
                AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.specificationsTitle,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 14),
                      AppDropdown<String>(
                        label: AppStrings.preferredMetal,
                        value: _selectedMetal,
                        items: _metalOptions
                            .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedMetal = v),
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _sizeCtrl,
                        label: AppStrings.sizeDimensions,
                        hintText: 'e.g. Ring Size 14, Bangle 2.6, or 18 inches',
                        prefixIcon: Icons.straighten_rounded,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _budgetCtrl,
                        label: AppStrings.approxBudget,
                        hintText: 'e.g. ₹35,000 - ₹50,000',
                        prefixIcon: Icons.currency_rupee_rounded,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _descCtrl,
                        label: AppStrings.detailedRequirements,
                        hintText: 'Describe finish, stone preferences, engraving name, or specific weight...',
                        prefixIcon: Icons.edit_note_rounded,
                        maxLines: 4,
                        validator: (v) => Validators.required(v, 'Custom order description'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                AppButton(
                  title: AppStrings.sendCustomOrderWhatsApp,
                  icon: Icons.chat_rounded,
                  backgroundColor: AppColors.whatsapp,
                  isLoading: _isSubmitting,
                  onPressed: _submitCustomOrder,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
