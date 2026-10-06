import 'package:jewel_ora/core/errors/app_exception.dart';
import 'package:jewel_ora/core/utils/formatters.dart';
import 'package:jewel_ora/core/utils/image_url.dart';
import 'package:jewel_ora/models/product_model.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  WhatsAppService._();

  /// wa.me links accept digits only (country code included, no + sign).
  static String cleanNumber(String raw) => raw.replaceAll(RegExp(r'\D'), '');

  /// The text that is pre-filled in the chat. *Asterisks* make bold text.
  static String buildProductMessage(
      ProductModel p, {
        String customerName = '',
      }) {
    final lines = <String>[
      'Hello! I am interested in this product:',
      '',
      '*${p.name}*',
      'Price: ${Formatters.price(p.price)}',
      if (p.categoryName.isNotEmpty) 'Category: ${p.categoryName}',
      if (p.material.isNotEmpty) 'Material: ${p.material}',
      if (p.weight.isNotEmpty) 'Weight: ${p.weight}',
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

  /// One message for the whole cart.
  static String buildCartMessage(
      List<({ProductModel product, int quantity})> lines, {
        String customerName = '',
      }) {
    var total = 0.0;
    final out = <String>[
      'Hello! I would like to enquire about these items:',
      '',
    ];

    for (var i = 0; i < lines.length; i++) {
      final p = lines[i].product;
      final q = lines[i].quantity;
      final lineTotal = p.price * q;
      total += lineTotal;

      out.add('${i + 1}. *${p.name}*');
      final details = [p.categoryName, p.material, p.weight]
          .where((e) => e.isNotEmpty)
          .join(' | ');
      if (details.isNotEmpty) out.add('   $details');
      out.add('   Qty: $q x ${Formatters.price(p.price)} = '
          '${Formatters.price(lineTotal)}');
      out.add('');
    }

    out.add('*Estimated total: ${Formatters.price(total)}*');
    if (customerName.isNotEmpty) out.addAll(['', '- $customerName']);
    return out.join('\n');
  }
}