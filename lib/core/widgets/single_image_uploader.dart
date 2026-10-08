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

class SingleImageUploader extends StatefulWidget {
  final String label;
  final String initialUrl;
  final String folder;
  final double height;
  final BoxFit fit;
  final ValueChanged<String> onUploaded;

  const SingleImageUploader({
    super.key,
    required this.label,
    required this.onUploaded,
    this.initialUrl = '',
    this.folder = 'jewel_ora',
    this.fit = BoxFit.cover,
    this.height = 160,
  });

  @override
  State<SingleImageUploader> createState() => _SingleImageUploaderState();
}

class _SingleImageUploaderState extends State<SingleImageUploader> {
  final _picker = ImagePickerService();
  final _cloudinary = CloudinaryService();

  late String _url = widget.initialUrl;
  bool _uploading = false;

  Future<void> _pickAndUpload() async {
    final file = await _picker.pickOne();
    if (file == null) return;

    setState(() => _uploading = true);
    try {
      final url = await _cloudinary.uploadImage(file, folder: widget.folder);
      if (!mounted) return;
      setState(() => _url = url);
      widget.onUploaded(url);
    } on UploadException catch (e) {
      if (mounted) showAppSnackBar(context, e.message, isError: true);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          onTap: _uploading ? null : _pickAndUpload,
          child: Container(
            height: widget.height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              border: Border.all(
                color: _url.isNotEmpty ? AppColors.borderGold : AppColors.border,
                width: 1.2,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: _uploading
                ? const Center(child: AppLoader(size: 40))
                : _url.isEmpty
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 40,
                            color: AppColors.primary,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap to choose image',
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : CachedNetworkImage(
                        imageUrl: ImageUrl.optimized(_url, width: 800),
                        fit: widget.fit,
                        placeholder: (context, url) =>
                            const Center(child: AppLoader(size: 36)),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.broken_image_outlined),
                      ),
          ),
        ),
        if (_url.isNotEmpty && !_uploading)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: TextButton.icon(
              onPressed: _pickAndUpload,
              icon: const Icon(Icons.swap_horiz_rounded, size: 18),
              label: const Text('Change Image'),
            ),
          ),
      ],
    );
  }
}