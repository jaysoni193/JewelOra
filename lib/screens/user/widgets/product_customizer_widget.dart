import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/widgets/app_card.dart';
import 'package:jewel_ora/models/metal_rate_model.dart';
import 'package:jewel_ora/models/product_model.dart';
import 'package:jewel_ora/screens/user/widgets/diamond_guide_sheet.dart';

class ProductCustomizerHelper {
  ProductCustomizerHelper._();

  static bool hasDiamonds(ProductModel p) {
    final lower = '${p.name} ${p.material} ${p.categoryName} ${p.description}'.toLowerCase();
    return lower.contains('diamond') || lower.contains('solitaire') || lower.contains('stone');
  }

  static bool isSilver(ProductModel p) {
    final lower = '${p.name} ${p.material} ${p.categoryName} ${p.metalType}'.toLowerCase();
    return lower.contains('silver') || p.metalType == 'silver';
  }

  static double calculateCustomPrice({
    required ProductModel product,
    required MetalRateModel rates,
    required String selectedPurity,
    required String selectedDiamondType,
  }) {
    double price;

    if (product.useDynamicRate && product.metalWeight != null) {
      double ratePerGram;
      switch (selectedPurity) {
        case '24K':
          ratePerGram = rates.gold24k;
          break;
        case '22K':
          ratePerGram = rates.gold22k;
          break;
        case '18K':
          ratePerGram = rates.gold18k;
          break;
        case '14K':
          ratePerGram = rates.gold24k * (14.0 / 24.0);
          break;
        case '925 Silver':
          ratePerGram = rates.silver1g;
          break;
        default:
          ratePerGram = rates.gold18k;
      }
      final metalCost = ratePerGram * product.metalWeight!;
      price = metalCost + (product.makingCharges ?? 0.0);
    } else {
      if (isSilver(product)) {
        price = product.price;
      } else {
        final baseKarat = product.metalType == 'gold_22k'
            ? 22.0
            : (product.metalType == 'gold_24k'
                ? 24.0
                : (product.metalType == 'gold_14k' ? 14.0 : 18.0));

        final selectedKarat = switch (selectedPurity) {
          '24K' => 24.0,
          '22K' => 22.0,
          '18K' => 18.0,
          '14K' => 14.0,
          _ => 18.0,
        };

        final ratio = selectedKarat / baseKarat;
        price = product.price * (0.35 + 0.65 * ratio);
      }
    }

    if (hasDiamonds(product)) {
      if (selectedDiamondType.contains('Lab-Grown')) {
        price *= 0.75; // 25% affordable for lab-grown CVD diamond
      } else if (selectedDiamondType.contains('VVS-GH')) {
        price *= 1.15; // 15% premium for VVS clarity
      }
    }

    return (price * 100).round() / 100.0;
  }
}

class ProductCustomizerWidget extends StatelessWidget {
  final ProductModel product;
  final MetalRateModel rates;
  final String selectedMetalTone;
  final String selectedPurity;
  final String selectedDiamondType;
  final ValueChanged<String> onMetalToneChanged;
  final ValueChanged<String> onPurityChanged;
  final ValueChanged<String> onDiamondTypeChanged;

  const ProductCustomizerWidget({
    super.key,
    required this.product,
    required this.rates,
    required this.selectedMetalTone,
    required this.selectedPurity,
    required this.selectedDiamondType,
    required this.onMetalToneChanged,
    required this.onPurityChanged,
    required this.onDiamondTypeChanged,
  });

  static const _goldTones = [
    ('Yellow Gold', Color(0xFFE5B869), '🟡'),
    ('Rose Gold', Color(0xFFE8A598), '🌸'),
    ('White Gold', Color(0xFFD6D6D6), '⚪'),
  ];

  static const _silverTones = [
    ('Sterling Silver', Color(0xFFE0E0E0), '✨'),
    ('Oxidised Silver', Color(0xFF757575), '🔘'),
    ('Rose Gold Polish', Color(0xFFE8A598), '🌸'),
  ];

  static const _goldPurities = [
    ('14K', '585 Hallmark', 'Dailywear Durability'),
    ('18K', '750 Hallmark', 'Luxury Diamond Setting'),
    ('22K', '916 BIS Hallmark', 'Traditional Rich Gold'),
  ];

  static const _diamondTypes = [
    ('Natural (SI-IJ)', 'Certified Natural', 'Real Earth Mined'),
    ('Natural (VVS-GH)', 'Top Brilliance (+15%)', 'Superior Fire & Clarity'),
    ('Lab-Grown (CVD)', 'Eco Luxury (-25% Off)', 'Identical Carbon Sparkle'),
  ];

  @override
  Widget build(BuildContext context) {
    final isSilverPiece = ProductCustomizerHelper.isSilver(product);
    final hasDiamonds = ProductCustomizerHelper.hasDiamonds(product);
    final tones = isSilverPiece ? _silverTones : _goldTones;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.tune_rounded, size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.customisePiece,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                    ),
                    const Text(
                      'Personalise metal colour, karat & diamonds',
                      style: TextStyle(fontSize: 11, color: AppColors.textGrey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt_rounded, size: 13, color: AppColors.primary),
                    SizedBox(width: 2),
                    Text(
                      'Live Rate',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 1. Metal Tone Selection (Yellow Gold, Rose Gold, White Gold)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.metalColor,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
              ),
              Text(
                selectedMetalTone,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: tones.map((tone) {
              final isSel = selectedMetalTone == tone.$1;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => onMetalToneChanged(tone.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                      decoration: BoxDecoration(
                        color: isSel ? AppColors.primaryLight : AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSel ? AppColors.primary : AppColors.border,
                          width: isSel ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: tone.$2,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            child: isSel
                                ? const Icon(Icons.check_rounded, size: 12, color: AppColors.primaryDark)
                                : null,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            tone.$1,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                              color: isSel ? AppColors.primary : AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // 2. Gold Karat / Purity Selector (14K, 18K, 22K)
          if (!isSilverPiece) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.purityKarat,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
                Text(
                  selectedPurity,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: _goldPurities.map((pur) {
                final isSel = selectedPurity == pur.$1;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => onPurityChanged(pur.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSel ? AppColors.primary : AppColors.border,
                            width: isSel ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              pur.$1,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isSel ? Colors.white : AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              pur.$2,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: isSel ? Colors.white70 : AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // 3. Diamond Quality (Natural SI-IJ vs Natural VVS-GH vs Lab-Grown CVD)
          if (hasDiamonds) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.diamondOption,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
                InkWell(
                  onTap: () => DiamondGuideSheet.show(context),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.diamond_outlined, size: 13, color: AppColors.accent),
                        const SizedBox(width: 4),
                        Text(
                          '${AppStrings.diamondGuide} ↗',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Column(
              children: _diamondTypes.map((dia) {
                final isSel = selectedDiamondType == dia.$1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => onDiamondTypeChanged(dia.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSel ? AppColors.accent.withValues(alpha: 0.08) : AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSel ? AppColors.accent : AppColors.border,
                          width: isSel ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSel ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                            size: 16,
                            color: isSel ? AppColors.accent : AppColors.textLight,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dia.$1,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                                    color: isSel ? AppColors.accent : AppColors.textDark,
                                  ),
                                ),
                                Text(
                                  dia.$3,
                                  style: const TextStyle(fontSize: 10, color: AppColors.textGrey),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSel ? AppColors.accent.withValues(alpha: 0.15) : AppColors.background,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              dia.$2,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isSel ? AppColors.accent : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
