import 'package:flutter_test/flutter_test.dart';
import 'package:jewel_ora/models/app_settings_model.dart';
import 'package:jewel_ora/models/enquiry_model.dart';
import 'package:jewel_ora/models/metal_rate_model.dart';
import 'package:jewel_ora/models/product_model.dart';

void main() {
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
}
