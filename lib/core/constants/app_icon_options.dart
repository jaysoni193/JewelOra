class AppIconOption {
  final String key;   // saved in Firestore
  final String label; // shown to the admin
  final String alias; // must match the manifest alias name
  const AppIconOption(this.key, this.label, this.alias);
}

class AppIconOptions {
  AppIconOptions._();

  static const List<AppIconOption> all = [
    AppIconOption('default', 'Default', 'IconDefault'),
    AppIconOption('diwali', 'Diwali', 'IconDiwali'),
    AppIconOption('christmas', 'Christmas', 'IconChristmas'),
  ];

  static AppIconOption byKey(String key) =>
      all.firstWhere((o) => o.key == key, orElse: () => all.first);
}