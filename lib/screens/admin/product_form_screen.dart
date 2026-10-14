import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/constants/product_options.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/utils/validators.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/app_card.dart';
import 'package:jewel_ora/core/widgets/app_dropdown.dart';
import 'package:jewel_ora/core/widgets/app_text_field.dart';
import 'package:jewel_ora/core/widgets/multi_image_uploader.dart';
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
  late final TextEditingController _mrpCtrl;
  late final TextEditingController _offerTagCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _sizesCtrl;
  late final TextEditingController _metalWeightCtrl;
  late final TextEditingController _makingChargesCtrl;

  late List<String> _images;
  String? _categoryId;
  String? _material;
  String? _metalType;
  late bool _useDynamicRate;
  late bool _isAvailable;
  late bool _isFeatured;

  bool get _isEdit => widget.product != null;

  static const _suggestedOfferTags = [
    'Diwali Sale',
    'Festive Offer',
    'Flat 15% Off',
    'Akshaya Tritiya',
    'Wedding Special',
    'Limited Edition',
  ];

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
    _mrpCtrl = TextEditingController(
      text: p?.mrp == null
          ? ''
          : (p!.mrp == p.mrp!.roundToDouble()
              ? p.mrp!.toInt().toString()
              : p.mrp.toString()),
    );
    _offerTagCtrl = TextEditingController(text: p?.offerTag ?? '');
    _weightCtrl = TextEditingController(text: p?.weight ?? '');
    _sizesCtrl = TextEditingController(text: p?.availableSizes.join(', ') ?? '');
    _metalWeightCtrl = TextEditingController(
      text: p?.metalWeight != null ? p!.metalWeight.toString() : '',
    );
    _makingChargesCtrl = TextEditingController(
      text: p?.makingCharges != null ? p!.makingCharges.toString() : '',
    );

    _images = List.of(p?.images ?? []);
    _categoryId = p?.categoryId;
    _material = (p?.material.isNotEmpty ?? false) ? p!.material : null;
    _metalType = p?.metalType;
    _useDynamicRate = p?.useDynamicRate ?? false;
    _isAvailable = p?.isAvailable ?? true;
    _isFeatured = p?.isFeatured ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _mrpCtrl.dispose();
    _offerTagCtrl.dispose();
    _weightCtrl.dispose();
    _sizesCtrl.dispose();
    _metalWeightCtrl.dispose();
    _makingChargesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    if (_images.isEmpty) {
      showAppSnackBar(context, 'Please add at least one product image', isError: true);
      return;
    }

    final categories = context.read<CategoryProvider>().categories;
    final category = categories.where((c) => c.id == _categoryId).firstOrNull;
    if (category == null) {
      showAppSnackBar(context, 'Please select a category', isError: true);
      return;
    }

    final mrpVal = double.tryParse(_mrpCtrl.text.trim());
    final metalWeightVal = double.tryParse(_metalWeightCtrl.text.trim());
    final makingChargesVal = double.tryParse(_makingChargesCtrl.text.trim());
    final sizesList = _sizesCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final provider = context.read<ProductProvider>();
    final ok = await provider.save(
      existing: widget.product,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      price: double.parse(_priceCtrl.text.trim()),
      mrp: mrpVal,
      offerTag: _offerTagCtrl.text.trim().isEmpty ? null : _offerTagCtrl.text.trim(),
      metalType: _metalType,
      metalWeight: metalWeightVal,
      makingCharges: makingChargesVal,
      useDynamicRate: _useDynamicRate,
      categoryId: category.id,
      categoryName: category.name,
      images: _images,
      material: _material ?? '',
      weight: _weightCtrl.text.trim(),
      isAvailable: _isAvailable,
      isFeatured: _isFeatured,
      availableSizes: sizesList,
    );

    if (!mounted) return;
    if (ok) {
      showAppSnackBar(context, _isEdit ? 'Piece updated successfully' : 'Piece added successfully');
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

    final materials = [
      ...ProductOptions.materials,
      if (_material != null && !ProductOptions.materials.contains(_material))
        _material!,
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_isEdit ? 'Edit Piece' : 'Add New Piece')),
      body: SafeArea(
        child: categories.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Please create at least one category first\n(Admin Console → Categories).',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textGrey, height: 1.4),
                  ),
                ),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Product Gallery Card
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: MultiImageUploader(
                          label: 'Product Images',
                          initialUrls: _images,
                          maxImages: ProductOptions.maxImages,
                          onChanged: (urls) => _images = urls,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Basic Details Card
                      AppCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Basic Details',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _nameCtrl,
                              label: 'Product Name',
                              prefixIcon: Icons.diamond_outlined,
                              validator: (v) => Validators.required(v, 'Name'),
                            ),
                            const SizedBox(height: 16),
                            AppDropdown<String>(
                              label: 'Category',
                              value: _categoryId,
                              prefixIcon: Icons.category_outlined,
                              items: [
                                for (final c in categories)
                                  DropdownMenuItem(value: c.id, child: Text(c.name)),
                              ],
                              onChanged: (v) => setState(() => _categoryId = v),
                              validator: (v) => v == null ? 'Select a category' : null,
                            ),
                            const SizedBox(height: 16),
                            AppDropdown<String>(
                              label: 'Material',
                              value: _material,
                              prefixIcon: Icons.auto_awesome_outlined,
                              items: [
                                for (final m in materials)
                                  DropdownMenuItem(value: m, child: Text(m)),
                              ],
                              onChanged: (v) => setState(() => _material = v),
                              validator: (v) => v == null ? 'Select a material' : null,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _weightCtrl,
                              label: 'Gross Weight (e.g. 5.2 g, 18 Karat)',
                              prefixIcon: Icons.scale_outlined,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _sizesCtrl,
                              label: 'Available Sizes (comma separated, optional)',
                              hintText: 'e.g. 12, 14, 16, 18 or 2.4, 2.6, 2.8',
                              prefixIcon: Icons.straighten_rounded,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _descCtrl,
                              label: 'Description',
                              prefixIcon: Icons.notes_outlined,
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Pricing, Offers & Discounts Card
                      AppCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.local_offer_outlined, color: AppColors.primary, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Pricing & Festive Offers',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _priceCtrl,
                              label: 'Selling Price (₹)',
                              hintText: 'e.g. 11999',
                              prefixIcon: Icons.currency_rupee_rounded,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: Validators.price,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _mrpCtrl,
                              label: 'Original MRP (₹, optional for strikethrough)',
                              hintText: 'e.g. 14999 (leave blank if no discount)',
                              prefixIcon: Icons.money_off_rounded,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _offerTagCtrl,
                              label: 'Offer / Festive Tag (optional)',
                              hintText: 'e.g. Diwali Sale, Flat 20% Off',
                              prefixIcon: Icons.local_fire_department_rounded,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                for (final tag in _suggestedOfferTags)
                                  InkWell(
                                    onTap: () => setState(() => _offerTagCtrl.text = tag),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight.withValues(alpha: 0.6),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: AppColors.borderAccent),
                                      ),
                                      child: Text(
                                        '+ $tag',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Dynamic Live Metal Pricing Card
                      AppCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              activeThumbColor: AppColors.primary,
                              activeTrackColor: AppColors.primaryLight,
                              title: const Text(
                                'Calculate Price from Daily Metal Rate',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              subtitle: const Text(
                                'Automatically updates price as daily gold/silver rates fluctuate',
                                style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                              ),
                              value: _useDynamicRate,
                              onChanged: (v) => setState(() => _useDynamicRate = v),
                            ),
                            if (_useDynamicRate) ...[
                              const Divider(height: 20),
                              AppDropdown<String>(
                                label: 'Metal Type',
                                value: _metalType,
                                prefixIcon: Icons.monetization_on_outlined,
                                items: const [
                                  DropdownMenuItem(value: 'gold_24k', child: Text('24K Pure Gold')),
                                  DropdownMenuItem(value: 'gold_22k', child: Text('22K Standard Gold')),
                                  DropdownMenuItem(value: 'gold_18k', child: Text('18K Diamond Gold')),
                                  DropdownMenuItem(value: 'silver', child: Text('Fine Silver')),
                                ],
                                onChanged: (v) => setState(() => _metalType = v),
                              ),
                              const SizedBox(height: 14),
                              AppTextField(
                                controller: _metalWeightCtrl,
                                label: 'Net Metal Weight (Grams)',
                                hintText: 'e.g. 3.45',
                                prefixIcon: Icons.scale_rounded,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                              const SizedBox(height: 14),
                              AppTextField(
                                controller: _makingChargesCtrl,
                                label: 'Making Charges / Wastage (₹)',
                                hintText: 'e.g. 1500',
                                prefixIcon: Icons.add_circle_outline,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Availability & Display settings
                      AppCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          children: [
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              activeThumbColor: AppColors.primary,
                              activeTrackColor: AppColors.primaryLight,
                              title: const Text(
                                'Available in Stock',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              subtitle: const Text(
                                'Turn off to mark as out of stock',
                                style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                              ),
                              value: _isAvailable,
                              onChanged: (v) => setState(() => _isAvailable = v),
                            ),
                            const Divider(height: 1),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              activeThumbColor: AppColors.primary,
                              activeTrackColor: AppColors.primaryLight,
                              title: const Text(
                                'Featured in Boutique Showcase',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              subtitle: const Text(
                                'Prominently highlighted on customer home screen',
                                style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                              ),
                              value: _isFeatured,
                              onChanged: (v) => setState(() => _isFeatured = v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      AppButton(
                        title: _isEdit ? 'Save Changes' : 'Add to Collection',
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