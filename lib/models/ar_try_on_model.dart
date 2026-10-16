import 'package:jewel_ora/models/product_model.dart';

enum ArItemType { earrings, necklace }

class ArTryOnItem {
  final String id;
  final String name;
  final ArItemType type;
  final String categoryId;
  final String categoryName;
  final String imageUrl;
  final double price;
  final String material;
  final String weight;
  final double defaultScale;
  final double defaultOffsetX;
  final double defaultOffsetY;
  final double earringSpacing; // Pixel distance between left and right earlobes

  const ArTryOnItem({
    required this.id,
    required this.name,
    required this.type,
    required this.categoryId,
    required this.categoryName,
    required this.imageUrl,
    required this.price,
    required this.material,
    this.weight = '5.0 g',
    this.defaultScale = 1.0,
    this.defaultOffsetX = 0.0,
    this.defaultOffsetY = 0.0,
    this.earringSpacing = 160.0,
  });

  /// Curated luxury try-on pieces with authentic images
  static List<ArTryOnItem> get curatedItems => [
        // --- EARRINGS ---
        const ArTryOnItem(
          id: 'ar_earring_jhumka',
          name: 'Royal Heritage Meenakari Jhumkas',
          type: ArItemType.earrings,
          categoryId: 'cat_earrings',
          categoryName: 'Earrings & Jhumkas',
          imageUrl:
              'https://images.unsplash.com/photo-1630019852942-f89202989a59?w=500&auto=format&fit=crop&q=80',
          price: 54999,
          material: '22K Gold with Pearl Drops',
          weight: '14.2 g',
          defaultScale: 0.95,
          earringSpacing: 165.0,
          defaultOffsetY: -30.0,
        ),
        const ArTryOnItem(
          id: 'ar_earring_solitaire',
          name: 'Eternal Solitaire Diamond Studs',
          type: ArItemType.earrings,
          categoryId: 'cat_earrings',
          categoryName: 'Earrings & Jhumkas',
          imageUrl:
              'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=500&auto=format&fit=crop&q=80',
          price: 42000,
          material: '18K White Gold with 0.70 ct VVS Diamonds',
          weight: '3.1 g',
          defaultScale: 0.75,
          earringSpacing: 160.0,
          defaultOffsetY: -35.0,
        ),
        const ArTryOnItem(
          id: 'ar_earring_chandbali',
          name: 'Nizam Polki Crescent Chandbalis',
          type: ArItemType.earrings,
          categoryId: 'cat_earrings',
          categoryName: 'Earrings & Jhumkas',
          imageUrl:
              'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=500&auto=format&fit=crop&q=80',
          price: 68000,
          material: '22K Hallmark Gold with Uncut Polki',
          weight: '18.5 g',
          defaultScale: 1.05,
          earringSpacing: 170.0,
          defaultOffsetY: -25.0,
        ),
        const ArTryOnItem(
          id: 'ar_earring_drops',
          name: 'Rose Gold Floral Chandelier Drops',
          type: ArItemType.earrings,
          categoryId: 'cat_earrings',
          categoryName: 'Earrings & Jhumkas',
          imageUrl:
              'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=500&auto=format&fit=crop&q=80',
          price: 36500,
          material: '18K Rose Gold with Natural Rubies',
          weight: '8.4 g',
          defaultScale: 0.90,
          earringSpacing: 162.0,
          defaultOffsetY: -28.0,
        ),

        // --- NECKLACES ---
        const ArTryOnItem(
          id: 'ar_necklace_choker',
          name: 'Royal Heritage Kundan Choker',
          type: ArItemType.necklace,
          categoryId: 'cat_necklaces',
          categoryName: 'Necklaces & Sets',
          imageUrl:
              'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600&auto=format&fit=crop&q=80',
          price: 119999,
          material: '22K Gold with Uncut Syndicate Polki',
          weight: '32.8 g',
          defaultScale: 1.15,
          defaultOffsetY: 95.0,
        ),
        const ArTryOnItem(
          id: 'ar_necklace_temple',
          name: 'Auspicious Lakshmi Temple Haar',
          type: ArItemType.necklace,
          categoryId: 'cat_necklaces',
          categoryName: 'Necklaces & Sets',
          imageUrl:
              'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600&auto=format&fit=crop&q=80',
          price: 185000,
          material: '22K Yellow Hallmark Gold',
          weight: '44.0 g',
          defaultScale: 1.25,
          defaultOffsetY: 125.0,
        ),
        const ArTryOnItem(
          id: 'ar_necklace_diamond',
          name: 'Lustrous Solitaire Diamond Pendant Chain',
          type: ArItemType.necklace,
          categoryId: 'cat_chains',
          categoryName: 'Pendants & Chains',
          imageUrl:
              'https://images.unsplash.com/photo-1611591475152-477028d7120a?w=600&auto=format&fit=crop&q=80',
          price: 48999,
          material: '18K Rose Gold with 0.45 ct Solitaire',
          weight: '5.2 g',
          defaultScale: 0.95,
          defaultOffsetY: 105.0,
        ),
        const ArTryOnItem(
          id: 'ar_necklace_mangalsutra',
          name: 'Modern Infinite Diamond Mangalsutra',
          type: ArItemType.necklace,
          categoryId: 'cat_mangalsutra',
          categoryName: 'Mangalsutras',
          imageUrl:
              'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600&auto=format&fit=crop&q=80',
          price: 52000,
          material: '18K Yellow Gold with Black Beads & Diamonds',
          weight: '6.8 g',
          defaultScale: 1.0,
          defaultOffsetY: 110.0,
        ),
      ];

  /// Convert a regular catalogue ProductModel into an ArTryOnItem
  static ArTryOnItem? fromProduct(ProductModel product) {
    final catId = product.categoryId.toLowerCase();
    final name = product.name.toLowerCase();

    final isEarring = catId.contains('earring') ||
        name.contains('earring') ||
        name.contains('jhumka') ||
        name.contains('stud') ||
        name.contains('chandbali') ||
        name.contains('bali') ||
        name.contains('drop');

    final isNecklace = catId.contains('necklace') ||
        catId.contains('chain') ||
        catId.contains('mangalsutra') ||
        name.contains('necklace') ||
        name.contains('choker') ||
        name.contains('haar') ||
        name.contains('pendant') ||
        name.contains('chain') ||
        name.contains('mangalsutra');

    if (!isEarring && !isNecklace) return null;

    final type = isEarring ? ArItemType.earrings : ArItemType.necklace;

    return ArTryOnItem(
      id: product.id,
      name: product.name,
      type: type,
      categoryId: product.categoryId,
      categoryName: product.categoryName,
      imageUrl: product.images.isNotEmpty
          ? product.images.first
          : 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600&auto=format&fit=crop&q=80',
      price: product.price,
      material: product.material,
      weight: product.weight,
      defaultScale: isEarring ? 0.95 : 1.15,
      defaultOffsetY: isEarring ? -30.0 : 100.0,
      earringSpacing: 165.0,
    );
  }
}
