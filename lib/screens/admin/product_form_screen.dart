import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/constants/product_options.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/utils/validators.dart';
import 'package:jewel_ora/core/widgets/app_text_field.dart';
import 'package:jewel_ora/core/widgets/multi_image_uploader.dart';
import 'package:jewel_ora/core/widgets/primary_button.dart';
import 'package:jewel_ora/models/product_model.dart';
import 'package:jewel_ora/providers/category_provider.dart';
import 'package:jewel_ora/providers/product_provider.dart';
import 'package:provider/provider.dart';

class ProductFormScreen extends StatefulWidget {
  /// null = add mode, otherwise edit mode.
  final ProductModel? product;
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _weightCtrl;

  late List<String> _images;
  String? _categoryId;
  String? _material;
  late bool _isAvailable;
  late bool _isFeatured;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _priceCtrl = TextEditingController(
      text: p == null
          ? ''
          : (p.price == p.price.roundToDouble()
          ? p.price.toInt().toString()
          : p.price.toString()),
    );
    _weightCtrl = TextEditingController(text: p?.weight ?? '');
    _images = List.of(p?.images ?? []);
    _categoryId = p?.categoryId;
    _material = (p?.material.isNotEmpty ?? false) ? p!.material : null;
    _isAvailable = p?.isAvailable ?? true;
    _isFeatured = p?.isFeatured ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    if (_images.isEmpty) {
      showAppSnackBar(context, 'Please add at least one image', isError: true);
      return;
    }

    final categories = context.read<CategoryProvider>().categories;
    final category = categories.where((c) => c.id == _categoryId).firstOrNull;
    if (category == null) {
      showAppSnackBar(context, 'Please select a category', isError: true);
      return;
    }

    final provider = context.read<ProductProvider>();
    final ok = await provider.save(
      existing: widget.product,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      price: double.parse(_priceCtrl.text.trim()),
      categoryId: category.id,
      categoryName: category.name,
      images: _images,
      material: _material ?? '',
      weight: _weightCtrl.text.trim(),
      isAvailable: _isAvailable,
      isFeatured: _isFeatured,
    );

    if (!mounted) return;
    if (ok) {
      showAppSnackBar(context, _isEdit ? 'Product updated' : 'Product added');
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
    final isSaving = context.watch<ProductProvider>().isSaving;
    final categories = context.watch<CategoryProvider>().categories;

    // If an old product has a material that is not in our list, still show it.
    final materials = [
      ...ProductOptions.materials,
      if (_material != null && !ProductOptions.materials.contains(_material))
        _material!,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Product' : 'Add Product')),
      body: SafeArea(
        child: categories.isEmpty
            ? const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text(
              'Please create at least one category first '
                  '(Admin Panel → Categories).',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGrey),
            ),
          ),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MultiImageUploader(
                  label: 'Product images',
                  initialUrls: _images,
                  maxImages: ProductOptions.maxImages,
                  onChanged: (urls) => _images = urls,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: _nameCtrl,
                  label: 'Product name',
                  prefixIcon: Icons.diamond_outlined,
                  validator: (v) => Validators.required(v, 'Name'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _categoryId,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: [
                    for (final c in categories)
                      DropdownMenuItem(
                        value: c.id,
                        child: Text(
                            c.isActive ? c.name : '${c.name} (hidden)'),
                      ),
                  ],
                  onChanged: (v) => setState(() => _categoryId = v),
                  validator: (v) =>
                  v == null ? 'Select a category' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _priceCtrl,
                  label: 'Price (₹)',
                  prefixIcon: Icons.currency_rupee,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  validator: Validators.price,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _material,
                  decoration: const InputDecoration(
                    labelText: 'Material',
                    prefixIcon: Icon(Icons.auto_awesome_outlined),
                  ),
                  items: [
                    for (final m in materials)
                      DropdownMenuItem(value: m, child: Text(m)),
                  ],
                  onChanged: (v) => setState(() => _material = v),
                  validator: (v) =>
                  v == null ? 'Select a material' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _weightCtrl,
                  label: 'Weight (e.g. 5.2 g)',
                  prefixIcon: Icons.scale_outlined,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _descCtrl,
                  label: 'Description',
                  prefixIcon: Icons.notes_outlined,
                  maxLines: 4,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Available'),
                  subtitle:
                  const Text('Turn off to show as out of stock'),
                  value: _isAvailable,
                  onChanged: (v) => setState(() => _isAvailable = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Featured'),
                  subtitle: const Text('Shown on the home screen'),
                  value: _isFeatured,
                  onChanged: (v) => setState(() => _isFeatured = v),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  text: _isEdit ? 'Save Changes' : 'Add Product',
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