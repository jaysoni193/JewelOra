class BannerModel {
  final String id;
  final String imageUrl;
  final String title;
  final int order;
  final bool isActive;

  const BannerModel({
    required this.id,
    required this.imageUrl,
    this.title = '',
    this.order = 0,
    this.isActive = true,
  });

  factory BannerModel.fromMap(Map<String, dynamic> map, String id) {
    return BannerModel(
      id: id,
      imageUrl: map['imageUrl'] ?? '',
      title: map['title'] ?? '',
      order: (map['order'] ?? 0).toInt(),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
    'imageUrl': imageUrl,
    'title': title,
    'order': order,
    'isActive': isActive,
  };
}