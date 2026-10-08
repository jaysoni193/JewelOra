import 'package:jewel_ora/core/constants/app_keys.dart';
import 'package:jewel_ora/models/app_settings_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  LocalStorage._();
  static final LocalStorage instance = LocalStorage._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> get _safePrefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ---------- Branding & App Settings Cache ----------

  Future<void> cacheAppSettings(AppSettingsModel settings) async {
    final prefs = await _safePrefs;
    await Future.wait([
      prefs.setString(AppKeys.cachedLogoUrl, settings.logoUrl),
      prefs.setString(AppKeys.cachedAppName, settings.appName),
      prefs.setString(AppKeys.cachedWelcomeMessage, settings.welcomeMessage),
      prefs.setString(AppKeys.cachedWhatsappNumber, settings.whatsappNumber),
      prefs.setString(AppKeys.cachedAppIcon, settings.appIcon),
      prefs.setString(
        AppKeys.cachedBrandingUpdatedAt,
        DateTime.now().toIso8601String(),
      ),
    ]);
  }

  Future<AppSettingsModel> getCachedAppSettings() async {
    final prefs = await _safePrefs;
    final logoUrl = prefs.getString(AppKeys.cachedLogoUrl) ?? '';
    final appName = prefs.getString(AppKeys.cachedAppName);
    final welcome = prefs.getString(AppKeys.cachedWelcomeMessage);
    final whatsapp = prefs.getString(AppKeys.cachedWhatsappNumber);
    final icon = prefs.getString(AppKeys.cachedAppIcon);

    // If never cached before, return defaults
    if (logoUrl.isEmpty && appName == null) {
      return const AppSettingsModel();
    }

    return AppSettingsModel(
      logoUrl: logoUrl,
      appName: appName ?? 'Jewel Ora',
      welcomeMessage: welcome ?? 'Welcome to our jewellery store',
      whatsappNumber: whatsapp ?? '',
      appIcon: icon ?? 'default',
    );
  }

  Future<void> clearBrandingCache() async {
    final prefs = await _safePrefs;
    await Future.wait([
      prefs.remove(AppKeys.cachedLogoUrl),
      prefs.remove(AppKeys.cachedAppName),
      prefs.remove(AppKeys.cachedWelcomeMessage),
      prefs.remove(AppKeys.cachedWhatsappNumber),
      prefs.remove(AppKeys.cachedAppIcon),
      prefs.remove(AppKeys.cachedBrandingUpdatedAt),
    ]);
  }
}
