import 'dart:io';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/utils/formatters.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/app_loader.dart';
import 'package:jewel_ora/models/ar_try_on_model.dart';
import 'package:jewel_ora/models/product_model.dart';
import 'package:jewel_ora/providers/product_provider.dart';
import 'package:jewel_ora/screens/user/product_detail_screen.dart';
import 'package:jewel_ora/services/whatsapp_service.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class ArTryOnScreen extends StatefulWidget {
  final ArTryOnItem? initialItem;
  final ProductModel? initialProduct;

  const ArTryOnScreen({
    super.key,
    this.initialItem,
    this.initialProduct,
  });

  static Future<void> open(
    BuildContext context, {
    ArTryOnItem? item,
    ProductModel? product,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ArTryOnScreen(
          initialItem: item,
          initialProduct: product,
        ),
      ),
    );
  }

  @override
  State<ArTryOnScreen> createState() => _ArTryOnScreenState();
}

class _ArTryOnScreenState extends State<ArTryOnScreen> {
  // Camera state
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isCameraReady = false;
  bool _mirrorMode = true;

  // Uploaded photo fallback
  File? _userUploadedPhoto;

  // Selected Try-On item
  late ArTryOnItem _selectedItem;
  ArItemType _activeCategory = ArItemType.earrings;

  // Interactive transform state
  double _scale = 1.0;
  double _baseScale = 1.0;
  Offset _offset = Offset.zero;
  Offset _baseOffset = Offset.zero;
  double _rotation = 0.0;
  double _earSpacing = 160.0;
  bool _showGuide = true;

  @override
  void initState() {
    super.initState();
    _initInitialItem();
    _initCamera();
  }

  void _initInitialItem() {
    if (widget.initialItem != null) {
      _selectedItem = widget.initialItem!;
    } else if (widget.initialProduct != null) {
      _selectedItem = ArTryOnItem.fromProduct(widget.initialProduct!) ??
          ArTryOnItem.curatedItems.first;
    } else {
      _selectedItem = ArTryOnItem.curatedItems.first;
    }
    _activeCategory = _selectedItem.type;
    _resetItemTransforms();
  }

