import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_icons.dart';
import 'package:jewel_ora/core/utils/formatters.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/app_card.dart';
import 'package:jewel_ora/core/widgets/app_image.dart';
import 'package:jewel_ora/core/widgets/app_loader.dart';
import 'package:jewel_ora/core/widgets/empty_state.dart';
import 'package:jewel_ora/models/enquiry_model.dart';
import 'package:jewel_ora/providers/enquiry_provider.dart';
import 'package:jewel_ora/providers/settings_provider.dart';
import 'package:jewel_ora/providers/user_nav_provider.dart';
import 'package:jewel_ora/services/whatsapp_service.dart';
import 'package:provider/provider.dart';

class EnquiryHistoryScreen extends StatelessWidget {
  const EnquiryHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final enquiryProvider = context.watch<EnquiryProvider>();
    final enquiries = enquiryProvider.userEnquiries;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Enquiries & Quotes'),
      ),
      body: enquiryProvider.isLoading
          ? const Center(child: AppLoader())
          : enquiries.isEmpty
              ? EmptyState(
                  icon: AppIcons.enquiries,
                  title: 'No Enquiries Yet',
                  message:
                      'When you enquire about custom jewellery, rings, or cart items via WhatsApp, your enquiry records and quote updates will appear here.',
                  actionLabel: 'Explore Jewellery',
                  onAction: () {
                    Navigator.of(context).pop();
                    context
                        .read<UserNavProvider>()
                        .setIndex(UserNavProvider.shopTab);
                  },
                )
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: enquiries.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final item = enquiries[index];
                    return _EnquiryCard(enquiry: item);
                  },
                ),
    );
  }
}

class _EnquiryCard extends StatelessWidget {
  final EnquiryModel enquiry;
  const _EnquiryCard({required this.enquiry});

  Color _getStatusBg(String status) {
    switch (status) {
      case 'in_discussion':
        return const Color(0xFFFEF3C7);
      case 'quote_shared':
        return const Color(0xFFE0F2FE);
      case 'completed':
        return const Color(0xFFECFDF5);
      case 'submitted':
      default:
        return AppColors.primaryLight;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'in_discussion':
        return const Color(0xFFB45309);
      case 'quote_shared':
        return const Color(0xFF0369A1);
      case 'completed':
        return const Color(0xFF047857);
      case 'submitted':
      default:
        return AppColors.primary;
    }
  }

  void _openDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _EnquiryDetailsSheet(enquiry: enquiry),
    );
  }

  void _followUp(BuildContext context) {
    final settings = context.read<SettingsProvider>().settings;
    final ref = enquiry.id.length >= 6
        ? enquiry.id.substring(0, 6).toUpperCase()
        : enquiry.id.toUpperCase();
    final itemNames = enquiry.items.map((i) => i.productName).join(', ');
    final msg =
        'Hello! I would like to follow up on my enquiry #$ref regarding:\n$itemNames\nTotal Quote: ${Formatters.price(enquiry.totalAmount)}';

    WhatsAppService.open(phone: settings.whatsappNumber, message: msg);
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = enquiry.createdAt != null
        ? '${enquiry.createdAt!.day}/${enquiry.createdAt!.month}/${enquiry.createdAt!.year}'
        : 'Recent';

    final refId = enquiry.id.length >= 6
        ? '#${enquiry.id.substring(0, 6).toUpperCase()}'
        : '#${enquiry.id.toUpperCase()}';

    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: () => _openDetails(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Reference & Status Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      refId,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusBg(enquiry.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  enquiry.statusDisplay,
                  style: TextStyle(
                    color: _getStatusTextColor(enquiry.status),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Items Preview
          if (enquiry.items.isNotEmpty) ...[
            Column(
              children: enquiry.items.take(3).map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: item.productImage.isNotEmpty
                              ? AppImage(
                                  imageUrl: item.productImage,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: AppColors.primaryLight,
                                  child: const Icon(Icons.diamond_outlined,
                                      size: 20, color: AppColors.primary),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              'Qty: ${item.quantity} • ${Formatters.price(item.productPrice)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            if (enquiry.items.length > 3)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '+ ${enquiry.items.length - 3} more item(s)',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
          const Divider(height: 20),

          // Footer: Total & WhatsApp Follow Up
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estimated Value',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textGrey,
                    ),
                  ),
                  Text(
                    Formatters.price(enquiry.totalAmount),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF25D366),
                  side: const BorderSide(color: Color(0xFF25D366)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(AppIcons.whatsapp, size: 16),
                label: const Text(
                  'Follow Up',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                onPressed: () => _followUp(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EnquiryDetailsSheet extends StatelessWidget {
  final EnquiryModel enquiry;
  const _EnquiryDetailsSheet({required this.enquiry});

  @override
  Widget build(BuildContext context) {
    final ref = enquiry.id.length >= 6
        ? enquiry.id.substring(0, 6).toUpperCase()
        : enquiry.id.toUpperCase();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Enquiry #$ref',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Status: ${enquiry.statusDisplay}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Requested Jewellery Items',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: enquiry.items.length,
              separatorBuilder: (_, index) => const Divider(height: 12),
              itemBuilder: (context, index) {
                final item = enquiry.items[index];
                return Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 46,
                        height: 46,
                        child: item.productImage.isNotEmpty
                            ? AppImage(
                                imageUrl: item.productImage,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: AppColors.primaryLight,
                                child: const Icon(Icons.diamond_outlined,
                                    color: AppColors.primary),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Quantity: ${item.quantity}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      Formatters.price(item.productPrice * item.quantity),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Estimated Quote:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                Formatters.price(enquiry.totalAmount),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AppButton(
            title: 'Chat on WhatsApp',
            icon: AppIcons.whatsapp,
            onPressed: () {
              Navigator.of(context).pop();
              final settings = context.read<SettingsProvider>().settings;
              final msg =
                  'Hello! Following up on my jewellery enquiry #$ref for: ${enquiry.items.map((i) => i.productName).join(', ')}';
              WhatsAppService.open(
                  phone: settings.whatsappNumber, message: msg);
            },
          ),
        ],
      ),
    );
  }
}
