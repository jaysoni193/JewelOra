import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/errors/upload_exception.dart';
import 'package:jewel_ora/core/utils/image_url.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/widgets/app_loader.dart';
import 'package:jewel_ora/services/cloudinary_service.dart';
import 'package:jewel_ora/services/image_picker_service.dart';

class MultiImageUploader extends StatefulWidget {
  final String label;
  final List<String> initialUrls;
  final String folder;
  final int maxImages;
  final ValueChanged<List<String>> onChanged;

  const MultiImageUploader({
    super.key,
    required this.onChanged,
    this.label = 'Images',
    this.initialUrls = const [],
    this.folder = 'jewel_ora/products',
    this.maxImages = 5,
  });

  @override
  State<MultiImageUploader> createState() => _MultiImageUploaderState();
}

class _MultiImageUploaderState extends State<MultiImageUploader> {
  final _picker = ImagePickerService();
  final _cloudinary = CloudinaryService();

  late final List<String> _urls = List.of(widget.initialUrls);
  bool _uploading = false;

  Future<void> _addImages() async {
    final remaining = widget.maxImages - _urls.length;
    if (remaining <= 0) return;

    final files = await _picker.pickMany();
    if (files.isEmpty) return;

    final selected = files.take(remaining).toList();
    if (files.length > remaining && mounted) {
      showAppSnackBar(
        context,
        'Maximum ${widget.maxImages} images. Extra ones were skipped.',
        isError: true,
      );
    }

    setState(() => _uploading = true);
    for (final file in selected) {
      try {
        final url = await _cloudinary.uploadImage(file, folder: widget.folder);
        if (!mounted) return;
        setState(() => _urls.add(url));
        widget.onChanged(List.of(_urls));
      } on UploadException catch (e) {
        if (mounted) showAppSnackBar(context, e.message, isError: true);
        break;
      }
    }
    if (mounted) setState(() => _uploading = false);
  }

  void _remove(int index) {
    setState(() => _urls.removeAt(index));
    widget.onChanged(List.of(_urls));
  }

  void _makeCover(int index) {
    if (index == 0) return;
    setState(() {
      final url = _urls.removeAt(index);
      _urls.insert(0, url);
    });
    widget.onChanged(List.of(_urls));
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = _urls.length < widget.maxImages && !_uploading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            Text(
              '${_urls.length}/${widget.maxImages}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'First image is the cover. Tap another image to make it the cover.',
          style: TextStyle(fontSize: 12, color: AppColors.textGrey),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (var i = 0; i < _urls.length; i++)
                _Thumb(
                  url: _urls[i],
                  isCover: i == 0,
                  onTap: () => _makeCover(i),
                  onRemove: () => _remove(i),
                ),
              if (_uploading)
                const _BoxShell(
                  child: Center(
                    child: AppLoader(size: 32),
                  ),
                ),
              if (canAdd)
                InkWell(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  onTap: _addImages,
                  child: const _BoxShell(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 28,
                          color: AppColors.primary,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Add Photo',
                          style: TextStyle(fontSize: 11, color: AppColors.textGrey),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BoxShell extends StatelessWidget {
  final Widget child;
  const _BoxShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: child,
    );
  }
}

class _Thumb extends StatelessWidget {
  final String url;
  final bool isCover;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _Thumb({
    required this.url,
    required this.isCover,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(
                  color: isCover ? AppColors.primary : AppColors.border,
                  width: isCover ? 2 : 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                imageUrl: ImageUrl.optimized(url, width: 250),
                fit: BoxFit.cover,
                errorWidget: (context, imageUrl, error) =>
                    const Icon(Icons.broken_image_outlined),
              ),
            ),
          ),
          if (isCover)
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'COVER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          Positioned(
            right: 4,
            top: 4,
            child: InkWell(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}