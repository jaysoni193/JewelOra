import 'package:flutter_test/flutter_test.dart';
import 'package:jewel_ora/models/app_settings_model.dart';
import 'package:jewel_ora/models/bridal_planner_model.dart';
import 'package:jewel_ora/models/diamond_guide_model.dart';
import 'package:jewel_ora/models/enquiry_model.dart';
import 'package:jewel_ora/models/metal_rate_model.dart';
import 'package:jewel_ora/models/gold_savings_scheme_model.dart';
import 'package:jewel_ora/models/occasion_reminder_model.dart';
import 'package:jewel_ora/models/price_alert_model.dart';
import 'package:jewel_ora/models/product_model.dart';
import 'package:jewel_ora/models/ring_size_model.dart';
import 'package:jewel_ora/models/vault_item_model.dart';
import 'package:jewel_ora/models/video_appointment_model.dart';
import 'package:jewel_ora/providers/bridal_planner_provider.dart';
import 'package:jewel_ora/providers/gold_savings_provider.dart';
import 'package:jewel_ora/providers/ring_size_provider.dart';
import 'package:jewel_ora/providers/video_appointment_provider.dart';
import 'package:jewel_ora/screens/user/widgets/gift_finder_sheet.dart';
import 'package:jewel_ora/screens/user/widgets/product_customizer_widget.dart';
import 'package:jewel_ora/models/app_notification_model.dart';
import 'package:jewel_ora/models/ar_try_on_model.dart';
import 'package:jewel_ora/services/certificate_verifier.dart';
import 'package:jewel_ora/services/notification_service.dart';
import 'package:jewel_ora/services/whatsapp_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Feature 1: Daily Gold and Silver Rates', () {
    test('MetalRateModel calculations and conversions', () {
      const rates = MetalRateModel(
        gold24k: 7450.0,
        gold22k: 6850.0,
        gold18k: 5600.0,
        silver1g: 92.5,
        gold24kChange: 25.0,
        silverChange: -1.2,
        isEnabled: true,
      );

      expect(rates.gold24k, 7450.0);
      expect(rates.gold22k, 6850.0);
      expect(rates.gold18k, 5600.0);
      expect(rates.silver10g, 925.0);
      expect(rates.silver1kg, 92500.0);
      expect(rates.getRateForType('gold_22k'), 6850.0);
      expect(rates.getRateForType('silver'), 92.5);
    });

    test('Product dynamic rate pricing with live metal rates', () {
      const rates = MetalRateModel(
        gold24k: 7500.0,
        gold22k: 6900.0,
        gold18k: 5650.0,
        silver1g: 90.0,
      );

      final product = ProductModel(
        id: 'p1',
        name: '22K Royal Gold Choker',
        categoryId: 'cat_gold',
        price: 50000.0, // fallback static price
        useDynamicRate: true,
        metalType: 'gold_22k',
        metalWeight: 10.0, // 10 grams
        makingCharges: 3500.0,
      );

      // 10g * 6900 + 3500 = 72,500
      final effectivePrice = product.getEffectivePrice(rates);
      expect(effectivePrice, 72500.0);
    });
  });

  group('Feature 2: Offers and Discount Badges', () {
    test('ProductModel discount percentage, MRP and savings', () {
      final product = ProductModel(
        id: 'p2',
        name: 'Diamond Solitaire Ring',
        categoryId: 'cat_diamond',
        price: 24000.0,
        mrp: 30000.0,
        offerTag: 'Diwali Sale',
      );

      expect(product.hasDiscount, isTrue);
      expect(product.discountPercent, 20); // (30000-24000)/30000 = 20%
      expect(product.savings, 6000.0);
      expect(product.offerTag, 'Diwali Sale');
    });

    test('Product without MRP has no discount flag', () {
      final product = ProductModel(
        id: 'p3',
        name: 'Silver Anklet',
        categoryId: 'cat_silver',
        price: 1500.0,
      );

      expect(product.hasDiscount, isFalse);
      expect(product.discountPercent, 0);
      expect(product.savings, 0.0);
    });
  });

  group('Feature 3: Store Information & Contact', () {
    test('AppSettingsModel contains store contact and location data', () {
      const settings = AppSettingsModel(
        appName: 'Jewel Ora Flagship',
        whatsappNumber: '919876543210',
        storeAddress: 'Shop 108, Zaveri Bazaar, Mumbai',
        mapUrl: 'https://maps.google.com/?q=Zaveri+Bazaar',
        storePhone: '+91 98765 43210',
        instagramHandle: 'jewelora.jewels',
        storeTimings: 'Mon - Sat: 10:30 AM - 8:30 PM',
        storeEmail: 'support@jewelora.com',
      );

      final map = settings.toMap();
      final fromMap = AppSettingsModel.fromMap(map);

      expect(fromMap.appName, 'Jewel Ora Flagship');
      expect(fromMap.storeAddress, 'Shop 108, Zaveri Bazaar, Mumbai');
      expect(fromMap.storePhone, '+91 98765 43210');
      expect(fromMap.instagramHandle, 'jewelora.jewels');
      expect(fromMap.storeTimings, 'Mon - Sat: 10:30 AM - 8:30 PM');
      expect(fromMap.storeEmail, 'support@jewelora.com');
    });
  });

  group('Feature 4: Enquiry History & Leads', () {
    test('EnquiryModel items breakdown and status display', () {
      const enquiry = EnquiryModel(
        id: 'ENQ12345',
        userId: 'u1',
        userName: 'Eleanor Vance',
        userPhone: '+91 98765 43210',
        items: [
          EnquiryItemModel(
            productId: 'p1',
            productName: 'Rose Gold Bracelet',
            productPrice: 12500.0,
            quantity: 2,
          ),
        ],
        totalAmount: 25000.0,
        status: 'quote_shared',
      );

      expect(enquiry.statusDisplay, 'Quote Shared');
      expect(enquiry.totalAmount, 25000.0);
      expect(enquiry.items.length, 1);
      expect(enquiry.items.first.productPrice, 12500.0);
      expect(enquiry.items.first.quantity, 2);
    });
  });

  group('Feature: Drop a Hint Gifting System', () {
    final product = ProductModel(
      id: 'p_ring_1',
      name: 'Solitaire Diamond Crown Ring',
      categoryId: 'cat_rings',
      price: 45000.0,
      material: '18K Rose Gold',
      weight: '3.4 g',
      images: ['https://res.cloudinary.com/demo/image/upload/sample.jpg'],
    );

    test('Builds charming hint message for Anniversary', () {
      final msg = WhatsAppService.buildHintMessage(
        product: product,
        price: 45000.0,
        size: '14 (US 7)',
        occasion: 'Anniversary',
        senderName: 'Priya',
        recipientName: 'Kunal',
        isAnonymous: false,
        customNote: 'In case you were wondering! 😉',
      );

      expect(msg, contains('Anniversary Whispering'));
      expect(msg, contains('Kunal, Priya has their heart set on this gorgeous jewellery piece'));
      expect(msg, contains('Solitaire Diamond Crown Ring'));
      expect(msg, contains('Preferred Size: 14 (US 7)'));
      expect(msg, contains('In case you were wondering! 😉'));
      expect(msg, contains('Take a look here:'));
    });

    test('Builds anonymous secret hint message', () {
      final msg = WhatsAppService.buildHintMessage(
        product: product,
        price: 45000.0,
        occasion: 'Birthday',
        senderName: 'Secret',
        recipientName: 'Aarav',
        isAnonymous: true,
      );

      expect(msg, contains('🎂 *Psst... It is hint time!*'));
      expect(msg, contains('Aarav, Someone who loves you 🤫 has their heart set on'));
      expect(msg, isNot(contains('Priya')));
    });
  });

  group('Feature: Old Gold Exchange Valuation System', () {
    const rates = MetalRateModel(
      gold24k: 7650.0,
      gold22k: 7015.0,
      gold18k: 5740.0,
      silver1g: 92.0,
    );

    test('22K Hallmark 100% Store Exchange Value', () {
      const grossWeight = 10.0; // 10 grams
      const stoneWeight = 0.0;
      final netWeight = grossWeight - stoneWeight;
      final ratePerGram = rates.gold22k;
      final valuation = netWeight * ratePerGram;

      expect(valuation, 70150.0); // 10 * 7015
    });

    test('Deducts non-gold stone weight accurately', () {
      const grossWeight = 16.5; // grams
      const stoneWeight = 1.5; // grams
      final netWeight = grossWeight - stoneWeight;
      final ratePerGram = rates.gold22k;
      final valuation = netWeight * ratePerGram;

      expect(netWeight, 15.0);
      expect(valuation, 105225.0); // 15 * 7015
    });

    test('Calculates 2% Melting Loss and 3% Cash Payout', () {
      const netWeight = 10.0;
      final grossValue = netWeight * rates.gold22k; // 70,150

      final meltingValue = grossValue * (1.0 - 0.02); // 2% melting
      final cashValue = grossValue * (1.0 - 0.03); // 3% cash

      expect(meltingValue, 68747.0);
      expect(cashValue, 68045.5);
    });

    test('Calculates 24K pure gold fine equivalent', () {
      const netWeight = 10.0;
      const purity22k = 0.9167;
      final pureGold = netWeight * purity22k;

      expect(pureGold, closeTo(9.167, 0.01));
    });
  });

  group('Feature: Interactive Metal & Diamond Customizer', () {
    const rates = MetalRateModel(
      gold24k: 7500.0,
      gold22k: 6900.0,
      gold18k: 5650.0,
      silver1g: 90.0,
    );

    final diamondRing = ProductModel(
      id: 'p_solitaire_1',
      name: 'Princess Cut Solitaire Diamond Ring',
      categoryId: 'cat_diamond_rings',
      price: 60000.0,
      useDynamicRate: true,
      metalType: 'gold_18k',
      metalWeight: 4.0, // 4 grams 18k
      makingCharges: 4000.0,
      material: '18K White Gold with Real Diamonds',
    );

    test('Detects diamond and metal characteristics accurately', () {
      expect(ProductCustomizerHelper.hasDiamonds(diamondRing), isTrue);
      expect(ProductCustomizerHelper.isSilver(diamondRing), isFalse);
    });

    test('Calculates live 18K base price for dynamic product', () {
      // 4g * 5650 + 4000 = 26,600
      final price18k = ProductCustomizerHelper.calculateCustomPrice(
        product: diamondRing,
        rates: rates,
        selectedPurity: '18K',
        selectedDiamondType: 'Natural (SI-IJ)',
      );
      expect(price18k, 26600.0);
    });

    test('Calculates live 22K upgrade price for dynamic product', () {
      // 4g * 6900 + 4000 = 31,600
      final price22k = ProductCustomizerHelper.calculateCustomPrice(
        product: diamondRing,
        rates: rates,
        selectedPurity: '22K',
        selectedDiamondType: 'Natural (SI-IJ)',
      );
      expect(price22k, 31600.0);
    });

    test('Applies 25% savings for Lab-Grown CVD Diamond option', () {
      // 26,600 * 0.75 = 19,950
      final priceLab = ProductCustomizerHelper.calculateCustomPrice(
        product: diamondRing,
        rates: rates,
        selectedPurity: '18K',
        selectedDiamondType: 'Lab-Grown (CVD)',
      );
      expect(priceLab, 19950.0);
    });

    test('Applies 15% premium for Natural VVS-GH Diamond option', () {
      // 26,600 * 1.15 = 30,590
      final priceVVS = ProductCustomizerHelper.calculateCustomPrice(
        product: diamondRing,
        rates: rates,
        selectedPurity: '18K',
        selectedDiamondType: 'Natural (VVS-GH)',
      );
      expect(priceVVS, closeTo(30590.0, 0.01));
    });
  });

  group('Feature: Curated Gift Finder & Occasion Stylist', () {
    const rates = MetalRateModel(
      gold24k: 7500.0,
      gold22k: 6900.0,
      gold18k: 5650.0,
      silver1g: 90.0,
    );

    final item1 = ProductModel(
      id: 'g1',
      name: 'Infinity Solitaire Diamond Ring',
      categoryId: 'rings',
      categoryName: 'Rings',
      price: 25000.0,
      material: '18K White Gold with Solitaire Diamond',
      description: 'Perfect romantic anniversary gift for her',
      isAvailable: true,
      isFeatured: true,
    );

    final item2 = ProductModel(
      id: 'g2',
      name: 'Men Royal Gold Chain Kada',
      categoryId: 'kada',
      categoryName: 'Men Kada',
      price: 28000.0,
      material: '22K Hallmark Gold',
      description: 'Bold kada bracelet for husband and men',
      isAvailable: true,
    );

    final item3 = ProductModel(
      id: 'g3',
      name: 'Silver Dainty Heart Pendant',
      categoryId: 'pendants',
      categoryName: 'Pendants',
      price: 3500.0,
      material: '925 Fine Silver',
      description: 'Cute lightweight pendant gift',
      isAvailable: true,
    );

    final item4 = ProductModel(
      id: 'g4',
      name: 'Royal Bridal Gold Choker Necklace',
      categoryId: 'necklaces',
      categoryName: 'Necklaces',
      price: 120000.0,
      material: '22K Gold',
      description: 'Grand bridal heritage necklace',
      isAvailable: true,
    );

    final item5OutOfStock = ProductModel(
      id: 'g5',
      name: 'Diamond Stud Earrings',
      categoryId: 'earrings',
      categoryName: 'Earrings',
      price: 22000.0,
      material: '18K Gold',
      description: 'Classic diamond earrings for wife',
      isAvailable: false, // Out of stock
    );

    final allItems = [item1, item2, item3, item4, item5OutOfStock];

    test('Filters strictly by budget and excludes unavailable items', () {
      final results = GiftFinderHelper.filterAndScore(
        products: allItems,
        rates: rates,
        recipientKeywords: ['ring', 'diamond'],
        occasionKeywords: ['anniversary'],
        minPrice: 15000.0,
        maxPrice: 35000.0,
      );

      // Only item1 and item2 fall into ₹15k - ₹35k. item5 is ₹22k but out of stock.
      expect(results.length, 2);
      expect(results.map((e) => e.id), containsAll(['g1', 'g2']));
      expect(results.any((e) => e.id == 'g5'), isFalse);
      expect(results.any((e) => e.id == 'g3'), isFalse);
      expect(results.any((e) => e.id == 'g4'), isFalse);
    });

    test('Ranks matching recipient and occasion keywords highest', () {
      final results = GiftFinderHelper.filterAndScore(
        products: allItems,
        rates: rates,
        recipientKeywords: ['ring', 'pendant', 'necklace', 'solitaire', 'diamond'],
        occasionKeywords: ['anniversary', 'solitaire', 'diamond', 'ring'],
        minPrice: 15000.0,
        maxPrice: 35000.0,
      );

      expect(results.first.id, 'g1'); // item1 matches ring, diamond, solitaire, anniversary
    });

    test('Handles open/any budget range', () {
      final results = GiftFinderHelper.filterAndScore(
        products: allItems,
        rates: rates,
        recipientKeywords: ['chain', 'bracelet', 'kada', 'men'],
        occasionKeywords: [],
        minPrice: null,
        maxPrice: null,
      );

      expect(results.any((e) => e.id == 'g2'), isTrue);
      expect(results.first.id, 'g2'); // Best match for men/kada
    });
  });

  group('Feature: Smart Gold Price Drop Alert System', () {
    const liveRates = MetalRateModel(
      gold24k: 7500.0,
      gold22k: 6900.0,
      gold18k: 5650.0,
      silver1g: 90.0,
      isEnabled: true,
    );

    test('Detects hit when live rate drops below target rate', () {
      final alert = PriceAlertModel(
        id: 'a1',
        metalType: 'gold_22k',
        targetRate: 6950.0, // Target is higher than current 6900
        createdAt: DateTime(2026, 1, 1),
      );

      expect(alert.checkHit(liveRates), isTrue);
    });

    test('Does not trigger when live rate is above target rate', () {
      final alert = PriceAlertModel(
        id: 'a2',
        metalType: 'gold_22k',
        targetRate: 6800.0, // Target is 6800, current is 6900
        createdAt: DateTime(2026, 1, 1),
      );

      expect(alert.checkHit(liveRates), isFalse);
    });

    test('Calculates drop difference and percentage required', () {
      final alert = PriceAlertModel(
        id: 'a3',
        metalType: 'gold_24k',
        targetRate: 7200.0, // Current is 7500
        createdAt: DateTime(2026, 1, 1),
      );

      final current = alert.getCurrentRate(liveRates); // 7500
      final diffPct = alert.percentageDiff(current); // (7200 - 7500) / 7500 * 100 = -4.0%

      expect(current, 7500.0);
      expect(diffPct, -4.0);
    });

    test('Supports Silver, 18K and 24K metal rate lookup', () {
      final silverAlert = PriceAlertModel(
        id: 's1',
        metalType: 'silver',
        targetRate: 85.0,
        createdAt: DateTime(2026, 1, 1),
      );

      final g18Alert = PriceAlertModel(
        id: 'g18',
        metalType: 'gold_18k',
        targetRate: 5600.0,
        createdAt: DateTime(2026, 1, 1),
      );

      expect(silverAlert.getCurrentRate(liveRates), 90.0);
      expect(silverAlert.metalLabel, '999 Fine Silver');
      expect(g18Alert.getCurrentRate(liveRates), 5650.0);
      expect(g18Alert.metalLabel, '18K Diamond Gold');
    });

    test('Serializes to and from JSON / Map accurately', () {
      final alert = PriceAlertModel(
        id: 'a_test',
        metalType: 'gold_22k',
        targetRate: 6850.0,
        createdAt: DateTime(2026, 5, 10, 14, 30),
        isActive: true,
        isTriggered: true,
        triggeredAt: DateTime(2026, 5, 11, 9, 0),
      );

      final jsonStr = alert.toJson();
      final decoded = PriceAlertModel.fromJson(jsonStr);

      expect(decoded.id, 'a_test');
      expect(decoded.metalType, 'gold_22k');
      expect(decoded.targetRate, 6850.0);
      expect(decoded.isActive, isTrue);
      expect(decoded.isTriggered, isTrue);
      expect(decoded.triggeredAt, isNotNull);
    });
  });

  group('Feature: Digital Jewellery Vault & Hallmark Verifier', () {
    const liveRates = MetalRateModel(
      gold24k: 7500.0,
      gold22k: 6900.0,
      gold18k: 5650.0,
      silver1g: 90.0,
      isEnabled: true,
    );

    test('VaultItemModel net weight deduction and live valuation', () {
      final item = VaultItemModel(
        id: 'v1',
        name: 'Royal Heritage 22K Gold Choker',
        category: 'Necklace',
        metalType: 'gold_22k',
        grossWeight: 15.5,
        stoneWeight: 0.5, // 15.0g net gold
        purchasePrice: 85000.0,
        purchaseDate: DateTime(2024, 1, 15),
        huidOrCert: 'HA8492',
      );

      expect(item.netWeight, 15.0);
      // 15.0g * 6900 = 103,500
      expect(item.getCurrentValuation(liveRates), 103500.0);
      // Gain: 103,500 - 85,000 = 18,500
      expect(item.getGain(liveRates), 18500.0);
      // Gain %: (18,500 / 85,000) * 100 = ~21.8%
      expect(item.getGainPercent(liveRates), closeTo(21.8, 0.1));
    });

    test('CertificateVerifier verifies authentic 6-digit BIS Hallmark HUID', () {
      final result = CertificateVerifier.verifyHuid('HA8492');

      expect(result.isValid, isTrue);
      expect(result.certType, 'BIS_HUID');
      expect(result.code, 'HA8492');
      expect(result.details['HUID Unique ID'], 'HA8492');
      expect(result.purity, contains('22K'));
      expect(result.errorMessage, isNull);
    });

    test('CertificateVerifier rejects malformed HUID codes', () {
      final shortCode = CertificateVerifier.verifyHuid('A123'); // only 4 chars
      final specialChar = CertificateVerifier.verifyHuid('AB@123'); // invalid character
      final longCode = CertificateVerifier.verifyHuid('HA84929'); // 7 chars

      expect(shortCode.isValid, isFalse);
      expect(specialChar.isValid, isFalse);
      expect(longCode.isValid, isFalse);
    });

    test('CertificateVerifier verifies IGI and GIA diamond certificates', () {
      final igi = CertificateVerifier.verifyDiamondCert('IGI-LG592810');
      final gia = CertificateVerifier.verifyDiamondCert('GIA-22194820');

      expect(igi.isValid, isTrue);
      expect(igi.certType, 'DIAMOND_CERT');
      expect(igi.authority, contains('IGI'));

      expect(gia.isValid, isTrue);
      expect(gia.authority, contains('GIA'));
    });

    test('VaultItemModel serializes to and from JSON Map accurately', () {
      final item = VaultItemModel(
        id: 'v_json',
        name: 'Solitaire Engagement Ring',
        category: 'Ring',
        metalType: 'gold_18k',
        grossWeight: 4.2,
        stoneWeight: 0.2,
        purchasePrice: 45000.0,
        purchaseDate: DateTime(2025, 2, 14),
        huidOrCert: 'IGI-LG98231',
        notes: 'Anniversary gift',
      );

      final jsonStr = item.toJson();
      final decoded = VaultItemModel.fromJson(jsonStr);

      expect(decoded.id, 'v_json');
      expect(decoded.name, 'Solitaire Engagement Ring');
      expect(decoded.category, 'Ring');
      expect(decoded.metalType, 'gold_18k');
      expect(decoded.grossWeight, 4.2);
      expect(decoded.stoneWeight, 0.2);
      expect(decoded.netWeight, 4.0);
      expect(decoded.purchasePrice, 45000.0);
      expect(decoded.huidOrCert, 'IGI-LG98231');
      expect(decoded.notes, 'Anniversary gift');
    });
  });

  group('Feature: Special Occasion & Gifting Reminder Calendar', () {
    final fixedToday = DateTime(2026, 5, 10); // 10 May 2026

    test('Calculates days until next occurrence when date is later this year', () {
      final reminder = OccasionReminderModel(
        id: 'r1',
        title: 'Wedding Anniversary',
        recipient: 'Spouse / Partner',
        month: 5,
        day: 20, // 10 days later: 20 May 2026
        year: 2020,
      );

      expect(reminder.daysUntilNext(fixedToday), 10);
      expect(reminder.isUpcoming(fixedToday, thresholdDays: 14), isTrue);
      expect(reminder.yearsCompleted(fixedToday), 6);
    });

    test('Calculates rollover to next year when date has already passed this year', () {
      final reminder = OccasionReminderModel(
        id: 'r2',
        title: "Mother's Birthday",
        recipient: 'Mother',
        month: 1,
        day: 15, // 15 Jan has passed for May 10, next is 15 Jan 2027
      );

      // From 10 May 2026 to 15 Jan 2027
      final nextYearDate = DateTime(2027, 1, 15);
      final expectedDays = nextYearDate.difference(DateTime(2026, 5, 10)).inDays;

      expect(reminder.daysUntilNext(fixedToday), expectedDays);
      expect(reminder.isUpcoming(fixedToday, thresholdDays: 14), isFalse);
    });

    test('Detects exact milestone day as 0 days left', () {
      final reminder = OccasionReminderModel(
        id: 'r3',
        title: 'Akshaya Tritiya',
        recipient: 'Family',
        month: 5,
        day: 10, // Exactly today
      );

      expect(reminder.daysUntilNext(fixedToday), 0);
      expect(reminder.isUpcoming(fixedToday, thresholdDays: 0), isTrue);
    });

    test('Serializes to and from JSON Map accurately', () {
      final reminder = OccasionReminderModel(
        id: 'r_test',
        title: 'Wife Birthday Surprise',
        recipient: 'Spouse / Partner',
        month: 12,
        day: 25,
        year: 1995,
        categoryHint: 'Rings & Solitaires',
        budget: 75000.0,
        notes: 'Loves Rose Gold',
      );

      final jsonStr = reminder.toJson();
      final decoded = OccasionReminderModel.fromJson(jsonStr);

      expect(decoded.id, 'r_test');
      expect(decoded.title, 'Wife Birthday Surprise');
      expect(decoded.recipient, 'Spouse / Partner');
      expect(decoded.month, 12);
      expect(decoded.day, 25);
      expect(decoded.year, 1995);
      expect(decoded.categoryHint, 'Rings & Solitaires');
      expect(decoded.budget, 75000.0);
      expect(decoded.notes, 'Loves Rose Gold');
    });
  });

  group('Feature: Monthly Gold Savings Scheme / Digi-Gold SIP (11+1 Plan)', () {
    test('GoldSavingsCalculator correctly computes contributions and bonus', () {
      const monthly = 5000.0;
      final customerPays = GoldSavingsCalculator.calculateCustomerTotal(monthly, 11);
      final storeBonus = GoldSavingsCalculator.calculateBonus(monthly);
      final totalMaturity = GoldSavingsCalculator.calculateTotalMaturity(monthly, 11);
      final estGrams = GoldSavingsCalculator.calculateEstGrams(monthly, 7500.0, 11);

      expect(customerPays, 55000.0);
      expect(storeBonus, 5000.0);
      expect(totalMaturity, 60000.0);
      expect(estGrams, closeTo(8.0, 0.001)); // 60,000 / 7,500 = 8.0 grams
    });

    test('GoldSavingsSchemeModel tracks installment progress and maturity status', () {
      final startDate = DateTime(2026, 1, 15);
      final plan = GoldSavingsSchemeModel(
        id: 'GSS-001',
        monthlyDeposit: 10000.0,
        totalTenureMonths: 11,
        monthsPaid: 3,
        startDate: startDate,
        customerName: 'Aarav Patel',
      );

      expect(plan.customerTotalContribution, 110000.0);
      expect(plan.storeBonusAmount, 10000.0);
      expect(plan.totalMaturityValue, 120000.0);
      expect(plan.amountPaidSoFar, 30000.0);
      expect(plan.remainingAmount, 80000.0);
      expect(plan.isMatured, isFalse);

      // 30,000 / 6,000 = 5.0 grams so far
      expect(plan.calculateGramsSoFar(6000.0), 5.0);
      // 120,000 / 6,000 = 20.0 grams at maturity
      expect(plan.calculateAccumulatedGrams(6000.0), 20.0);

      // Check next due date: 15 April 2026
      expect(plan.nextDueDate.month, 4);
      expect(plan.nextDueDate.day, 15);

      // Matured plan
      final maturedPlan = plan.copyWith(monthsPaid: 11);
      expect(maturedPlan.isMatured, isTrue);
      expect(maturedPlan.remainingAmount, 0.0);
      expect(maturedPlan.amountPaidSoFar, 110000.0);
    });

    test('GoldSavingsSchemeModel serializes and deserializes cleanly via JSON', () {
      final plan = GoldSavingsSchemeModel(
        id: 'GSS-999',
        monthlyDeposit: 25000.0,
        totalTenureMonths: 11,
        monthsPaid: 5,
        startDate: DateTime(2026, 3, 1),
        lastPaymentDate: DateTime(2026, 7, 1),
        planName: 'Swarna Nidhi Elite Plan',
        customerName: 'Priya Sharma',
        customerPhone: '+91 98765 43210',
      );

      final jsonStr = plan.toJson();
      final decoded = GoldSavingsSchemeModel.fromJson(jsonStr);

      expect(decoded.id, 'GSS-999');
      expect(decoded.monthlyDeposit, 25000.0);
      expect(decoded.totalTenureMonths, 11);
      expect(decoded.monthsPaid, 5);
      expect(decoded.planName, 'Swarna Nidhi Elite Plan');
      expect(decoded.customerName, 'Priya Sharma');
      expect(decoded.customerPhone, '+91 98765 43210');
      expect(decoded.amountPaidSoFar, 125000.0);
      expect(decoded.storeBonusAmount, 25000.0);
      expect(decoded.totalMaturityValue, 300000.0);
    });

    test('GoldSavingsProvider manages plan enrollment, payments and cancellation', () async {
      final provider = GoldSavingsProvider();
      expect(provider.hasActivePlan, isFalse);
      expect(provider.activePlan, isNull);

      final newPlan = GoldSavingsSchemeModel(
        id: 'GSS-TEST-1',
        monthlyDeposit: 5000.0,
        monthsPaid: 1,
        startDate: DateTime.now(),
      );

      await provider.enrollPlan(newPlan);
      expect(provider.hasActivePlan, isTrue);
      expect(provider.activePlan?.id, 'GSS-TEST-1');
      expect(provider.activePlan?.monthsPaid, 1);

      // Pay next installment
      await provider.payInstallment('GSS-TEST-1');
      expect(provider.activePlan?.monthsPaid, 2);

      // Cancel plan
      await provider.cancelPlan('GSS-TEST-1');
      expect(provider.hasActivePlan, isFalse);
      expect(provider.activePlan, isNull);
    });
  });

  group('Feature: Virtual Live Video Shopping & Stylist Appointment Booking', () {
    final fixedToday = DateTime(2026, 6, 1);

    test('VideoAppointmentModel calculates daysUntil and isUpcoming status accurately', () {
      final futureDate = DateTime(2026, 6, 5); // 4 days later
      final appt = VideoAppointmentModel(
        id: 'VSA-101',
        customerName: 'Meera Shah',
        customerPhone: '+91 98222 11111',
        categoryInterest: 'Bridal Polki & Kundan',
        preferredLanguage: 'Gujarati (ગુજરાતી)',
        appointmentDate: futureDate,
        timeSlot: '02:00 PM - 02:45 PM',
        platform: 'WhatsApp Video',
        createdAt: fixedToday,
      );

      expect(appt.daysUntil(fixedToday), 4);
      expect(appt.categoryInterest, 'Bridal Polki & Kundan');
      expect(appt.preferredLanguage, 'Gujarati (ગુજરાતી)');
      expect(appt.platform, 'WhatsApp Video');

      // Cancelled appointment is not upcoming
      final cancelled = appt.copyWith(status: 'cancelled');
      expect(cancelled.isUpcoming, isFalse);
    });

    test('VideoAppointmentModel presets and configuration list validation', () {
      expect(VideoAppointmentModel.availableCategories, contains('Bridal Polki & Kundan'));
      expect(VideoAppointmentModel.availableCategories, contains('Solitaire & Diamond Rings'));
      expect(VideoAppointmentModel.availableLanguages, contains('Hindi (हिंदी)'));
      expect(VideoAppointmentModel.availableTimeSlots.length, greaterThanOrEqualTo(4));
      expect(VideoAppointmentModel.availablePlatforms, containsAll(['WhatsApp Video', 'Google Meet']));
    });

    test('VideoAppointmentModel serializes and deserializes cleanly via JSON', () {
      final appt = VideoAppointmentModel(
        id: 'VSA-888',
        customerName: 'Kavita Joshi',
        customerPhone: '+91 99888 77665',
        categoryInterest: 'Antique Temple Jewellery',
        preferredLanguage: 'Hindi (हिंदी)',
        appointmentDate: DateTime(2026, 7, 10),
        timeSlot: '04:00 PM - 04:45 PM',
        platform: 'Google Meet',
        notes: 'Looking for bridal necklace sets for daughter wedding',
        createdAt: DateTime(2026, 6, 1),
      );

      final jsonStr = appt.toJson();
      final decoded = VideoAppointmentModel.fromJson(jsonStr);

      expect(decoded.id, 'VSA-888');
      expect(decoded.customerName, 'Kavita Joshi');
      expect(decoded.customerPhone, '+91 99888 77665');
      expect(decoded.categoryInterest, 'Antique Temple Jewellery');
      expect(decoded.preferredLanguage, 'Hindi (हिंदी)');
      expect(decoded.timeSlot, '04:00 PM - 04:45 PM');
      expect(decoded.platform, 'Google Meet');
      expect(decoded.notes, 'Looking for bridal necklace sets for daughter wedding');
      expect(decoded.status, 'confirmed');
    });

    test('VideoAppointmentProvider manages booking, sorting and cancellation', () async {
      final provider = VideoAppointmentProvider();
      expect(provider.hasUpcoming, isFalse);
      expect(provider.nextUpcomingAppointment, isNull);

      final appt1 = VideoAppointmentModel(
        id: 'VSA-TEST-1',
        customerName: 'Aanya',
        customerPhone: '9876543210',
        categoryInterest: 'Daily Wear Gold & Chains',
        appointmentDate: DateTime.now().add(const Duration(days: 3)),
        timeSlot: '11:00 AM - 11:45 AM',
        createdAt: DateTime.now(),
      );

      final appt2 = VideoAppointmentModel(
        id: 'VSA-TEST-2',
        customerName: 'Aanya',
        customerPhone: '9876543210',
        categoryInterest: 'Solitaire & Diamond Rings',
        appointmentDate: DateTime.now().add(const Duration(days: 1)),
        timeSlot: '02:00 PM - 02:45 PM',
        createdAt: DateTime.now(),
      );

      await provider.bookAppointment(appt1);
      await provider.bookAppointment(appt2);

      expect(provider.hasUpcoming, isTrue);
      expect(provider.upcomingAppointments.length, 2);
      // Earliest date first: appt2 is 1 day away, appt1 is 3 days away
      expect(provider.nextUpcomingAppointment?.id, 'VSA-TEST-2');

      // Cancel the earliest appointment
      await provider.cancelAppointment('VSA-TEST-2');
      expect(provider.upcomingAppointments.length, 1);
      expect(provider.nextUpcomingAppointment?.id, 'VSA-TEST-1');

      // Delete the remaining appointment
      await provider.deleteAppointment('VSA-TEST-1');
      expect(provider.hasUpcoming, isFalse);
      expect(provider.nextUpcomingAppointment, isNull);
    });
  });

  group('Feature 10: Diamond 4Cs & Solitaire Grading Guide', () {
    test('Calculates accurate millimeter diameter for round brilliant solitaire', () {
      final dia1ct = DiamondGuideCalculator.calculateDiameterMm(1.0);
      expect(dia1ct, closeTo(6.5, 0.05));

      final diaHalfCt = DiamondGuideCalculator.calculateDiameterMm(0.5);
      expect(diaHalfCt, closeTo(5.16, 0.05));

      final dia2ct = DiamondGuideCalculator.calculateDiameterMm(2.0);
      expect(dia2ct, closeTo(8.19, 0.05));

      expect(DiamondGuideCalculator.calculateDiameterMm(0), 0.0);
    });

    test('Estimates benchmark solitaire price with non-linear rarity curve', () {
      final price1ct = DiamondGuideCalculator.estimateBenchmarkPrice(
        carat: 1.0,
        cutId: 'excellent',
        colorId: 'd_f',
        clarityId: 'vvs',
      );
      expect(price1ct, greaterThan(100000.0));

      final priceSi = DiamondGuideCalculator.estimateBenchmarkPrice(
        carat: 1.0,
        cutId: 'good',
        colorId: 'i_j',
        clarityId: 'si',
      );
      // SI and Good cut should cost significantly less than Excellent D-F VVS
      expect(priceSi, lessThan(price1ct));

      // 2 carat diamond should cost more than double of 1 carat due to geometric rarity
      final price2ct = DiamondGuideCalculator.estimateBenchmarkPrice(
        carat: 2.0,
        cutId: 'excellent',
        colorId: 'd_f',
        clarityId: 'vvs',
      );
      expect(price2ct, greaterThan(price1ct * 2.5));
    });

    test('Calculates sparkle rating based on cut and clarity', () {
      final topSparkle = DiamondGuideCalculator.calculateSparkleRating('excellent', 'fl_if');
      expect(topSparkle, closeTo(99, 1));

      final midSparkle = DiamondGuideCalculator.calculateSparkleRating('good', 'si');
      expect(midSparkle, lessThan(topSparkle));
      expect(midSparkle, greaterThanOrEqualTo(60));
    });

    test('Retrieves 4Cs entities with fallback safety', () {
      final cut = DiamondCut.getById('very_good');
      expect(cut.label, 'Very Good Cut');
      expect(DiamondCut.getById('non_existent').id, 'excellent');

      final color = DiamondColor.getById('g_h');
      expect(color.grade, 'G - H');
      expect(DiamondColor.getById('non_existent').id, 'd_f');

      final clarity = DiamondClarity.getById('vvs');
      expect(clarity.grade, 'VVS1 - VVS2');
      expect(DiamondClarity.getById('non_existent').id, 'fl_if');
    });
  });

  group('Feature 11: Bridal Trousseau & Wedding Jewellery Budget Planner', () {
    test('Calculates budget progress, remaining balance, and gold weights correctly', () {
      final items = [
        const BridalItem(
          id: 'item_1',
          ceremonyId: 'engagement',
          name: 'Solitaire Ring',
          category: 'Rings',
          estimatedBudget: 80000.0,
          actualSpend: 85000.0,
          isPurchased: true,
          targetGoldGrams: 4.5,
        ),
        const BridalItem(
          id: 'item_2',
          ceremonyId: 'wedding_day',
          name: 'Bridal Choker',
          category: 'Necklace',
          estimatedBudget: 250000.0,
          isPurchased: false,
          targetGoldGrams: 35.0,
        ),
      ];

      final profile = BridalPlannerProfile(
        brideName: 'Aanya',
        totalBudget: 500000.0,
        weddingDate: DateTime.now().add(const Duration(days: 45)),
        items: items,
      );

      // Estimated spend: 80,000 + 250,000 = 330,000
      expect(profile.totalEstimatedSpend, 330000.0);

      // Purchased spend: 85,000
      expect(profile.totalPurchasedSpend, 85000.0);

      // Remaining budget: 500,000 - 85,000 = 415,000
      expect(profile.remainingBudget, 415000.0);
      expect(profile.isOverBudget, isFalse);

      // Total items: 2, purchased: 1
      expect(profile.totalItemsCount, 2);
      expect(profile.purchasedCount, 1);
      expect(profile.completionPercentage, 0.5);

      // Gold weight: 4.5g purchased / 39.5g total
      expect(profile.purchasedGoldGrams, 4.5);
      expect(profile.totalGoldGrams, 39.5);

      // Countdown
      expect(profile.daysUntilWedding, 45);

      // Ceremony items
      expect(profile.itemsForCeremony('engagement').length, 1);
      expect(profile.itemsForCeremony('wedding_day').length, 1);
      expect(profile.itemsForCeremony('sangeet').length, 0);
    });

    test('Detects over-budget scenario when actual spend exceeds budget', () {
      final overItems = [
        const BridalItem(
          id: 'item_heavy',
          ceremonyId: 'wedding_day',
          name: 'Heavy Polki Haar',
          category: 'Necklace',
          estimatedBudget: 600000.0,
          actualSpend: 620000.0,
          isPurchased: true,
        ),
      ];

      final profile = BridalPlannerProfile(
        brideName: 'Rhea',
        totalBudget: 500000.0,
        items: overItems,
      );

      expect(profile.totalPurchasedSpend, 620000.0);
      expect(profile.remainingBudget, -120000.0);
      expect(profile.isOverBudget, isTrue);
      expect(profile.budgetUtilizationPercentage, 1.0);
    });

    test('Starter heritage trousseau checklist contains complete ceremony pieces', () {
      final starter = BridalPlannerProfile.starterHeritageItems();
      expect(starter.length, 12);

      // Checks that each of the 5 ceremonies has at least one piece
      for (final ceremony in BridalCeremony.all) {
        final matches = starter.where((i) => i.ceremonyId == ceremony.id);
        expect(matches.isNotEmpty, isTrue, reason: 'Missing items for ceremony: ${ceremony.id}');
      }
    });

    test('BridalPlannerProfile serializes and deserializes accurately via JSON', () {
      final profile = BridalPlannerProfile(
        brideName: 'Priya & Vikram',
        totalBudget: 1200000.0,
        weddingDate: DateTime(2027, 2, 14),
        items: const [
          BridalItem(
            id: 'bi_test_1',
            ceremonyId: 'reception',
            name: 'Diamond Collar',
            category: 'Necklace',
            estimatedBudget: 150000.0,
            targetGoldGrams: 14.0,
            notes: 'VVS diamonds preferred',
          ),
        ],
      );

      final json = profile.toJson();
      final decoded = BridalPlannerProfile.fromJson(json);

      expect(decoded.brideName, 'Priya & Vikram');
      expect(decoded.totalBudget, 1200000.0);
      expect(decoded.weddingDate?.year, 2027);
      expect(decoded.items.length, 1);
      expect(decoded.items.first.name, 'Diamond Collar');
      expect(decoded.items.first.notes, 'VVS diamonds preferred');
    });

    test('BridalPlannerProvider manages items, purchased state, and updates', () async {
      final provider = BridalPlannerProvider();
      await provider.createOrUpdateProfile(
        brideName: 'Ananya',
        totalBudget: 800000.0,
        includeStarterTemplate: false,
      );

      expect(provider.hasProfile, isTrue);
      expect(provider.profile?.items.isEmpty, isTrue);

      const newItem = BridalItem(
        id: 'bi_custom_1',
        ceremonyId: 'sangeet',
        name: 'Cocktail Chandelier Earrings',
        category: 'Earrings',
        estimatedBudget: 75000.0,
      );

      await provider.addItem(newItem);
      expect(provider.profile?.items.length, 1);
      expect(provider.profile?.items.first.isPurchased, isFalse);

      // Mark purchased
      await provider.togglePurchased('bi_custom_1', actualSpend: 72000.0);
      expect(provider.profile?.items.first.isPurchased, isTrue);
      expect(provider.profile?.items.first.actualSpend, 72000.0);
      expect(provider.profile?.totalPurchasedSpend, 72000.0);

      // Update item
      final updatedItem = provider.profile!.items.first.copyWith(notes: 'Rose gold polish');
      await provider.updateItem(updatedItem);
      expect(provider.profile?.items.first.notes, 'Rose gold polish');

      // Delete item
      await provider.deleteItem('bi_custom_1');
      expect(provider.profile?.items.isEmpty, isTrue);

      // Reset
      await provider.resetPlanner();
      expect(provider.hasProfile, isFalse);
    });
  });

  group('Feature 12: Interactive Physical Screen Ring & Bangle Sizer', () {
    test('RingSizeData.findClosest matches diameters to Indian, US and UK sizes accurately', () {
      final ring14 = RingSizeData.findClosest(17.3);
      expect(ring14.indiaSize, '14');
      expect(ring14.usSize, '7.0');
      expect(ring14.ukSize, 'N 1/2');
      expect(ring14.circumferenceMm, 54.3);

      final ring10 = RingSizeData.findClosest(16.1);
      expect(ring10.indiaSize, '10');
      expect(ring10.usSize, '5.5');

      final ring18 = RingSizeData.findClosest(18.5);
      expect(ring18.indiaSize, '18');
      expect(ring18.usSize, '8.5');

      // Boundary values
      final smallRing = RingSizeData.findClosest(13.0);
      expect(smallRing.indiaSize, '6');

      final largeRing = RingSizeData.findClosest(25.0);
      expect(largeRing.indiaSize, '28');
    });

    test('BangleSizeData.findClosest matches diameters to standard Indian bangle notations', () {
      final bangle26 = BangleSizeData.findClosest(60.3);
      expect(bangle26.notation, '2-6');
      expect(bangle26.inches, '2.375 in');
      expect(bangle26.fitDescription, contains('Medium'));

      final bangle22 = BangleSizeData.findClosest(54.0);
      expect(bangle22.notation, '2-2');

      final bangle210 = BangleSizeData.findClosest(66.7);
      expect(bangle210.notation, '2-10');
    });

    test('ScreenCalibrationConstants defines authentic real-world dimensions', () {
      expect(ScreenCalibrationConstants.creditCardWidthMm, 85.60);
      expect(ScreenCalibrationConstants.creditCardHeightMm, 53.98);
      expect(ScreenCalibrationConstants.coin5RupeeDiameterMm, 23.00);
      expect(ScreenCalibrationConstants.defaultPixelsPerMm, 6.30);
    });

    test('RingSizeProvider calibrates PPI, stores sizes and resets scale', () async {
      final provider = RingSizeProvider();
      expect(provider.pixelsPerMm, ScreenCalibrationConstants.defaultPixelsPerMm);
      expect(provider.isCalibrated, isFalse);

      // Calibrate with credit card (e.g. 540 pixels measured)
      await provider.calibrateWithCreditCard(540.0);
      expect(provider.isCalibrated, isTrue);
      // 540 / 85.60 ≈ 6.308
      expect(provider.pixelsPerMm, closeTo(6.308, 0.05));

      // Save user sizes
      await provider.saveUserRingSize('14');
      await provider.saveUserBangleSize('2-6');
      expect(provider.savedRingSize, '14');
      expect(provider.savedBangleSize, '2-6');

      // Calibrate with ₹5 coin (e.g. 145 pixels measured)
      await provider.calibrateWithCoin(145.0);
      // 145 / 23.0 ≈ 6.304
      expect(provider.pixelsPerMm, closeTo(6.304, 0.05));

      // Reset calibration restores default
      await provider.resetCalibration();
      expect(provider.pixelsPerMm, ScreenCalibrationConstants.defaultPixelsPerMm);
      expect(provider.isCalibrated, isFalse);
    });
  });

  group('Feature 13: Push Notifications (FCM) & Automated Drop Triggers', () {
    test('AppNotificationModel serializes and deserializes accurately', () {
      final now = DateTime(2026, 10, 16, 12, 0);
      final notification = AppNotificationModel(
        id: 'notif_123',
        title: '⚡ Gold Rate Dropped! ₹45/g Down Today',
        body: 'Today\'s 22K Gold rate dropped to ₹6850/g. Lock your jewellery now before rates rise!',
        topic: NotificationService.topicGoldDrop,
        type: 'rate_drop',
        timestamp: now,
        isRead: false,
        payload: const {'route': '/metal_rates', 'newRate': 6850.0},
      );

      final map = notification.toMap();
      expect(map['id'], 'notif_123');
      expect(map['title'], contains('Gold Rate Dropped'));
      expect(map['topic'], 'gold_price_drops');
      expect(map['type'], 'rate_drop');
      expect(map['isRead'], false);

      final reconstructed = AppNotificationModel.fromMap(map, 'notif_123');
      expect(reconstructed.id, 'notif_123');
      expect(reconstructed.title, notification.title);
      expect(reconstructed.body, notification.body);
      expect(reconstructed.topic, NotificationService.topicGoldDrop);
      expect(reconstructed.type, 'rate_drop');
    });

    test('Topic constants and payload structure validate cleanly', () {
      expect(NotificationService.topicGoldDrop, 'gold_price_drops');
      expect(NotificationService.topicNewCollection, 'new_collections');
      expect(NotificationService.topicFestiveOffers, 'festive_offers');
      expect(NotificationService.topicGeneral, 'general');
    });
  });

  group('Feature 14: AR Virtual Try-On for Earrings & Necklaces', () {
    test('ArTryOnItem curated items contains comprehensive earrings and necklaces', () {
      final items = ArTryOnItem.curatedItems;
      expect(items.isNotEmpty, isTrue);

      final earrings = items.where((i) => i.type == ArItemType.earrings).toList();
      final necklaces = items.where((i) => i.type == ArItemType.necklace).toList();

      expect(earrings.length, greaterThanOrEqualTo(4));
      expect(necklaces.length, greaterThanOrEqualTo(4));

      for (final e in earrings) {
        expect(e.imageUrl, isNotEmpty);
        expect(e.earringSpacing, inInclusiveRange(140.0, 190.0));
        expect(e.defaultScale, inInclusiveRange(0.5, 2.0));
      }

      for (final n in necklaces) {
        expect(n.imageUrl, isNotEmpty);
        expect(n.defaultOffsetY, greaterThan(0.0)); // Necklaces drape below chin
        expect(n.defaultScale, inInclusiveRange(0.5, 2.0));
      }
    });

    test('ArTryOnItem.fromProduct converts jewellery correctly and rejects non-earring/necklace items', () {
      const earringProduct = ProductModel(
        id: 'p_earring_1',
        name: 'Heritage Chandbali Jhumka',
        categoryId: 'cat_earrings',
        categoryName: 'Earrings & Jhumkas',
        price: 45000,
        images: ['https://example.com/earring.png'],
      );
      final earringTryOn = ArTryOnItem.fromProduct(earringProduct);
      expect(earringTryOn, isNotNull);
      expect(earringTryOn!.type, ArItemType.earrings);
      expect(earringTryOn.name, 'Heritage Chandbali Jhumka');

      const necklaceProduct = ProductModel(
        id: 'p_necklace_1',
        name: 'Royal Polki Choker Necklace',
        categoryId: 'cat_necklaces',
        categoryName: 'Necklaces & Sets',
        price: 125000,
        images: ['https://example.com/necklace.png'],
      );
      final necklaceTryOn = ArTryOnItem.fromProduct(necklaceProduct);
      expect(necklaceTryOn, isNotNull);
      expect(necklaceTryOn!.type, ArItemType.necklace);
      expect(necklaceTryOn.name, 'Royal Polki Choker Necklace');

      // A ring or gold coin is NOT an earring or necklace
      const ringProduct = ProductModel(
        id: 'p_ring_1',
        name: 'Solitaire Diamond Band',
        categoryId: 'cat_rings',
        categoryName: 'Rings',
        price: 28000,
      );
      expect(ArTryOnItem.fromProduct(ringProduct), isNull);

      const coinProduct = ProductModel(
        id: 'p_coin_1',
        name: '10g 24K Laxmi Gold Coin',
        categoryId: 'cat_coins',
        categoryName: 'Gold Coins & Bars',
        price: 76000,
      );
      expect(ArTryOnItem.fromProduct(coinProduct), isNull);
    });
  });
}





