import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/utils/image_url.dart';
import 'package:jewel_ora/models/category_model.dart';

class HomeCategoryList extends StatelessWidget {
  final List<CategoryModel> categories;
  final ValueChanged<CategoryModel> onTap;

  const HomeCategoryList({
    super.key,
    required this.categories,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final c = categories[i];
          return InkWell(
            borderRadius: BorderRadius.circular(40),
            onTap: () => onTap(c),
            child: SizedBox(
              width: 76,
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.borderAccent,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(2.5),
                    child: ClipOval(
                      child: c.imageUrl.isEmpty
                          ? Container(
                              color: AppColors.primaryLight,
                              child: const Icon(
                                Icons.diamond_outlined,
                                color: AppColors.primary,
                                size: 26,
                              ),
                            )
                          : CachedNetworkImage(
                              imageUrl: ImageUrl.optimized(c.imageUrl, width: 200),
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppColors.surfaceVariant,
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppColors.primaryLight,
                                child: const Icon(
                                  Icons.diamond_outlined,
                                  color: AppColors.primaryDark,
                                  size: 26,
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    c.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}