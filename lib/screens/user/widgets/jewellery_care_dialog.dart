import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/widgets/app_bottom_sheet.dart';

class JewelleryCareSheet extends StatelessWidget {
  const JewelleryCareSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show(
      context,
      child: const JewelleryCareSheet(),
    );
  }

  List<(String, IconData, Color, String)> _getTips() => [
    (
      AppStrings.careGoldTitle,
      Icons.auto_awesome_rounded,
      AppColors.primary,
      AppStrings.careGoldDesc,
    ),
    (
      AppStrings.careDiamondsTitle,
      Icons.diamond_outlined,
      AppColors.violet,
      AppStrings.careDiamondsDesc,
    ),
    (
      AppStrings.careSilverTitle,
      Icons.shield_outlined,
      AppColors.accentTeal,
      AppStrings.careSilverDesc,
    ),
    (
      AppStrings.careDailyWearTitle,
      Icons.inventory_2_outlined,
      AppColors.accentCoral,
      AppStrings.careDailyWearDesc,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tips = _getTips();

    return CommonBottomSheetContainer(
      title: AppStrings.jewelleryCare,
      subtitle: AppStrings.jewelleryCareSubtitle,
      icon: Icons.auto_awesome_rounded,
      child: Column(
        children: [
          for (int i = 0; i < tips.length; i++) ...[
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
                      color: tips[i].$3.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(tips[i].$2,
                        size: 20, color: tips[i].$3),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tips[i].$1,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tips[i].$4,
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
    );
  }
}

typedef JewelleryCareDialog = JewelleryCareSheet;
