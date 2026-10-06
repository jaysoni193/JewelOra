import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  // Resize and compress at pick time, so uploads are small and fast.
  static const double _maxWidth = 1200;
  static const int _quality = 80;

  Future<XFile?> pickOne() {
    return _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: _maxWidth,
      imageQuality: _quality,
    );
  }

  Future<List<XFile>> pickMany() {
    return _picker.pickMultiImage(
      maxWidth: _maxWidth,
      imageQuality: _quality,
    );
  }
}