import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/theme/app_text_styles.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/app_card.dart';
import 'package:jewel_ora/core/widgets/app_snackbar.dart';
import 'package:jewel_ora/core/widgets/app_text_field.dart';
import 'package:jewel_ora/core/widgets/single_image_uploader.dart';
import 'package:jewel_ora/models/banner_model.dart';
import 'package:jewel_ora/providers/banner_provider.dart';
import 'package:provider/provider.dart';

class BannerFormScreen extends StatefulWidget {
  /// null = add mode, otherwise edit mode.
  final BannerModel? banner;
  const BannerFormScreen({super.key, this.banner});

  @override
  State<BannerFormScreen> createState() => _BannerFormScreenState();
}

class _BannerFormScreenState extends State<BannerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late String _imageUrl;
  late bool _isActive;

  bool get _isEdit => widget.banner != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.banner?.title ?? '');
    _imageUrl = widget.banner?.imageUrl ?? '';
    _isActive = widget.banner?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (_imageUrl.isEmpty) {
      AppSnackbar.showWarning(context, 'Please upload a banner image');
      return;
    }

    final provider = context.read<BannerProvider>();
    final ok = await provider.save(
      existing: widget.banner,
      title: _titleCtrl.text.trim(),
      imageUrl: _imageUrl,
      isActive: _isActive,
    );

    if (!mounted) return;
    if (ok) {
      AppSnackbar.showSuccess(
        context,
        _isEdit ? 'Banner updated successfully' : 'Banner published successfully',
      );
      Navigator.of(context).pop();
    } else {
      AppSnackbar.showError(
        context,
        provider.errorMessage ?? AppStrings.somethingWentWrong,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<BannerProvider>().isSaving;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Banner' : 'Add Banner'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.p20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Banner Media',
                        style: AppTextStyles.h4,
                      ),
                      const SizedBox(height: AppSizes.p4),
                      Text(
                        'Recommended ratio 16:7 (e.g. 1600 × 700 px) for optimal boutique display.',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textGrey),
                      ),
                      const SizedBox(height: AppSizes.p16),
                      SingleImageUploader(
                        label: 'Banner Image',
                        initialUrl: _imageUrl,
                        folder: 'jewel_ora/banners',
                        height: 180,
                        onUploaded: (url) => setState(() => _imageUrl = url),
                      ),
                      const SizedBox(height: AppSizes.p20),
                      AppTextField(
                        controller: _titleCtrl,
                        label: 'Promotional Title (optional)',
                        hintText: 'e.g. Festive Gold Collection 2026',
                        prefixIcon: Icons.title,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.p16),
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: AppSizes.p8),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: AppColors.primary,
                    activeTrackColor: AppColors.primaryLight,
                    title: const Text(
                      'Visible on Customer Home',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    subtitle: const Text(
                      'Turn off to archive banner without deleting it',
                      style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                    ),
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                ),
                const SizedBox(height: AppSizes.p24),
                AppButton(
                  title: _isEdit ? 'Save Changes' : 'Publish Banner',
                  isLoading: isSaving,
                  icon: _isEdit ? Icons.check : Icons.add,
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