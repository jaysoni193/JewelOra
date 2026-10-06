import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/utils/validators.dart';
import 'package:jewel_ora/core/widgets/app_text_field.dart';
import 'package:jewel_ora/core/widgets/primary_button.dart';
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
      showAppSnackBar(context, 'Please choose a category image',
          isError: true);
      return;
    }

    final provider = context.read<CategoryProvider>();
    final name = _nameCtrl.text.trim();

    if (provider.nameExists(name, excludeId: widget.category?.id)) {
      showAppSnackBar(context, 'A category with this name already exists',
          isError: true);
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
      showAppSnackBar(
          context, _isEdit ? 'Category updated' : 'Category added');
      Navigator.of(context).pop();
    } else {
      showAppSnackBar(
        context,
        provider.errorMessage ?? AppStrings.somethingWentWrong,
        isError: true,
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
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SingleImageUploader(
                  label: 'Category image',
                  initialUrl: _imageUrl,
                  folder: 'jewel_ora/categories',
                  onUploaded: (url) => _imageUrl = url,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: _nameCtrl,
                  label: 'Category name (e.g. Ring)',
                  prefixIcon: Icons.category_outlined,
                  validator: (v) => Validators.required(v, 'Name'),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Visible to customers'),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  text: _isEdit ? 'Save Changes' : 'Add Category',
                  isLoading: isSaving,
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