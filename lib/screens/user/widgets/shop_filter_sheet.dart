import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/constants/product_options.dart';
import 'package:jewel_ora/core/utils/formatters.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/providers/shop_filter_provider.dart';
import 'package:provider/provider.dart';

class ShopFilterSheet extends StatefulWidget {
  final ShopFilterProvider? filter;
  const ShopFilterSheet({super.key, this.filter});

  static Future<void> show(BuildContext context) {
    final filter = context.read<ShopFilterProvider>();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: filter,
        child: ShopFilterSheet(filter: filter),
      ),
    );
  }

  @override
  State<ShopFilterSheet> createState() => _ShopFilterSheetState();
}

class _ShopFilterSheetState extends State<ShopFilterSheet> {
  late RangeValues _priceRange;
  late Set<String> _selectedMaterials;
  late bool _inStockOnly;

  static const double _minLimit = 0.0;
  static const double _maxLimit = 300000.0;

  ShopFilterProvider get _activeFilter =>
      widget.filter ?? context.read<ShopFilterProvider>();

  @override
  void initState() {
    super.initState();
    final filter = widget.filter ?? context.read<ShopFilterProvider>();
    _priceRange = RangeValues(
      filter.minPrice ?? _minLimit,
      filter.maxPrice ?? _maxLimit,
    );
    _selectedMaterials = Set.from(filter.materials);
    _inStockOnly = filter.inStockOnly;
  }

  void _apply() {
    final filter = _activeFilter;
    filter.setPriceRange(
      _priceRange.start > _minLimit ? _priceRange.start : null,
      _priceRange.end < _maxLimit ? _priceRange.end : null,
    );
    // Sync materials
    for (final m in ProductOptions.materials) {
      final wasActive = filter.materials.contains(m);
      final isNowActive = _selectedMaterials.contains(m);
      if (wasActive != isNowActive) {
        filter.toggleMaterial(m);
      }
    }
    filter.setInStockOnly(_inStockOnly);
    Navigator.pop(context);
  }

  void _reset() {
    setState(() {
      _priceRange = const RangeValues(_minLimit, _maxLimit);
      _selectedMaterials.clear();
      _inStockOnly = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

            // Sheet Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                TextButton(
                  onPressed: _reset,
                  child: const Text('Reset All'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 1. Price Range Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Price Range',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  '${Formatters.currency(_priceRange.start)} - ${Formatters.currency(_priceRange.end)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            RangeSlider(
              values: _priceRange,
              min: _minLimit,
              max: _maxLimit,
              divisions: 60,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.primaryLight,
              labels: RangeLabels(
                Formatters.currency(_priceRange.start),
                Formatters.currency(_priceRange.end),
              ),
              onChanged: (values) => setState(() => _priceRange = values),
            ),
            const SizedBox(height: 16),

            // 2. Material Chips
            const Text(
              'Material & Purity',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final material in ProductOptions.materials)
                  FilterChip(
                    label: Text(material),
                    selected: _selectedMaterials.contains(material),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedMaterials.add(material);
                        } else {
                          _selectedMaterials.remove(material);
                        }
                      });
                    },
                    selectedColor: AppColors.primaryLight,
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: _selectedMaterials.contains(material)
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: _selectedMaterials.contains(material)
                          ? AppColors.primaryDark
                          : AppColors.textDark,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // 3. In Stock Only Toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'In Stock Only',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        'Hide out of stock & made-to-order items',
                        style:
                            TextStyle(fontSize: 11, color: AppColors.textGrey),
                      ),
                    ],
                  ),
                  Switch.adaptive(
                    value: _inStockOnly,
                    activeTrackColor: AppColors.primary,
                    onChanged: (val) => setState(() => _inStockOnly = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Apply Button
            AppButton(
              title: 'Apply Filters',
              onPressed: _apply,
            ),
          ],
        ),
      ),
    ),
  );
}
}
