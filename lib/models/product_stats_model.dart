class ProductStatsModel {
  final String productId; // also the document ID
  final int views;
  final int enquiries;

  const ProductStatsModel({
    required this.productId,
    this.views = 0,
    this.enquiries = 0,
  });

  factory ProductStatsModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductStatsModel(
      productId: id,
      views: ((map['views'] ?? 0) as num).toInt(),
      enquiries: ((map['enquiries'] ?? 0) as num).toInt(),
    );
  }
}