  void _resetItemTransforms() {
    setState(() {
      _scale = _selectedItem.defaultScale;
      _offset = Offset(_selectedItem.defaultOffsetX, _selectedItem.defaultOffsetY);
      _rotation = 0.0;
      _earSpacing = _selectedItem.earringSpacing;
    });
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _isCameraReady = false;
        });
        return;
      }

      // Default to front selfie camera
      final frontIndex = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );
      _selectedCameraIndex = frontIndex != -1 ? frontIndex : 0;

      await _setupCameraController(_cameras[_selectedCameraIndex]);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AR Camera Init Error]: $e');
      }
      if (mounted) {
        setState(() {
          _isCameraReady = false;
        });
      }
    }
  }

  Future<void> _setupCameraController(CameraDescription camera) async {
    await _cameraController?.dispose();
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _cameraController = controller;
    try {
      await controller.initialize();
      if (mounted) {
        setState(() {
          _isCameraReady = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCameraReady = false;
        });
      }
    }
  }

  Future<void> _toggleCamera() async {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _setupCameraController(_cameras[_selectedCameraIndex]);
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, maxWidth: 1200);
      if (picked != null && mounted) {
        setState(() {
          _userUploadedPhoto = File(picked.path);
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void _selectItem(ArTryOnItem item) {
    setState(() {
      _selectedItem = item;
      _activeCategory = item.type;
      _resetItemTransforms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera / Photo Viewport Layer
          _buildViewportLayer(size),

          // 2. AR Facial Alignment Guidelines (Gold Silhouette)
          if (_showGuide) _buildGuideOverlay(size),

          // 3. Virtual Jewellery Overlay Layer with Interactive Gestures
          _buildJewelleryOverlay(size),

          // 4. Top Floating Bar (Back, Camera Flip, Mirror, Upload, Guide toggle, Reset)
          _buildTopBar(context),

          // 5. Bottom Floating Jewellery Selector & Action Drawer
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomTryOnShelf(context),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // VIEWPORT LAYER (Camera / Photo / Luxury Fallback)
  // -------------------------------------------------------------

  Widget _buildViewportLayer(Size size) {
    if (_userUploadedPhoto != null) {
      return Image.file(
        _userUploadedPhoto!,
        fit: BoxFit.cover,
        width: size.width,
        height: size.height,
      );
    }

    if (_isCameraReady && _cameraController != null && _cameraController!.value.isInitialized) {
      final preview = CameraPreview(_cameraController!);
      return _mirrorMode
          ? Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(math.pi),
              child: preview,
            )
          : preview;
    }

    // Fallback luxury selfie studio canvas
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2C193D), Color(0xFF13091B), Colors.black],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.4)),
              ),
              child: const Icon(Icons.face_retouching_natural_rounded, color: AppColors.accentGold, size: 54),
            ),
            const SizedBox(height: 16),
            const Text(
              'Virtual Jewellery Mirror Studio',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Camera preview is unavailable. Upload or snap a photo of your face & neck to try on earrings and necklaces live.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusPill)),
                  ),
                  icon: const Icon(Icons.camera_alt_rounded, size: 18),
                  label: const Text('Take Selfie'),
                  onPressed: () => _pickPhoto(ImageSource.camera),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusPill)),
                  ),
                  icon: const Icon(Icons.photo_library_rounded, size: 18),
                  label: const Text('Upload Photo'),
                  onPressed: () => _pickPhoto(ImageSource.gallery),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // AR FACIAL ALIGNMENT GUIDE
  // -------------------------------------------------------------

  Widget _buildGuideOverlay(Size size) {
    return IgnorePointer(
      child: CustomPaint(
        size: size,
        painter: _ArFacialGuidePainter(
          earSpacing: _earSpacing,
          isEarring: _selectedItem.type == ArItemType.earrings,
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // VIRTUAL JEWELLERY OVERLAY LAYER
  // -------------------------------------------------------------

  Widget _buildJewelleryOverlay(Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onScaleStart: (details) {
        _baseScale = _scale;
        _baseOffset = _offset;
      },
      onScaleUpdate: (details) {
        setState(() {
          _scale = (_baseScale * details.scale).clamp(0.5, 2.5);
          _offset = _baseOffset + (details.focalPointDelta);
          if (details.rotation != 0) {
            _rotation += details.rotation * 0.05;
          }
        });
      },
      child: Stack(
        children: [
          if (_selectedItem.type == ArItemType.earrings) ...[
            // Left Earring
            Positioned(
              left: center.dx - (_earSpacing / 2) + _offset.dx - (40 * _scale),
              top: center.dy + _offset.dy - (40 * _scale),
              child: Transform.rotate(
                angle: _rotation,
                child: Transform.scale(
                  scale: _scale,
                  child: _buildEarringPiece(_selectedItem.imageUrl),
                ),
              ),
            ),
            // Right Earring (Mirrored for realistic pair draping)
            Positioned(
              left: center.dx + (_earSpacing / 2) + _offset.dx - (40 * _scale),
              top: center.dy + _offset.dy - (40 * _scale),
              child: Transform.rotate(
                angle: -_rotation,
                child: Transform.scale(
                  scale: _scale,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(math.pi),
                    child: _buildEarringPiece(_selectedItem.imageUrl),
                  ),
                ),
              ),
            ),
          ] else ...[
            // Necklace draped across collarbone
            Positioned(
              left: center.dx + _offset.dx - (140 * _scale),
              top: center.dy + _offset.dy - (60 * _scale),
              child: Transform.rotate(
                angle: _rotation,
                child: Transform.scale(
                  scale: _scale,
                  child: _buildNecklacePiece(_selectedItem.imageUrl),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEarringPiece(String imageUrl) {
    return Container(
      width: 80,
      height: 110,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppColors.accentGold.withValues(alpha: 0.25),
            blurRadius: 10,
          ),
        ],
      ),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain,
        placeholder: (context, url) => const Center(child: AppLoader(size: 24)),
        errorWidget: (context, url, error) => const Icon(Icons.diamond_outlined, color: AppColors.accentGold, size: 36),
      ),
    );
  }

  Widget _buildNecklacePiece(String imageUrl) {
    return Container(
      width: 280,
      height: 220,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: AppColors.accentGold.withValues(alpha: 0.2),
            blurRadius: 14,
          ),
        ],
      ),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain,
        placeholder: (context, url) => const Center(child: AppLoader(size: 32)),
        errorWidget: (context, url, error) => const Icon(Icons.diamond_outlined, color: AppColors.accentGold, size: 48),
      ),
    );
  }

  // -------------------------------------------------------------
  // TOP FLOATING CONTROL BAR
  // -------------------------------------------------------------

  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: Row(
        children: [
          // Close button
          _buildCircleIconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: 'Back',
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),

          // Active guide hint pill
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.touch_app_rounded, color: AppColors.accentGold, size: 15),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      AppStrings.dragToAdjust,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Flip Camera
          if (_cameras.length > 1)
            _buildCircleIconButton(
              icon: Icons.flip_camera_ios_rounded,
              tooltip: AppStrings.switchCamera,
              onTap: _toggleCamera,
            ),
          const SizedBox(width: 6),

          // Mirror Mode
          _buildCircleIconButton(
            icon: Icons.swap_horiz_rounded,
            tooltip: AppStrings.mirrorMode,
            isActive: _mirrorMode,
            onTap: () => setState(() => _mirrorMode = !_mirrorMode),
          ),
          const SizedBox(width: 6),

          // Upload photo
          _buildCircleIconButton(
            icon: Icons.photo_library_outlined,
            tooltip: AppStrings.uploadPhoto,
            onTap: () => _pickPhoto(ImageSource.gallery),
          ),
          const SizedBox(width: 6),

          // Toggle Guide
          _buildCircleIconButton(
            icon: _showGuide ? Icons.visibility_rounded : Icons.visibility_off_rounded,
            tooltip: AppStrings.toggleGuide,
            isActive: _showGuide,
            onTap: () => setState(() => _showGuide = !_showGuide),
          ),
          const SizedBox(width: 6),

          // Reset transforms
          _buildCircleIconButton(
            icon: Icons.restart_alt_rounded,
            tooltip: AppStrings.resetPosition,
            onTap: _resetItemTransforms,
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Material(
      color: Colors.black.withValues(alpha: 0.65),
      shape: const CircleBorder(side: BorderSide(color: Colors.white24)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(
            icon,
            size: 20,
            color: isActive ? AppColors.accentGold : Colors.white,
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // BOTTOM JEWELLERY SELECTOR & ACTIONS
  // -------------------------------------------------------------

  Widget _buildBottomTryOnShelf(BuildContext context) {
    final products = context.watch<ProductProvider>().products;
    final dynamicTryOns = products
        .map((p) => ArTryOnItem.fromProduct(p))
        .whereType<ArTryOnItem>()
        .toList();

    final allItems = [...ArTryOnItem.curatedItems, ...dynamicTryOns];
    final filtered = allItems.where((i) => i.type == _activeCategory).toList();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.85),
            Colors.black.withValues(alpha: 0.98),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Active Item Info Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedItem.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_selectedItem.material} • ${_selectedItem.weight}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  Formatters.price(_selectedItem.price),
                  style: const TextStyle(
                    color: AppColors.accentGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Category Switcher (Earrings vs Necklaces)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCategoryPill(
                type: ArItemType.earrings,
                label: AppStrings.earrings,
                icon: Icons.flare_rounded,
              ),
              const SizedBox(width: 12),
              _buildCategoryPill(
                type: ArItemType.necklace,
                label: AppStrings.necklaces,
                icon: Icons.all_inclusive_rounded,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Horizontal Jewellery Carousel
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = filtered[index];
                final isSelected = item.id == _selectedItem.id;

                return InkWell(
                  onTap: () => _selectItem(item),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 76,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.7)
                          : Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                      border: Border.all(
                        color: isSelected ? AppColors.accentGold : Colors.white24,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: CachedNetworkImage(
                            imageUrl: item.imageUrl,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(child: AppLoader(size: 16)),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.diamond_outlined, color: Colors.white54, size: 24),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Formatters.price(item.price),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          // Action Buttons: Snap & Share / Enquire / Details
          Row(
            children: [
              // Share Look
              Expanded(
                child: AppButton.outlined(
                  title: AppStrings.shareLook,
                  height: 44,
                  onPressed: _shareLook,
                ),
              ),
              const SizedBox(width: 8),

              // Enquire on WhatsApp
              Expanded(
                child: AppButton(
                  title: 'Enquire Piece',
                  height: 44,
                  onPressed: () {
                    WhatsAppService.shareMessage(
                      message:
                          'Hello Jewel Ora, I tried on the ${_selectedItem.name} (${Formatters.price(_selectedItem.price)}) in your AR Virtual Mirror and would love to check availability and book a viewing.',
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),

              // View Full Details
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                tooltip: 'Product Details',
                icon: const Icon(Icons.open_in_new_rounded, size: 20),
                onPressed: () {
                  final product = context
                      .read<ProductProvider>()
                      .findById(_selectedItem.id);
                  if (product != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(productId: product.id),
                      ),
                    );
                  } else {
                    showAppSnackBar(context, '${_selectedItem.name} (${_selectedItem.material})');
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPill({
    required ArItemType type,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _activeCategory == type;

    return InkWell(
      onTap: () {
        setState(() {
          _activeCategory = type;
          final firstOfType = ArTryOnItem.curatedItems.firstWhere(
            (i) => i.type == type,
          );
          _selectItem(firstOfType);
        });
      },
      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentGold : Colors.white12,
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          border: Border.all(
            color: isSelected ? AppColors.accentGold : Colors.white24,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.black : Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareLook() async {
    final message =
        '${AppStrings.howDoesThisLook} Trying on the ${_selectedItem.name} (${Formatters.price(_selectedItem.price)}) in Jewel Ora\'s AR Virtual Mirror! ✨';
    await SharePlus.instance.share(
      ShareParams(
        text: message,
        subject: _selectedItem.name,
      ),
    );
  }
}

// -------------------------------------------------------------
// AR FACIAL & NECKLINE SILHOUETTE PAINTER
// -------------------------------------------------------------

class _ArFacialGuidePainter extends CustomPainter {
  final double earSpacing;
  final bool isEarring;

  _ArFacialGuidePainter({
    required this.earSpacing,
    required this.isEarring,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.40);

    final guidePaint = Paint()
      ..color = AppColors.accentGold.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final dotPaint = Paint()
      ..color = AppColors.accentGold.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    // 1. Oval Face Contour
    final ovalRect = Rect.fromCenter(
      center: center,
      width: 175,
      height: 235,
    );
    canvas.drawOval(ovalRect, guidePaint);

    if (isEarring) {
      // 2. Left and Right Earlobe Targets
      final leftEar = Offset(center.dx - (earSpacing / 2), center.dy + 15);
      final rightEar = Offset(center.dx + (earSpacing / 2), center.dy + 15);

      canvas.drawCircle(leftEar, 6, dotPaint);
      canvas.drawCircle(leftEar, 12, guidePaint);

      canvas.drawCircle(rightEar, 6, dotPaint);
      canvas.drawCircle(rightEar, 12, guidePaint);
    } else {
      // 3. Neck & Collarbone Curve
      final neckPath = Path()
        ..moveTo(center.dx - 80, center.dy + 110)
        ..quadraticBezierTo(
          center.dx,
          center.dy + 165,
          center.dx + 80,
          center.dy + 110,
        );
      canvas.drawPath(neckPath, guidePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ArFacialGuidePainter oldDelegate) {
    return oldDelegate.earSpacing != earSpacing || oldDelegate.isEarring != isEarring;
  }
}
