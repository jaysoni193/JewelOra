class CloudinaryConfig {
  CloudinaryConfig._();

  // Replace both values with yours from the Cloudinary dashboard.
  static const String cloudName = 'dzxnwbyhg';
  static const String uploadPreset = 'Jewelora';

  static String get uploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';
}