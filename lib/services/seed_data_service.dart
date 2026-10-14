import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jewel_ora/core/constants/firestore_paths.dart';
import 'package:jewel_ora/models/banner_model.dart';
import 'package:jewel_ora/models/category_model.dart';
import 'package:jewel_ora/models/product_model.dart';

/// One-tap catalogue seeder for populating realistic, luxury demo jewellery data.
/// Covers:
/// - 8 distinct categories
/// - 3 promotional banners
/// - 18 all-feature jewellery pieces (Dynamic live gold/silver rates, strikethrough MRP,
///   discount %, festive tags, sizing chips, multi-image galleries, in-stock & out-of-stock).
/// Uses a single Firestore Batch write (29 writes total = 0.14% of daily Spark free tier).
class SeedDataService {
  SeedDataService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<int> seedCatalogue({bool overwrite = false}) async {
    final batch = _db.batch();

    // 1. Categories
    final categories = <CategoryModel>[
      const CategoryModel(
        id: 'cat_rings',
        name: 'Rings',
        imageUrl:
            'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600&auto=format&fit=crop&q=80',
        isActive: true,
      ),
      const CategoryModel(
        id: 'cat_necklaces',
        name: 'Necklaces & Sets',
        imageUrl:
            'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600&auto=format&fit=crop&q=80',
        isActive: true,
      ),
      const CategoryModel(
        id: 'cat_bangles',
        name: 'Bangles & Bracelets',
        imageUrl:
            'https://images.unsplash.com/photo-1611591475152-477028d7120a?w=600&auto=format&fit=crop&q=80',
        isActive: true,
      ),
      const CategoryModel(
        id: 'cat_earrings',
        name: 'Earrings & Jhumkas',
        imageUrl:
            'https://images.unsplash.com/photo-1630019852942-f89202989a59?w=600&auto=format&fit=crop&q=80',
        isActive: true,
      ),
      const CategoryModel(
        id: 'cat_mangalsutra',
        name: 'Mangalsutras',
        imageUrl:
            'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=600&auto=format&fit=crop&q=80',
        isActive: true,
      ),
      const CategoryModel(
        id: 'cat_coins',
        name: 'Gold Coins & Bars',
        imageUrl:
            'https://images.unsplash.com/photo-1610375461246-83df859d849d?w=600&auto=format&fit=crop&q=80',
        isActive: true,
      ),
      const CategoryModel(
        id: 'cat_chains',
        name: 'Pendants & Chains',
        imageUrl:
            'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=600&auto=format&fit=crop&q=80',
        isActive: true,
      ),
      const CategoryModel(
        id: 'cat_silver',
        name: 'Silver Articles',
        imageUrl:
            'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=600&auto=format&fit=crop&q=80',
        isActive: true,
      ),
    ];

    for (final cat in categories) {
      final ref = _db.collection(FirestorePaths.categories).doc(cat.id);
      batch.set(ref, cat.toMap(), SetOptions(merge: true));
    }

    // 2. Promotional Banners
    final banners = <BannerModel>[
      const BannerModel(
        id: 'banner_diwali',
        title: 'Diwali Jewellery Mahotsav',
        imageUrl:
            'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=1000&auto=format&fit=crop&q=80',
        isActive: true,
        order: 1,
      ),
      const BannerModel(
        id: 'banner_solitaire',
        title: 'Certified Solitaire Diamond Fest',
        imageUrl:
            'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=1000&auto=format&fit=crop&q=80',
        isActive: true,
        order: 2,
      ),
      const BannerModel(
        id: 'banner_live_rates',
        title: 'Zero Making Charges on Gold Coins',
        imageUrl:
            'https://images.unsplash.com/photo-1610375461246-83df859d849d?w=1000&auto=format&fit=crop&q=80',
        isActive: true,
        order: 3,
      ),
    ];

    for (final ban in banners) {
      final ref = _db.collection(FirestorePaths.banners).doc(ban.id);
      batch.set(ref, ban.toMap(), SetOptions(merge: true));
    }

    // 3. 18 Comprehensive Jewellery Products
    final products = <ProductModel>[
      // 1. Diamond Solitaire Ring
      ProductModel(
        id: 'prod_solitaire_ring',
        name: 'Eternal Solitaire Diamond Ring',
        description:
            'Handcrafted in luminous 18K rose gold, featuring a hand-selected 0.50 ct round brilliant VVS-EF solitaire diamond with IGI certification.',
        price: 49999,
        mrp: 65000,
        offerTag: 'Festive Offer',
        categoryId: 'cat_rings',
        categoryName: 'Rings',
        images: const [
          'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=800&auto=format&fit=crop&q=80',
        ],
        material: '18K Rose Gold with VVS-EF Diamond',
        weight: '3.45 g',
        isAvailable: true,
        isFeatured: true,
        availableSizes: const ['10', '12', '14', '16', '18', '20'],
      ),

      // 2. Royal Kundan Choker (Wedding Special)
      ProductModel(
        id: 'prod_kundan_choker',
        name: 'Royal Heritage Kundan Choker Set',
        description:
            'Magnificent bridal necklace adorned with uncut syndicate polki diamonds, natural Russian emerald drops, and south sea pearl strings.',
        price: 119999,
        mrp: 145000,
        offerTag: 'Wedding Special',
        categoryId: 'cat_necklaces',
        categoryName: 'Necklaces & Sets',
        images: const [
          'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=800&auto=format&fit=crop&q=80',
        ],
        material: '22K Hallmark Gold with Polki & Emeralds',
        weight: '32.80 g',
        isAvailable: true,
        isFeatured: true,
        availableSizes: const ['14 inch', '16 inch', 'Adjustable Dori'],
      ),

      // 3. 22K Temple Bangle Pair (Live Metal Rate)
      ProductModel(
        id: 'prod_temple_bangle',
        name: 'Auspicious Temple Bangle (Pair)',
        description:
            'Traditional handcrafted Lakshmi motifs carved by master artisans. Priced dynamically according to today\'s live 22K gold market rate.',
        price: 176400,
        mrp: 195000,
        offerTag: 'Live Metal Rate',
        categoryId: 'cat_bangles',
        categoryName: 'Bangles & Bracelets',
        images: const [
          'https://images.unsplash.com/photo-1611591475152-477028d7120a?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=800&auto=format&fit=crop&q=80',
        ],
        material: '22K BIS Hallmarked Yellow Gold',
        weight: '24.50 g',
        metalType: 'gold_22k',
        metalWeight: 24.5,
        makingCharges: 4900,
        useDynamicRate: true,
        isAvailable: true,
        isFeatured: true,
        availableSizes: const ['2.2', '2.4', '2.6', '2.8'],
      ),

      // 4. Peacock Chandbali Earrings
      ProductModel(
        id: 'prod_peacock_jhumka',
        name: 'Peacock Chandbali Jhumka Earrings',
        description:
            'Opulent festive earrings featuring delicate filigree peacock artwork, dangling cultured pearls, and pure ruby highlights.',
        price: 38400,
        mrp: 48000,
        offerTag: 'Diwali Special',
        categoryId: 'cat_earrings',
        categoryName: 'Earrings & Jhumkas',
        images: const [
          'https://images.unsplash.com/photo-1630019852942-f89202989a59?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=800&auto=format&fit=crop&q=80',
        ],
        material: '22K Yellow Gold with South Sea Pearls',
        weight: '8.60 g',
        isAvailable: true,
        isFeatured: true,
        availableSizes: const ['Standard'],
      ),

      // 5. Aura Diamond Eternity Mangalsutra
      ProductModel(
        id: 'prod_diamond_mangalsutra',
        name: 'Aura Diamond Eternity Mangalsutra',
        description:
            'A graceful union of modern eternity curves and sacred black beads, crowned with brilliant natural diamonds. Perfect for modern daily wear.',
        price: 58500,
        mrp: 72000,
        offerTag: 'Bestseller',
        categoryId: 'cat_mangalsutra',
        categoryName: 'Mangalsutras',
        images: const [
          'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=800&auto=format&fit=crop&q=80',
        ],
        material: '18K Yellow Gold with Natural Diamonds',
        weight: '5.20 g',
        isAvailable: true,
        isFeatured: true,
        availableSizes: const ['16 inch', '18 inch', '20 inch'],
      ),

      // 6. 24K 999 Purity Laxmi Ganesh Gold Coin 10g (Live Rate)
      ProductModel(
        id: 'prod_gold_coin_10g',
        name: '24K 999 Purity Laxmi Ganesh Gold Coin (10g)',
        description:
            'Government certified LBMA standard 999.9 fine pure gold minted coin with embossed Goddess Lakshmi and Lord Ganesha. Tamper-evident certipack packaging.',
        price: 76500,
        mrp: 79000,
        offerTag: 'Zero Waste / 999 Pure',
        categoryId: 'cat_coins',
        categoryName: 'Gold Coins & Bars',
        images: const [
          'https://images.unsplash.com/photo-1610375461246-83df859d849d?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1611591475152-477028d7120a?w=800&auto=format&fit=crop&q=80',
        ],
        material: '24K 999.9 Fine Pure Gold',
        weight: '10.00 g',
        metalType: 'gold_24k',
        metalWeight: 10.0,
        makingCharges: 650,
        useDynamicRate: true,
        isAvailable: true,
        isFeatured: true,
        availableSizes: const ['10 Grams Tamper-Proof Pack'],
      ),

      // 7. Italian Curb Men\'s Gold Chain (Live Rate)
      ProductModel(
        id: 'prod_curb_chain',
        name: 'Classic Italian Curb Gold Chain',
        description:
            'Heavy-gauge diamond-cut Italian curb link chain for gentlemen. Solid construction with high-polish rhodium-accented lobster claw lock.',
        price: 109600,
        mrp: 122000,
        offerTag: 'Trending Men',
        categoryId: 'cat_chains',
        categoryName: 'Pendants & Chains',
        images: const [
          'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=800&auto=format&fit=crop&q=80',
        ],
        material: '22K Hallmarked Yellow Gold',
        weight: '15.20 g',
        metalType: 'gold_22k',
        metalWeight: 15.2,
        makingCharges: 3200,
        useDynamicRate: true,
        isAvailable: true,
        isFeatured: false,
        availableSizes: const ['20 inch', '22 inch', '24 inch'],
      ),

      // 8. 925 Sterling Silver Antique Pooja Thali (Live Silver Rate)
      ProductModel(
        id: 'prod_silver_pooja_thali',
        name: '925 Sterling Silver Antique Pooja Thali Set',
        description:
            'Authentic hand-carved floral pooja thali featuring 2 silver katories, 1 diya, 1 agarbatti stand, and 1 bell. Ideal for auspicious wedding gifts and festivals.',
        price: 26250,
        mrp: 32000,
        offerTag: 'Auspicious Silver',
        categoryId: 'cat_silver',
        categoryName: 'Silver Articles',
        images: const [
          'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1610375461246-83df859d849d?w=800&auto=format&fit=crop&q=80',
        ],
        material: '92.5% Pure Sterling Silver',
        weight: '250.00 g',
        metalType: 'silver',
        metalWeight: 250.0,
        makingCharges: 2500,
        useDynamicRate: true,
        isAvailable: true,
        isFeatured: false,
        availableSizes: const ['8-inch Thali with 5 Accessories'],
      ),

      // 9. Vintage Emerald Cut Cocktail Ring
      ProductModel(
        id: 'prod_emerald_ring',
        name: 'Vintage Emerald Cut Cocktail Ring',
        description:
            'Deep verdant hydro emerald bordered by a double halo of brilliant round-cut lab diamonds set in high-polish 18K white and rose gold.',
        price: 42000,
        mrp: 54000,
        offerTag: 'Limited Edition',
        categoryId: 'cat_rings',
        categoryName: 'Rings',
        images: const [
          'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=800&auto=format&fit=crop&q=80',
        ],
        material: '18K White & Rose Gold with Hydro Emerald',
        weight: '4.80 g',
        isAvailable: true,
        isFeatured: false,
        availableSizes: const ['12', '14', '16', '18'],
      ),

      // 10. Royal Rajputana Polki Kada (OUT OF STOCK - tests stock indicator & pre-order flow)
      ProductModel(
        id: 'prod_polki_kada_oos',
        name: 'Royal Rajputana Polki Kada',
        description:
            'A museum-worthy heritage piece with openable screw clasp, hand-enameled meenakari foliage on the inner curve, and syndicate polki diamonds.',
        price: 175000,
        mrp: 210000,
        offerTag: 'Heritage Collection',
        categoryId: 'cat_bangles',
        categoryName: 'Bangles & Bracelets',
        images: const [
          'https://images.unsplash.com/photo-1611591475152-477028d7120a?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=800&auto=format&fit=crop&q=80',
        ],
        material: '22K Gold with Syndicate Polki & Meenakari',
        weight: '38.50 g',
        isAvailable: false, // Intentionally Out of stock!
        isFeatured: true,
        availableSizes: const ['2.4', '2.6'],
      ),

      // 11. Dancing Diamond Teardrop Pendant
      ProductModel(
        id: 'prod_teardrop_pendant',
        name: 'Dancing Diamond Teardrop Pendant',
        description:
            'A proprietary suspended diamond setting that catches micro-vibrations of your heartbeat, reflecting continuous sparkle in 18K rose gold.',
        price: 27500,
        mrp: 34000,
        offerTag: 'Valentine Special',
        categoryId: 'cat_chains',
        categoryName: 'Pendants & Chains',
        images: const [
          'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=800&auto=format&fit=crop&q=80',
        ],
        material: '18K Rose Gold with Floating Diamond',
        weight: '2.10 g',
        isAvailable: true,
        isFeatured: true,
        availableSizes: const ['Free Size (Pendant with 18" chain)'],
      ),

      // 12. Evil Eye Daily Wear Bracelet
      ProductModel(
        id: 'prod_evil_eye_bracelet',
        name: 'Contemporary Evil Eye Gold Bracelet',
        description:
            'Ward off negative energies in luxurious style. Handcrafted with genuine mother-of-pearl, blue turquoise enamel, and solid 18K yellow gold.',
        price: 22900,
        mrp: 29000,
        offerTag: 'Daily Wear',
        categoryId: 'cat_bangles',
        categoryName: 'Bangles & Bracelets',
        images: const [
          'https://images.unsplash.com/photo-1611591475152-477028d7120a?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1630019852942-f89202989a59?w=800&auto=format&fit=crop&q=80',
        ],
        material: '18K Yellow Gold with Turkish Turquoise Enamel',
        weight: '3.10 g',
        isAvailable: true,
        isFeatured: false,
        availableSizes: const ['6.5 inch', '7.0 inch', '7.5 inch (Adjustable)'],
      ),

      // 13. Kolhapuri Saaj Traditional Necklace (Live Rate)
      ProductModel(
        id: 'prod_kolhapuri_saaj',
        name: 'Traditional Kolhapuri Saaj Necklace',
        description:
            'Historic Maharashtrian bridal ornament containing 21 auspicious leaves and medallions depicting sun, moon, and Vishnu avatars.',
        price: 201600,
        mrp: 225000,
        offerTag: 'Festive Pride',
        categoryId: 'cat_necklaces',
        categoryName: 'Necklaces & Sets',
        images: const [
          'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=800&auto=format&fit=crop&q=80',
        ],
        material: '22K Hallmark Gold with 21 Paan Charms',
        weight: '28.00 g',
        metalType: 'gold_22k',
        metalWeight: 28.0,
        makingCharges: 5600,
        useDynamicRate: true,
        isAvailable: true,
        isFeatured: false,
        availableSizes: const ['Traditional 20 inch with Red Silk Cord'],
      ),

      // 14. 925 Silver Rose Gold Plated Infinity Anklet Pair
      ProductModel(
        id: 'prod_silver_anklet',
        name: 'Rose Gold Plated Infinity Silver Anklet (Pair)',
        description:
            'Hypoallergenic 925 sterling silver payal electroplated with 1-micron 18K rose gold and sparkling cubic zirconia pavé.',
        price: 4499,
        mrp: 6500,
        offerTag: 'Modern Silver',
        categoryId: 'cat_silver',
        categoryName: 'Silver Articles',
        images: const [
          'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1611591475152-477028d7120a?w=800&auto=format&fit=crop&q=80',
        ],
        material: '925 Sterling Silver with AAA+ Cubic Zirconia',
        weight: '14.20 g',
        isAvailable: true,
        isFeatured: false,
        availableSizes: const ['9.5 inch + 1 inch extension'],
      ),

      // 15. Men\'s Lion Head Signet Ring
      ProductModel(
        id: 'prod_mens_lion_ring',
        name: 'Men\'s Sovereign Lion Head Signet Ring',
        description:
            'A bold statement of royal authority. Features a sculptured 3D roaring lion head with vivid cabochon ruby eyes and hand-brushed matte shank.',
        price: 72000,
        mrp: 85000,
        offerTag: 'Men Luxury',
        categoryId: 'cat_rings',
        categoryName: 'Rings',
        images: const [
          'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?w=800&auto=format&fit=crop&q=80',
        ],
        material: '22K Two-Tone Matte & Gloss Gold with Ruby Eyes',
        weight: '11.80 g',
        isAvailable: true,
        isFeatured: false,
        availableSizes: const ['18', '20', '22', '24'],
      ),

      // 16. Floral Diamond Sui Dhaga Threader Earrings
      ProductModel(
        id: 'prod_sui_dhaga_earrings',
        name: 'Floral Diamond Sui Dhaga Threader Earrings',
        description:
            'Featherlight modern pull-through earrings terminating in delicate diamond blossom clusters that sway effortlessly with every step.',
        price: 29999,
        mrp: 38000,
        offerTag: 'Minimalist Chic',
        categoryId: 'cat_earrings',
        categoryName: 'Earrings & Jhumkas',
        images: const [
          'https://images.unsplash.com/photo-1630019852942-f89202989a59?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=800&auto=format&fit=crop&q=80',
        ],
        material: '18K Yellow Gold with Natural Round Brilliant Cut Diamonds',
        weight: '2.80 g',
        isAvailable: true,
        isFeatured: true,
        availableSizes: const ['Standard Drop (45mm)'],
      ),

      // 17. Lord Ganesha 999 Fine Silver Idol
      ProductModel(
        id: 'prod_ganesha_silver_idol',
        name: 'Lord Ganesha 999 Pure Silver Idol',
        description:
            'Divine consecrated silver murti of Lord Ganesha in sitting posture with modak and mushak, treated with Swiss anti-tarnish coating.',
        price: 13500,
        mrp: 18000,
        offerTag: 'Diwali Pooja Special',
        categoryId: 'cat_silver',
        categoryName: 'Silver Articles',
        images: const [
          'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1610375461246-83df859d849d?w=800&auto=format&fit=crop&q=80',
        ],
        material: '999 Pure Fine Silver with Anti-Tarnish Coating',
        weight: '150.00 g',
        isAvailable: true,
        isFeatured: false,
        availableSizes: const ['3.5 inch height with Velvet Gift Box'],
      ),

      // 18. Bridal Navratna Statement Choker Set
      ProductModel(
        id: 'prod_navratna_bridal_set',
        name: 'Bridal Navratna Statement Choker Set',
        description:
            'Grand royal bridal set featuring the 9 sacred cosmic gemstones (Ruby, Pearl, Coral, Emerald, Yellow Sapphire, Diamond, Blue Sapphire, Hessonite, Cat\'s Eye) with matching chandelier jhumkas.',
        price: 265000,
        mrp: 320000,
        offerTag: 'Royal Wedding Collection',
        categoryId: 'cat_necklaces',
        categoryName: 'Necklaces & Sets',
        images: const [
          'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1630019852942-f89202989a59?w=800&auto=format&fit=crop&q=80',
        ],
        material: '22K Yellow Gold with 9 Precious Gemstones & Matching Jhumkis',
        weight: '62.00 g',
        isAvailable: true,
        isFeatured: true,
        availableSizes: const ['Choker with Matching Jhumkas & Maang Tikka'],
      ),
    ];

    for (final prod in products) {
      final ref = _db.collection(FirestorePaths.products).doc(prod.id);
      batch.set(ref, prod.toMap(), SetOptions(merge: true));
    }

    await batch.commit();
    return products.length;
  }
}
