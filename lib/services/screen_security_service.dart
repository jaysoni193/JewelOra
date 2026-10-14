import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// ScreenSecurityService manages hardware-level protection against screenshots,
/// screen video recording, and recent-apps task switcher snapshots.
///
/// On Android, this enforces `WindowManager.LayoutParams.FLAG_SECURE`.
/// On iOS, this observes screen capture / mirroring notifications and applies
/// privacy blur overlays.
class ScreenSecurityService {
  ScreenSecurityService._();
  static final ScreenSecurityService instance = ScreenSecurityService._();

  static const MethodChannel _channel = MethodChannel('jewel_ora/security');

  bool _isSecure = true;

  /// Returns whether screenshot & recording protection is active.
  bool get isSecure => _isSecure;

  /// Initializes screen security on app startup.
  Future<void> init() async {
    await enableProtection();
  }

  /// Blocks screenshots and video recordings.
  Future<bool> enableProtection() async {
    if (kIsWeb) return false;
    try {
      final ok = await _channel.invokeMethod<bool>('enableSecure') ?? true;
      _isSecure = ok;
      return ok;
    } catch (e) {
      debugPrint('Screen security enable error: $e');
      return false;
    }
  }

  /// Unblocks screenshots and video recordings if ever explicitly needed.
  Future<bool> disableProtection() async {
    if (kIsWeb) return false;
    try {
      final ok = await _channel.invokeMethod<bool>('disableSecure') ?? false;
      _isSecure = !ok;
      return ok;
    } catch (e) {
      debugPrint('Screen security disable error: $e');
      return false;
    }
  }
}
