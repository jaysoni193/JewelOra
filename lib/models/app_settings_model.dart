import 'package:jewel_ora/core/constants/app_strings.dart';

class AppSettingsModel {
  final String logoUrl;
  final String appName;
  final String whatsappNumber; // with country code, e.g. 919876543210
  final String welcomeMessage;
  final String appIcon; // key from AppIconOptions

  const AppSettingsModel({
    this.logoUrl = '',
    this.appName = AppStrings.appName,
    this.whatsappNumber = '',
    this.welcomeMessage = 'Welcome to our jewellery store',
    this.appIcon = 'default',
  });

  factory AppSettingsModel.fromMap(Map<String, dynamic> map) {
    return AppSettingsModel(
      logoUrl: map['logoUrl'] ?? '',
      appName: map['appName'] ?? AppStrings.appName,
      whatsappNumber: map['whatsappNumber'] ?? '',
      welcomeMessage: map['welcomeMessage'] ?? 'Welcome to our jewellery store',
      appIcon: map['appIcon'] ?? 'default',
    );
  }

  Map<String, dynamic> toMap() => {
    'logoUrl': logoUrl,
    'appName': appName,
    'whatsappNumber': whatsappNumber,
    'welcomeMessage': welcomeMessage,
    'appIcon': appIcon,
  };
}