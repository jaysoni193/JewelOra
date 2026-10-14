import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';

class JewelleryCareSheet extends StatelessWidget {
  const JewelleryCareSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const JewelleryCareSheet(),
    );
  }

  static final _tips = <(String, IconData, Color, String)>[
    (
      'Gold & Platinum Care',
      Icons.auto_awesome_rounded,
      AppColors.primary,
      'Clean gently using lukewarm water and mild baby shampoo with a soft-bristled brush. Avoid chlorine from swimming pools, bleach, and harsh detergents that can erode prongs.',
    ),
    (
      'Diamonds & Gemstones',
      Icons.diamond_outlined,
      AppColors.violet,
      'Diamonds attract body oils and lotion. Soak for 15 minutes in mild soapy water once a month, then pat dry with a lint-free microfiber cloth. Avoid ultrasonic cleaners for emeralds and pearls.',
    ),
    (
      '925 Sterling Silver',
      Icons.shield_outlined,
      AppColors.accentTeal,
      'Silver naturally oxidizes when exposed to sulfur in ambient air. Store pieces in airtight zip pouches with anti-tarnish strips. Never spray perfume directly onto silver jewellery.',
    ),
    (
      'Daily Wear & Safe Storage',
      Icons.inventory_2_outlined,
      AppColors.accentCoral,
      'Remember the golden rule: Jewellery should be the last thing you put on when dressing, and the first thing you take off. Store each piece separately in velvet-lined slots to prevent scratches.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 12, 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.jewelleryCare,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          AppStrings.jewelleryCareSubtitle,
                          style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textGrey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Content
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  for (int i = 0; i < _tips.length; i++) ...[
                    if (i > 0) const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _tips[i].$3.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(_tips[i].$2,
                                size: 20, color: _tips[i].$3),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _tips[i].$1,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _tips[i].$4,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}

typedef JewelleryCareDialog = JewelleryCareSheet;
