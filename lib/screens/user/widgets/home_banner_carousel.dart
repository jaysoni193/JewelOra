import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/utils/image_url.dart';
import 'package:jewel_ora/models/banner_model.dart';

class HomeBannerCarousel extends StatefulWidget {
  final List<BannerModel> banners;
  const HomeBannerCarousel({super.key, required this.banners});

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final banners = widget.banners;
    if (banners.isEmpty) return const SizedBox.shrink();

    // The admin may delete banners while the app is open.
    final active = _current < banners.length ? _current : 0;

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            aspectRatio: 16 / 7.5,
            viewportFraction: 0.92,
            enlargeCenterPage: true,
            enlargeFactor: 0.15,
            autoPlay: banners.length > 1,
            autoPlayInterval: const Duration(seconds: 4),
            onPageChanged: (i, reason) => setState(() => _current = i),
          ),
          items: [for (final b in banners) _BannerItem(banner: b)],
        ),
        if (banners.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < banners.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 5,
                  width: i == active ? 22 : 6,
                  decoration: BoxDecoration(
                    color: i == active ? AppColors.primary : AppColors.borderAccent.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _BannerItem extends StatelessWidget {
  final BannerModel banner;
  const _BannerItem({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: ImageUrl.optimized(banner.imageUrl, width: 900),
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Container(color: AppColors.primaryLight.withValues(alpha: 0.5)),
              errorWidget: (context, url, error) =>
                  const Center(child: Icon(Icons.broken_image_outlined)),
            ),
            if (banner.title.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 28, 14, 12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                  child: Text(
                    banner.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}