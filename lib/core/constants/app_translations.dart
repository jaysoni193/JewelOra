import 'package:jewel_ora/core/constants/app_strings.dart';

class AppTranslations {
  AppTranslations._();

  static String tr(String key, String langCode) {
    return AppStrings.tr(key, langCode: langCode);
  }
}
