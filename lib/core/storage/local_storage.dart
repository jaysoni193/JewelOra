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
      prefs.setString(AppKeys.cachedAppName, settings.appName),
      prefs.setString(AppKeys.cachedWelcomeMessage, settings.welcomeMessage),
      prefs.setString(AppKeys.cachedWhatsappNumber, settings.whatsappNumber),
      prefs.setString(AppKeys.cachedAppIcon, settings.appIcon),
      prefs.setString(AppKeys.cachedStoreAddress, settings.storeAddress),
      prefs.setString(AppKeys.cachedMapUrl, settings.mapUrl),
      prefs.setString(AppKeys.cachedStorePhone, settings.storePhone),
      prefs.setString(AppKeys.cachedInstagramHandle, settings.instagramHandle),
      prefs.setString(AppKeys.cachedStoreTimings, settings.storeTimings),
      prefs.setString(AppKeys.cachedStoreEmail, settings.storeEmail),
      prefs.setString(
        AppKeys.cachedBrandingUpdatedAt,
        DateTime.now().toIso8601String(),
      ),
    ]);
  }

  Future<AppSettingsModel> getCachedAppSettings() async {
    final prefs = await _safePrefs;
    final appName = prefs.getString(AppKeys.cachedAppName);
    final welcome = prefs.getString(AppKeys.cachedWelcomeMessage);
    final whatsapp = prefs.getString(AppKeys.cachedWhatsappNumber);
    final icon = prefs.getString(AppKeys.cachedAppIcon);
    final address = prefs.getString(AppKeys.cachedStoreAddress);
    final mapUrl = prefs.getString(AppKeys.cachedMapUrl);
    final phone = prefs.getString(AppKeys.cachedStorePhone);
    final instagram = prefs.getString(AppKeys.cachedInstagramHandle);
    final timings = prefs.getString(AppKeys.cachedStoreTimings);
    final email = prefs.getString(AppKeys.cachedStoreEmail);

    // If never cached before, return defaults
    if (appName == null) {
      return const AppSettingsModel();
    }

    return AppSettingsModel(
      appName: appName,
      welcomeMessage: welcome ?? 'Welcome to our jewellery store',
      whatsappNumber: whatsapp ?? '',
      appIcon: icon ?? 'default',
      storeAddress: address ?? '108, Jewel Boulevard, Zaveri Bazaar, Mumbai 400002',
      mapUrl: mapUrl ?? 'https://maps.google.com/?q=Zaveri+Bazaar+Mumbai',
      storePhone: phone ?? '+91 98765 43210',
      instagramHandle: instagram ?? 'jewelora.jewels',
      storeTimings: timings ?? 'Mon - Sat: 10:30 AM - 8:30 PM | Sun: 11:00 AM - 6:00 PM',
      storeEmail: email ?? 'support@jewelora.com',
    );
  }

  Future<void> clearBrandingCache() async {
    final prefs = await _safePrefs;
    await Future.wait([
      prefs.remove(AppKeys.cachedAppName),
      prefs.remove(AppKeys.cachedWelcomeMessage),
      prefs.remove(AppKeys.cachedWhatsappNumber),
      prefs.remove(AppKeys.cachedAppIcon),
      prefs.remove(AppKeys.cachedStoreAddress),
      prefs.remove(AppKeys.cachedMapUrl),
      prefs.remove(AppKeys.cachedStorePhone),
      prefs.remove(AppKeys.cachedInstagramHandle),
      prefs.remove(AppKeys.cachedStoreTimings),
      prefs.remove(AppKeys.cachedStoreEmail),
      prefs.remove(AppKeys.cachedBrandingUpdatedAt),
    ]);
  }
}
