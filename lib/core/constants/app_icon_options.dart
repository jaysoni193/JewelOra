import 'package:jewel_ora/core/constants/app_images.dart';

class AppIconOption {
  final String key;   // saved in Firestore (app_settings/config -> appIcon)
  final String label; // shown to the admin
  final String alias; // must match the <activity-alias> name in AndroidManifest.xml
  final String asset; // the picture used INSIDE the app (login, home, admin...)

  const AppIconOption(this.key, this.label, this.alias, this.asset);
}

/// THE one list of icons. To add a festival:
///  1. add the 5 launcher PNGs  (android/.../res/mipmap-*/ic_launcher_<name>.png)
///  2. add one <activity-alias> block in AndroidManifest.xml
///  3. add the picture assets/app_icons/<name>.png
///  4. add one line below
class AppIconOptions {
  AppIconOptions._();

  static const List<AppIconOption> all = [
    // "Default" keeps your own logo (assets/images/logo.png).
    AppIconOption('default', 'Default', 'IconDefault', AppImages.logo),
    AppIconOption('diwali', 'Diwali', 'IconDiwali', 'assets/app_icons/diwali.png'),
    AppIconOption('christmas', 'Christmas', 'IconChristmas', 'assets/app_icons/christmas.png'),
    AppIconOption('eid', 'Eid', 'IconEid', 'assets/app_icons/eid.png'),
    AppIconOption('holi', 'Holi', 'IconHoli', 'assets/app_icons/holi.png'),
    AppIconOption('navratri', 'Navratri', 'IconNavratri', 'assets/app_icons/navratri.png'),
    AppIconOption('newyear', 'New Year', 'IconNewYear', 'assets/app_icons/newyear.png'),
    AppIconOption('rakhi', 'Raksha Bandhan', 'IconRakhi', 'assets/app_icons/rakhi.png'),
    AppIconOption('akshaya', 'Akshaya Tritiya', 'IconAkshaya', 'assets/app_icons/akshaya.png'),
  ];

  static AppIconOption byKey(String key) =>
      all.firstWhere((o) => o.key == key, orElse: () => all.first);
}
