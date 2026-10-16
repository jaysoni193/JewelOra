import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/widgets/app_bottom_sheet.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/app_dropdown.dart';
import 'package:jewel_ora/core/widgets/app_text_field.dart';
import 'package:jewel_ora/providers/category_provider.dart';
import 'package:jewel_ora/providers/product_provider.dart';
import 'package:provider/provider.dart';

class BulkPriceDialog extends StatefulWidget {
  const BulkPriceDialog({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show(
      context,
      child: const BulkPriceDialog(),
    );
  }

  @override
  State<BulkPriceDialog> createState() => _BulkPriceDialogState();
}

class _BulkPriceDialogState extends State<BulkPriceDialog> {
  final _percentCtrl = TextEditingController(text: '5');
  String? _selectedCategory; // null = all
  bool _isIncreasing = true;
  bool _isProcessing = false;

  @override
  void dispose() {
    _percentCtrl.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    final raw = double.tryParse(_percentCtrl.text.trim());
    if (raw == null || raw <= 0 || raw > 100) {
      showAppSnackBar(context, 'Please enter a valid percentage between 1 and 100', isError: true);
      return;
    }

    final percentage = _isIncreasing ? raw : -raw;

    setState(() => _isProcessing = true);
    final count = await context.read<ProductProvider>().bulkUpdatePrices(
      percentage: percentage,
      categoryId: _selectedCategory,
    );
    if (!mounted) return;
    setState(() => _isProcessing = false);

    Navigator.pop(context);
    showAppSnackBar(
      context,
      count > 0
          ? 'Updated prices for $count pieces (${percentage > 0 ? '+$percentage' : '$percentage'}%)'
          : 'No products matched the filter criteria',
      isError: count == 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;
    final products = context.watch<ProductProvider>().products;

    final affected = products.where((p) {
      if (_selectedCategory != null && p.categoryId != _selectedCategory) return false;
      return true;
    }).length;

    return CommonBottomSheetContainer(
      title: AppStrings.bulkPriceAdjustment,
      subtitle: AppStrings.bulkPriceSubtitle,
      icon: Icons.price_change_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Direction Toggle: Increase / Decrease
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _isIncreasing = true),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _isIncreasing ? AppColors.accentTealLight : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _isIncreasing ? AppColors.accentTeal : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_upward_rounded, size: 16, color: _isIncreasing ? AppColors.accentTeal : AppColors.textGrey),
                        const SizedBox(width: 6),
                        Text(
                          AppStrings.increase,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: _isIncreasing ? AppColors.accentTeal : AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _isIncreasing = false),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: !_isIncreasing ? AppColors.accentCoralLight : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: !_isIncreasing ? AppColors.accentCoral : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_downward_rounded, size: 16, color: !_isIncreasing ? AppColors.accentCoral : AppColors.textGrey),
                        const SizedBox(width: 6),
                        Text(
                          AppStrings.discount,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: !_isIncreasing ? AppColors.accentCoral : AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Percentage Input
          AppTextField(
            controller: _percentCtrl,
            label: AppStrings.adjustmentPercentage,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Icons.percent_rounded,
            hintText: 'e.g. 5 or 10',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),

          // Category Filter Dropdown
          AppDropdown<String?>(
            label: AppStrings.targetCategory,
            value: _selectedCategory,
            items: [
              DropdownMenuItem(value: null, child: Text(AppStrings.allCategories)),
              for (final c in categories)
                DropdownMenuItem(value: c.id, child: Text(c.name)),
            ],
            onChanged: (v) => setState(() => _selectedCategory = v),
          ),
          const SizedBox(height: 16),

          // Live Impact Summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderAccent),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This will adjust prices for $affected piece${affected == 1 ? '' : 's'} by ${_isIncreasing ? '+' : '-'}${_percentCtrl.text}%.',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          AppButton(
            title: AppStrings.applyBulkPrice,
            isLoading: _isProcessing,
            onPressed: _apply,
          ),
        ],
      ),
    );
  }
}
