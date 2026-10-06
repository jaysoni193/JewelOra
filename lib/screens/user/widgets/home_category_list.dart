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
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, i) {
          final c = categories[i];
          return InkWell(
            borderRadius: BorderRadius.circular(40),
            onTap: () => onTap(c),
            child: SizedBox(
              width: 72,
              child: Column(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 1.5),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ClipOval(
                      child: c.imageUrl.isEmpty
                          ? Container(
                        color: AppColors.primaryLight,
                        child: const Icon(Icons.diamond_outlined),
                      )
                          : CachedNetworkImage(
                        imageUrl:
                        ImageUrl.optimized(c.imageUrl, width: 200),
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                        const Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    c.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500),
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