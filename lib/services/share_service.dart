import 'package:flutter/cupertino.dart';
import 'package:jewel_ora/core/config/app_links.dart';
import 'package:jewel_ora/core/errors/app_exception.dart';
import 'package:jewel_ora/core/utils/formatters.dart';
import 'package:jewel_ora/core/utils/image_url.dart';
import 'package:jewel_ora/models/product_model.dart';
import 'package:jewel_ora/services/whatsapp_service.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  ShareService._();

  /// The text that friends receive. *Asterisks* make bold text in WhatsApp.
  static String buildProductText(
    ProductModel p, {
    required String shopName,
    String whatsappNumber = '',
  }) {
    final number = WhatsAppService.cleanNumber(whatsappNumber);

    final lines = <String>[
      'Look at this beautiful piece from $shopName:',
      '',
      '*${p.name}*',
      'Price: ${Formatters.price(p.price)}',
      if (p.categoryName.isNotEmpty) 'Category: ${p.categoryName}',
      if (p.material.isNotEmpty) 'Material: ${p.material}',
      if (p.weight.isNotEmpty) 'Weight: ${p.weight}',
      if (p.firstImage.isNotEmpty) ...[
        '',
        'Photo: ${ImageUrl.shareable(p.firstImage)}',
      ],
      if (number.isNotEmpty) ...['', 'Chat with us: https://wa.me/$number'],
      if (AppLinks.storeUrl.isNotEmpty) ...[
        '',
        'Get our app: ${AppLinks.storeUrl}',
      ],
    ];
    return lines.join('\n');
  }

  /// Opens the phone's share menu.
  /// Throws [AppException] with a friendly message if it cannot.
  static Future<void> shareProduct(
    ProductModel p, {
    required String shopName,
    String whatsappNumber = '',
  }) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: buildProductText(
            p,
            shopName: shopName,
            whatsappNumber: whatsappNumber,
          ),
          subject: p.name, // used by email apps as the subject line
        ),
      );
    } catch (e, st) {
      debugPrint('Share failed: $e\n$st');
      throw const AppException('Could not open the share menu.');
    }
  }
}
