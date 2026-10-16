import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/utils/formatters.dart';
import 'package:jewel_ora/core/utils/image_url.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/widgets/app_bottom_sheet.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/models/product_model.dart';
import 'package:jewel_ora/providers/auth_provider.dart';
import 'package:jewel_ora/services/whatsapp_service.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class DropHintSheet extends StatefulWidget {
  final ProductModel product;
  final double effectivePrice;
  final String? selectedSize;

  const DropHintSheet({
    super.key,
    required this.product,
    required this.effectivePrice,
    this.selectedSize,
  });

  static Future<void> show(
    BuildContext context, {
    required ProductModel product,
    required double effectivePrice,
    String? selectedSize,
  }) {
    return AppBottomSheet.show(
      context,
      child: DropHintSheet(
        product: product,
        effectivePrice: effectivePrice,
        selectedSize: selectedSize,
      ),
    );
  }

  @override
  State<DropHintSheet> createState() => _DropHintSheetState();
}

class _DropHintSheetState extends State<DropHintSheet> {
  static const _occasions = [
    ('Birthday', '🎂', 'Birthday'),
    ('Anniversary', '💍', 'Anniversary'),
    ("Valentine's", '❤️', "Valentine's"),
    ('Festive', '🪔', 'Festive / Diwali'),
    ('Just Because', '✨', 'Just Because'),
  ];

  static const _quickRecipients = [
    'Partner / Spouse',
    'Bestie',
    'Mom',
    'Dad',
    'Brother',
    'Sister',
  ];

  late String _selectedOccasion;
  late final TextEditingController _recipientNameCtrl;
  late final TextEditingController _senderNameCtrl;
  late final TextEditingController _recipientPhoneCtrl;
  late final TextEditingController _customNoteCtrl;
  bool _isAnonymous = false;

  @override
  void initState() {
    super.initState();
    _selectedOccasion = _occasions.first.$1;

    final user = context.read<AuthProvider>().user;
    final defaultSender = user?.name.isNotEmpty == true
        ? user!.name
        : (user?.email.isNotEmpty == true
            ? user!.email.split('@').first
            : '');

    _senderNameCtrl = TextEditingController(text: defaultSender);
    _recipientNameCtrl = TextEditingController(text: 'Partner');
    _recipientPhoneCtrl = TextEditingController();
    _customNoteCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _recipientNameCtrl.dispose();
    _senderNameCtrl.dispose();
    _recipientPhoneCtrl.dispose();
    _customNoteCtrl.dispose();
    super.dispose();
  }

  String _generateMessage() {
    return WhatsAppService.buildHintMessage(
      product: widget.product,
      price: widget.effectivePrice,
      size: widget.selectedSize,
      occasion: _selectedOccasion,
      senderName: _senderNameCtrl.text,
      recipientName: _recipientNameCtrl.text,
      isAnonymous: _isAnonymous,
      customNote: _customNoteCtrl.text,
    );
  }

  Future<void> _sendWhatsApp() async {
    final msg = _generateMessage();
    try {
      await WhatsAppService.shareMessage(
        phone: _recipientPhoneCtrl.text.trim(),
        message: msg,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, 'Could not open WhatsApp: $e', isError: true);
      }
    }
  }

  Future<void> _shareAny() async {
    final msg = _generateMessage();
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: msg,
          subject: 'A Special Hint from Jewel Ora 🎁',
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, 'Sharing failed: $e', isError: true);
      }
    }
  }

  void _copyToClipboard() {
    final msg = _generateMessage();
    Clipboard.setData(ClipboardData(text: msg));
    showAppSnackBar(context, 'Hint message copied to clipboard! 📋');
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return CommonBottomSheetContainer(
      title: 'Drop a Hint 🎁',
      subtitle: 'Let someone special know what piece you love!',
      icon: Icons.card_giftcard_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

                // Mini Product Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: p.firstImage.isNotEmpty
                            ? Image.network(
                                ImageUrl.optimized(p.firstImage, width: 120),
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 56,
                                  height: 56,
                                  color: AppColors.surface,
                                  child: const Icon(Icons.diamond_outlined, color: AppColors.textLight),
                                ),
                              )
                            : Container(
                                width: 56,
                                height: 56,
                                color: AppColors.surface,
                                child: const Icon(Icons.diamond_outlined, color: AppColors.textLight),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              Formatters.price(widget.effectivePrice),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            if (widget.selectedSize != null && widget.selectedSize!.isNotEmpty)
                              Text(
                                'Size: ${widget.selectedSize}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 1. Select Occasion
                const Text(
                  'Select Occasion',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _occasions.map((occ) {
                    final isSel = _selectedOccasion == occ.$1;
                    return InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => setState(() => _selectedOccasion = occ.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSel ? AppColors.primary : AppColors.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(occ.$2, style: const TextStyle(fontSize: 13)),
                            const SizedBox(width: 5),
                            Text(
                              occ.$3,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                color: isSel ? Colors.white : AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // 2. Who is this hint for?
                const Text(
                  'Who is this hint for?',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _quickRecipients.map((rec) {
                    final isSel = _recipientNameCtrl.text == rec;
                    return ActionChip(
                      label: Text(rec, style: TextStyle(fontSize: 11, color: isSel ? Colors.white : AppColors.textDark)),
                      backgroundColor: isSel ? AppColors.accent : AppColors.background,
                      side: BorderSide(color: isSel ? AppColors.accent : AppColors.border),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      onPressed: () {
                        setState(() {
                          _recipientNameCtrl.text = rec;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: _recipientNameCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Recipient Name or Nickname',
                    hintText: 'e.g., Sweetheart, Raj, Priya...',
                    prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _recipientPhoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Their WhatsApp Number (Optional)',
                    hintText: 'e.g., 919876543210 (Leave blank for contact picker)',
                    prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Sender Options
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Your Name on Hint',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Secret Wish 🤫', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        Switch(
                          value: _isAnonymous,
                          activeThumbColor: AppColors.accent,
                          onChanged: (val) => setState(() => _isAnonymous = val),
                        ),
                      ],
                    ),
                  ],
                ),
                if (!_isAnonymous) ...[
                  const SizedBox(height: 4),
                  TextField(
                    controller: _senderNameCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Your Name (e.g. Megha)',
                      prefixIcon: const Icon(Icons.favorite_border_rounded, size: 20, color: AppColors.accent),
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                // 4. Custom Personal Note (Optional)
                TextField(
                  controller: _customNoteCtrl,
                  onChanged: (_) => setState(() {}),
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Add a Sweet Note (Optional)',
                    hintText: 'e.g., In case you were wondering what to get me! 😉',
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),

                // Message Live Preview Box
                const Text(
                  'Message Preview',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    _generateMessage(),
                    style: const TextStyle(fontSize: 11, height: 1.45, color: AppColors.textDark),
                  ),
                ),
                const SizedBox(height: 20),

                // Actions: Send on WhatsApp, Share, Copy
                AppButton(
                  title: 'Send Hint on WhatsApp',
                  icon: Icons.chat_rounded,
                  backgroundColor: AppColors.whatsapp,
                  onPressed: _sendWhatsApp,
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: AppButton.outlined(
                        title: 'Share Anywhere',
                        icon: Icons.share_rounded,
                        onPressed: _shareAny,
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filledTonal(
                      tooltip: 'Copy Message',
                      icon: const Icon(Icons.copy_rounded, color: AppColors.primary),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.all(14),
                      ),
                      onPressed: _copyToClipboard,
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
