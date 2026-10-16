import 'package:jewel_ora/core/errors/app_exception.dart';
import 'package:jewel_ora/core/utils/formatters.dart';
import 'package:jewel_ora/core/utils/image_url.dart';
import 'package:jewel_ora/models/product_model.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  WhatsAppService._();

  /// wa.me links accept digits only (country code included, no + sign).
  static String cleanNumber(String raw) => raw.replaceAll(RegExp(r'\D'), '');

  /// The text that is pre-filled in the chat for a single product enquiry.
  /// Formatted cleanly with bold asterisks and explicit jewellery size.
  static String buildProductMessage(
    ProductModel p, {
    String customerName = '',
    String? selectedSize,
    String? size,
  }) {
    final effectiveSize = (selectedSize != null && selectedSize.isNotEmpty)
        ? selectedSize
        : size;
    final lines = <String>[
      'Hello! I am interested in this jewellery piece:',
      '',
      '*${p.name}*',
      'Price: ${Formatters.price(p.price)}',
      if (effectiveSize != null && effectiveSize.isNotEmpty)
        '*Selected Size / Dimensions: $effectiveSize*',
      if (p.categoryName.isNotEmpty) 'Category: ${p.categoryName}',
      if (p.material.isNotEmpty) 'Material: ${p.material}',
      if (p.weight.isNotEmpty) 'Weight: ${p.weight}',
      if (p.metalType != null && p.metalType!.isNotEmpty)
        'Purity: ${p.metalType!.replaceAll('_', ' ').toUpperCase()}',
      if (p.firstImage.isNotEmpty) ...[
        '',
        'Image: ${ImageUrl.shareable(p.firstImage)}',
      ],
      if (customerName.isNotEmpty) ...['', '- $customerName'],
    ];
    return lines.join('\n');
  }

  /// Opens a WhatsApp chat with [phone] and the message pre-filled.
  /// Throws [AppException] with a friendly message if it cannot.
  static Future<void> open({
    required String phone,
    required String message,
  }) async {
    final number = cleanNumber(phone);
    if (number.isEmpty) {
      throw const AppException(
        'The shop has not set a WhatsApp number yet. Please try again later.',
      );
    }

    final uri = Uri.parse(
      'https://wa.me/$number?text=${Uri.encodeComponent(message)}',
    );

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) throw const AppException('Could not open WhatsApp.');
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException('Could not open WhatsApp.');
    }
  }

  /// One message for the whole cart with sizes for each item.
  static String buildCartMessage(
    List<({ProductModel product, int quantity, String? size, double? price})> lines, {
    String customerName = '',
  }) {
    var total = 0.0;
    final out = <String>[
      'Hello! I would like to enquire about these pieces from your catalogue:',
      '',
    ];

    for (var i = 0; i < lines.length; i++) {
      final p = lines[i].product;
      final q = lines[i].quantity;
      final s = lines[i].size;
      final itemPrice = lines[i].price ?? p.price;
      final lineTotal = itemPrice * q;
      total += lineTotal;

      out.add('${i + 1}. *${p.name}*');
      final details = [
        if (s != null && s.isNotEmpty) 'Size: $s',
        p.categoryName,
        p.material,
        p.weight,
      ].where((e) => e.isNotEmpty).join(' | ');
      if (details.isNotEmpty) out.add('   $details');
      out.add('   Qty: $q x ${Formatters.price(itemPrice)} = '
          '${Formatters.price(lineTotal)}');
      out.add('');
    }

    out.add('*Estimated total: ${Formatters.price(total)}*');
    if (customerName.isNotEmpty) out.addAll(['', '- $customerName']);
    return out.join('\n');
  }

  /// Message builder for Custom Jewellery Orders
  static String buildCustomOrderMessage({
    required String metal,
    required String budget,
    required String size,
    required String description,
    required String imageUrl,
    String customerName = '',
  }) {
    final lines = <String>[
      'Hello Jewel Ora! I would like to place a *Custom Jewellery Request*:',
      '',
      if (metal.isNotEmpty) '*Preferred Metal:* $metal',
      if (budget.isNotEmpty) '*Estimated Budget:* $budget',
      if (size.isNotEmpty) '*Preferred Size / Dimensions:* $size',
      if (description.isNotEmpty) ...[
        '',
        '*Design Notes:*',
        description,
      ],
      if (imageUrl.isNotEmpty) ...[
        '',
        '*Reference Image:* $imageUrl',
      ],
      if (customerName.isNotEmpty) ...['', '- $customerName'],
    ];
    return lines.join('\n');
  }

  /// Message builder for Store Visit Appointment Booking
  static String buildBookVisitMessage({
    required String date,
    required String timeSlot,
    required String category,
    int guests = 1,
    String notes = '',
    String customerName = '',
  }) {
    final lines = <String>[
      'Hello Jewel Ora! I would like to *Book an In-Store Experience Visit*:',
      '',
      '*Date:* $date',
      '*Time Slot:* $timeSlot',
      '*Interested Category:* $category',
      '*Number of Guests:* $guests',
      if (notes.isNotEmpty) ...[
        '',
        '*Special Requests / Notes:*',
        notes,
      ],
      if (customerName.isNotEmpty) ...['', '- $customerName'],
    ];
    return lines.join('\n');
  }

  /// Opens WhatsApp with [message] pre-filled.
  /// If [phone] is given and non-empty, opens direct chat with that number.
  /// Otherwise opens WhatsApp's contact picker so user can pick any friend/partner.
  static Future<void> shareMessage({
    String? phone,
    required String message,
  }) async {
    final number = phone != null ? cleanNumber(phone) : '';
    final Uri uri = number.isNotEmpty
        ? Uri.parse('https://wa.me/$number?text=${Uri.encodeComponent(message)}')
        : Uri.parse('https://api.whatsapp.com/send?text=${Uri.encodeComponent(message)}');

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) throw const AppException('Could not open WhatsApp.');
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException('Could not open WhatsApp.');
    }
  }

  /// Builds an enchanting gift hint message for WhatsApp or social sharing
  static String buildHintMessage({
    required ProductModel product,
    required double price,
    String? size,
    required String occasion,
    required String senderName,
    required String recipientName,
    required bool isAnonymous,
    String? customNote,
  }) {
    final sender = isAnonymous
        ? 'Someone who loves you 🤫'
        : (senderName.trim().isNotEmpty ? senderName.trim() : 'Someone special');
    final recipient =
        recipientName.trim().isNotEmpty ? recipientName.trim() : 'Hey';

    final occ = occasion.toLowerCase();
    final String intro;
    if (occ.contains('birthday')) {
      intro = '🎂 *Psst... It is hint time!*';
    } else if (occ.contains('anniversary')) {
      intro = '💍 *A Little Anniversary Whispering...*';
    } else if (occ.contains('valentine') || occ.contains('love')) {
      intro = '❤️ *A Heartfelt Hint Just for You...*';
    } else if (occ.contains('festive') || occ.contains('diwali')) {
      intro = '🪔 *Festive Sparkle Wishlist!*';
    } else {
      intro = '✨ *Psst... A Special Hint for You!*';
    }

    final lines = <String>[
      intro,
      '',
      '$recipient, $sender has their heart set on this gorgeous jewellery piece from *Jewel Ora*:',
      '',
      '💎 *${product.name}*',
      'Price: ${Formatters.price(price)}',
      if (size != null && size.isNotEmpty) 'Preferred Size: $size',
      if (product.categoryName.isNotEmpty) 'Category: ${product.categoryName}',
      if (product.material.isNotEmpty) 'Material: ${product.material}',
      if (product.weight.isNotEmpty) 'Weight: ${product.weight}',
      if (customNote != null && customNote.trim().isNotEmpty) ...[
        '',
        '💌 *Personal Note:* "${customNote.trim()}"',
      ],
      if (product.firstImage.isNotEmpty) ...[
        '',
        'Take a look here: ${ImageUrl.shareable(product.firstImage)}',
      ],
      '',
      "Wouldn't this make the most unforgettable gift? ✨",
    ];

    return lines.join('\n');
  }
}