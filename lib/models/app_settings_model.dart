import 'package:jewel_ora/core/constants/app_strings.dart';

class AppSettingsModel {
  final String appName;
  final String whatsappNumber; // with country code, e.g. 919876543210
  final String welcomeMessage;
  final String appIcon; // key from AppIconOptions (also drives the in-app logo)

  const AppSettingsModel({
    this.appName = AppStrings.appName,
    this.whatsappNumber = '',
    this.welcomeMessage = 'Welcome to our jewellery store',
    this.appIcon = 'default',
  });

  factory AppSettingsModel.fromMap(Map<String, dynamic> map) {
    return AppSettingsModel(
      appName: map['appName'] ?? AppStrings.appName,
      whatsappNumber: map['whatsappNumber'] ?? '',
      welcomeMessage: map['welcomeMessage'] ?? 'Welcome to our jewellery store',
      appIcon: map['appIcon'] ?? 'default',
    );
  }

  Map<String, dynamic> toMap() => {
    'appName': appName,
    'whatsappNumber': whatsappNumber,
    'welcomeMessage': welcomeMessage,
    'appIcon': appIcon,
  };

  AppSettingsModel copyWith({
    String? appName,
    String? whatsappNumber,
    String? welcomeMessage,
    String? appIcon,
  }) {
    return AppSettingsModel(
      appName: appName ?? this.appName,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      welcomeMessage: welcomeMessage ?? this.welcomeMessage,
      appIcon: appIcon ?? this.appIcon,
    );
  }
}
