class ImageUrl {
  ImageUrl._();

  /// Returns a resized, auto-compressed version of a Cloudinary URL.
  /// Non-Cloudinary URLs are returned unchanged.
  static String optimized(String url, {int width = 600}) {
    const marker = '/upload/';
    if (url.isEmpty || !url.contains('res.cloudinary.com')) return url;
    return url.replaceFirst(marker, '$marker' 'w_$width,c_limit,q_auto,f_auto/');
  }
}