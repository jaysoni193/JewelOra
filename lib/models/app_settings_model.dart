import 'package:jewel_ora/core/constants/app_strings.dart';

class AppSettingsModel {
  final String appName;
  final String whatsappNumber; // with country code, e.g. 919876543210
  final String welcomeMessage;
  final String appIcon; // key from AppIconOptions (also drives the in-app logo)
  final String storeAddress;
  final String mapUrl;
  final String storePhone;
  final String instagramHandle;
  final String storeTimings;
  final String storeEmail;

  // Admin Tool: Force Update Flag
  final bool forceUpdate;
  final String minAppVersion;
  final String forceUpdateMessage;

  const AppSettingsModel({
    this.appName = AppStrings.appName,
    this.whatsappNumber = '',
    this.welcomeMessage = 'Welcome to our jewellery store',
    this.appIcon = 'default',
    this.storeAddress = '108, Jewel Boulevard, Zaveri Bazaar, Mumbai 400002',
    this.mapUrl = 'https://maps.google.com/?q=Zaveri+Bazaar+Mumbai',
    this.storePhone = '+91 98765 43210',
    this.instagramHandle = 'jewelora.jewels',
    this.storeTimings = 'Mon - Sat: 10:30 AM - 8:30 PM | Sun: 11:00 AM - 6:00 PM',
    this.storeEmail = 'support@jewelora.com',
    this.forceUpdate = false,
    this.minAppVersion = '1.0.0',
    this.forceUpdateMessage = 'A critical update is required to continue viewing our latest collection.',
  });

  factory AppSettingsModel.fromMap(Map<String, dynamic> map) {
    return AppSettingsModel(
      appName: map['appName'] ?? AppStrings.appName,
      whatsappNumber: map['whatsappNumber'] ?? '',
      welcomeMessage: map['welcomeMessage'] ?? 'Welcome to our jewellery store',
      appIcon: map['appIcon'] ?? 'default',
      storeAddress: map['storeAddress'] ?? '108, Jewel Boulevard, Zaveri Bazaar, Mumbai 400002',
      mapUrl: map['mapUrl'] ?? 'https://maps.google.com/?q=Zaveri+Bazaar+Mumbai',
      storePhone: map['storePhone'] ?? '+91 98765 43210',
      instagramHandle: map['instagramHandle'] ?? 'jewelora.jewels',
      storeTimings: map['storeTimings'] ?? 'Mon - Sat: 10:30 AM - 8:30 PM | Sun: 11:00 AM - 6:00 PM',
      storeEmail: map['storeEmail'] ?? 'support@jewelora.com',
      forceUpdate: map['forceUpdate'] ?? false,
      minAppVersion: map['minAppVersion'] ?? '1.0.0',
      forceUpdateMessage: map['forceUpdateMessage'] ??
          'A critical update is required to continue viewing our latest collection.',
    );
  }

  Map<String, dynamic> toMap() => {
    'appName': appName,
    'whatsappNumber': whatsappNumber,
    'welcomeMessage': welcomeMessage,
    'appIcon': appIcon,
    'storeAddress': storeAddress,
    'mapUrl': mapUrl,
    'storePhone': storePhone,
    'instagramHandle': instagramHandle,
    'storeTimings': storeTimings,
    'storeEmail': storeEmail,
    'forceUpdate': forceUpdate,
    'minAppVersion': minAppVersion,
    'forceUpdateMessage': forceUpdateMessage,
  };

  AppSettingsModel copyWith({
    String? appName,
    String? whatsappNumber,
    String? welcomeMessage,
    String? appIcon,
    String? storeAddress,
    String? mapUrl,
    String? storePhone,
    String? instagramHandle,
    String? storeTimings,
    String? storeEmail,
    bool? forceUpdate,
    String? minAppVersion,
    String? forceUpdateMessage,
  }) {
    return AppSettingsModel(
      appName: appName ?? this.appName,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      welcomeMessage: welcomeMessage ?? this.welcomeMessage,
      appIcon: appIcon ?? this.appIcon,
      storeAddress: storeAddress ?? this.storeAddress,
      mapUrl: mapUrl ?? this.mapUrl,
      storePhone: storePhone ?? this.storePhone,
      instagramHandle: instagramHandle ?? this.instagramHandle,
      storeTimings: storeTimings ?? this.storeTimings,
      storeEmail: storeEmail ?? this.storeEmail,
      forceUpdate: forceUpdate ?? this.forceUpdate,
      minAppVersion: minAppVersion ?? this.minAppVersion,
      forceUpdateMessage: forceUpdateMessage ?? this.forceUpdateMessage,
    );
  }
}
