/// All Firestore collection names in ONE place.
/// A typo in a collection name causes silent bugs, so never type them by hand elsewhere.
class FirestorePaths {
  FirestorePaths._();

  static const String users = 'users';
  static const String categories = 'categories';
  static const String products = 'products';
  static const String banners = 'banners';
  static const String appSettings = 'app_settings';
  static const String cart = 'cart'; // subcollection of users/{uid}
  static const String wishlist = 'wishlist'; // subcollection of users/{uid}
  // The single settings document ID
  static const String settingsDocId = 'config';
  static const String productStats = 'product_stats';
}