import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/storage/local_storage.dart';

class LocaleProvider extends ChangeNotifier {
  String _locale = 'en';

  String get locale => _locale;
  String get currentCode => _locale;
  Locale get currentLocale => Locale(_locale);

  LocaleProvider() {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    _locale = await LocalStorage.instance.getAppLocale();
    AppStrings.setLocale(_locale);
    notifyListeners();
  }

  Future<void> setLocale(String langCode) async {
    if (_locale == langCode) return;
    _locale = langCode;
    AppStrings.setLocale(langCode);
    await LocalStorage.instance.setAppLocale(langCode);
    notifyListeners();
  }

  String tr(String key) => AppStrings.tr(key, langCode: _locale);
}
