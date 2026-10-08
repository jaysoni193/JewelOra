import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/theme/app_text_styles.dart';
import 'package:jewel_ora/core/utils/validators.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/app_card.dart';
import 'package:jewel_ora/core/widgets/app_snackbar.dart';
import 'package:jewel_ora/core/widgets/app_text_field.dart';
import 'package:jewel_ora/core/widgets/single_image_uploader.dart';
import 'package:jewel_ora/models/category_model.dart';
import 'package:jewel_ora/providers/category_provider.dart';
import 'package:provider/provider.dart';

class CategoryFormScreen extends StatefulWidget {
  /// null = add mode, otherwise edit mode.
  final CategoryModel? category;
  const CategoryFormScreen({super.key, this.category});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late String _imageUrl;
  late bool _isActive;

  bool get _isEdit => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.category?.name ?? '');
    _imageUrl = widget.category?.imageUrl ?? '';
    _isActive = widget.category?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    if (_imageUrl.isEmpty) {
      AppSnackbar.showWarning(context, 'Please upload a category image');
      return;
    }

    final provider = context.read<CategoryProvider>();
    final name = _nameCtrl.text.trim();

    if (provider.nameExists(name, excludeId: widget.category?.id)) {
      AppSnackbar.showError(context, 'A category with this name already exists');
      return;
    }

    final ok = await provider.save(
      existing: widget.category,
      name: name,
      imageUrl: _imageUrl,
      isActive: _isActive,
    );

    if (!mounted) return;
    if (ok) {
      AppSnackbar.showSuccess(
        context,
        _isEdit ? 'Category updated successfully' : 'Category created successfully',
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
    final isSaving = context.watch<CategoryProvider>().isSaving;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Category' : 'Add Category'),
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
                        'Category Media & Details',
                        style: AppTextStyles.h4,
                      ),
                      const SizedBox(height: AppSizes.p4),
                      Text(
                        'Upload a high quality thumbnail and enter category name.',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textGrey),
                      ),
                      const SizedBox(height: AppSizes.p16),
                      SingleImageUploader(
                        label: 'Category Thumbnail',
                        initialUrl: _imageUrl,
                        folder: 'jewel_ora/categories',
                        onUploaded: (url) => setState(() => _imageUrl = url),
                      ),
                      const SizedBox(height: AppSizes.p20),
                      AppTextField(
                        controller: _nameCtrl,
                        label: 'Category Name',
                        hintText: 'e.g. Diamond Rings, Necklaces',
                        prefixIcon: Icons.category_outlined,
                        validator: (v) => Validators.required(v, 'Name'),
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
                      'Visible to Customers',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    subtitle: const Text(
                      'Turn off to hide from boutique navigation and shop filters',
                      style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                    ),
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                ),
                const SizedBox(height: AppSizes.p24),
                AppButton(
                  title: _isEdit ? 'Save Changes' : 'Create Category',
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