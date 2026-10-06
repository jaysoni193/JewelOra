class UploadException implements Exception {
  final String message;
  const UploadException(this.message);

  @override
  String toString() => message;
}