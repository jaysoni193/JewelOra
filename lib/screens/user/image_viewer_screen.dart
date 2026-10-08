import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jewel_ora/core/utils/image_url.dart';
import 'package:jewel_ora/core/widgets/app_loader.dart';

class ImageViewerScreen extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const ImageViewerScreen({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late final PageController _ctrl =
      PageController(initialPage: widget.initialIndex);
  late int _current = widget.initialIndex;
  bool _zoomed = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          '${_current + 1} / ${widget.images.length}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: PageView.builder(
        controller: _ctrl,
        physics: _zoomed
            ? const NeverScrollableScrollPhysics()
            : const PageScrollPhysics(),
        itemCount: widget.images.length,
        onPageChanged: (i) => setState(() => _current = i),
        itemBuilder: (context, i) => _ZoomableImage(
          url: widget.images[i],
          onZoomChanged: (z) {
            if (z != _zoomed) setState(() => _zoomed = z);
          },
        ),
      ),
    );
  }
}

class _ZoomableImage extends StatefulWidget {
  final String url;
  final ValueChanged<bool> onZoomChanged;

  const _ZoomableImage({required this.url, required this.onZoomChanged});

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage> {
  final _controller = TransformationController();
  Offset _tapPosition = Offset.zero;
  bool _zoomed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setZoomed(bool value) {
    if (value == _zoomed) return;
    setState(() => _zoomed = value);
    widget.onZoomChanged(value);
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    _setZoomed(_controller.value.getMaxScaleOnAxis() > 1.01);
  }

  void _onDoubleTap() {
    if (_zoomed) {
      _controller.value = Matrix4.identity();
      _setZoomed(false);
    } else {
      // Zoom in around the spot that was tapped.
      const s = 2.5;
      _controller.value = Matrix4.diagonal3Values(s, s, 1)
        ..setTranslationRaw(
          -_tapPosition.dx * (s - 1),
          -_tapPosition.dy * (s - 1),
          0,
        );
      _setZoomed(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (d) => _tapPosition = d.localPosition,
      onDoubleTap: _onDoubleTap,
      child: InteractiveViewer(
        transformationController: _controller,
        minScale: 1,
        maxScale: 4,
        // One-finger drag is only for moving a zoomed image; at normal
        // size it must stay free for swiping between pictures.
        panEnabled: _zoomed,
        onInteractionEnd: _onInteractionEnd,
        child: SizedBox.expand(
          child: CachedNetworkImage(
            imageUrl: ImageUrl.optimized(widget.url, width: 1400),
            fit: BoxFit.contain,
            placeholder: (context, url) =>
                const Center(child: AppLoader(size: 40)),
            errorWidget: (context, url, error) => const Icon(
              Icons.broken_image_outlined,
              color: Colors.white54,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }
}