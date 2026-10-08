import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/utils/image_url.dart';
import 'package:jewel_ora/core/widgets/app_loader.dart';
import 'package:jewel_ora/screens/user/image_viewer_screen.dart';

class ProductImageSlider extends StatefulWidget {
  final List<String> images;
  const ProductImageSlider({super.key, required this.images});

  @override
  State<ProductImageSlider> createState() => _ProductImageSliderState();
}

class _ProductImageSliderState extends State<ProductImageSlider> {
  final _pageCtrl = PageController();
  int _current = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _openViewer(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ImageViewerScreen(images: widget.images, initialIndex: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;

    if (images.isEmpty) {
      return AspectRatio(
        aspectRatio: 1,
        child: Container(
          color: AppColors.primaryLight.withValues(alpha: 0.3),
          child: const Center(
            child: Icon(Icons.diamond_outlined, size: 56, color: AppColors.primary),
          ),
        ),
      );
    }

    // The admin may remove images while the screen is open.
    final active = _current < images.length ? _current : 0;

    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageCtrl,
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, i) => GestureDetector(
              onTap: () => _openViewer(i),
              child: Container(
                color: const Color(0xFFFBF9F5),
                child: CachedNetworkImage(
                  imageUrl: ImageUrl.optimized(images[i], width: 900),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                    child: const Center(child: AppLoader(size: 40)),
                  ),
                  errorWidget: (context, url, error) =>
                      const Center(child: Icon(Icons.broken_image_outlined, size: 40)),
                ),
              ),
            ),
          ),

          // Counter, top right
          if (images.length > 1)
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${active + 1}/${images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          // Zoom hint, bottom right
          Positioned(
            bottom: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.zoom_out_map_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),

          // Dots, bottom center
          if (images.length > 1)
            Positioned(
              bottom: 14,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < images.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 5,
                      width: i == active ? 22 : 6,
                      decoration: BoxDecoration(
                        color: i == active ? AppColors.primary : Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}