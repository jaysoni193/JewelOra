import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_icons.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/utils/formatters.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/widgets/app_card.dart';
import 'package:jewel_ora/core/widgets/app_image.dart';
import 'package:jewel_ora/core/widgets/app_loader.dart';
import 'package:jewel_ora/core/widgets/empty_state.dart';
import 'package:jewel_ora/models/enquiry_model.dart';
import 'package:jewel_ora/providers/enquiry_provider.dart';
import 'package:jewel_ora/services/whatsapp_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminEnquiryListScreen extends StatefulWidget {
  const AdminEnquiryListScreen({super.key});

  @override
  State<AdminEnquiryListScreen> createState() => _AdminEnquiryListScreenState();
}

class _AdminEnquiryListScreenState extends State<AdminEnquiryListScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final enquiryProvider = context.watch<EnquiryProvider>();
    final all = enquiryProvider.allEnquiries;

    final filtered = _selectedFilter == 'all'
        ? all
        : all.where((e) => e.status == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Customer Leads & Enquiries'),
      ),
      body: Column(
        children: [
          // Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All (${all.length})',
                  isSelected: _selectedFilter == 'all',
                  onTap: () => setState(() => _selectedFilter = 'all'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label:
                      'New (${all.where((e) => e.status == 'submitted').length})',
                  isSelected: _selectedFilter == 'submitted',
                  onTap: () => setState(() => _selectedFilter = 'submitted'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label:
                      'In Discussion (${all.where((e) => e.status == 'in_discussion').length})',
                  isSelected: _selectedFilter == 'in_discussion',
                  onTap: () =>
                      setState(() => _selectedFilter = 'in_discussion'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label:
                      'Quotes Shared (${all.where((e) => e.status == 'quote_shared').length})',
                  isSelected: _selectedFilter == 'quote_shared',
                  onTap: () =>
                      setState(() => _selectedFilter = 'quote_shared'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label:
                      'Confirmed (${all.where((e) => e.status == 'completed').length})',
                  isSelected: _selectedFilter == 'completed',
                  onTap: () => setState(() => _selectedFilter = 'completed'),
                ),
              ],
            ),
          ),

          // Enquiries List
          Expanded(
            child: enquiryProvider.isLoading
                ? const Center(child: AppLoader())
                : filtered.isEmpty
                    ? const EmptyState(
                        icon: AppIcons.enquiries,
                        title: 'No Enquiries Found',
                        message:
                            'Customer enquiries generated from product details or cart will show up here.',
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: filtered.length,
                        separatorBuilder: (_, index) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return _AdminEnquiryCard(enquiry: item);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}

class _AdminEnquiryCard extends StatelessWidget {
  final EnquiryModel enquiry;
  const _AdminEnquiryCard({required this.enquiry});

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

  Future<void> _changeStatus(BuildContext context) async {
    final newStatus = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Update Enquiry Status',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            ListTile(
              title: const Text('Enquiry Sent / New'),
              leading: const Icon(Icons.mark_email_unread_outlined),
              onTap: () => Navigator.of(ctx).pop('submitted'),
            ),
            ListTile(
              title: const Text('In Discussion'),
              leading: const Icon(Icons.question_answer_outlined),
              onTap: () => Navigator.of(ctx).pop('in_discussion'),
            ),
            ListTile(
              title: const Text('Quote Shared'),
              leading: const Icon(Icons.request_quote_outlined),
              onTap: () => Navigator.of(ctx).pop('quote_shared'),
            ),
            ListTile(
              title: const Text('Order Confirmed / Completed'),
              leading: const Icon(Icons.check_circle_outline_rounded),
              onTap: () => Navigator.of(ctx).pop('completed'),
            ),
          ],
        ),
      ),
    );

    if (newStatus != null && context.mounted) {
      final ok =
          await context.read<EnquiryProvider>().updateStatus(enquiry.id, newStatus);
      if (context.mounted) {
        showAppSnackBar(
          context,
          ok ? 'Status updated' : AppStrings.somethingWentWrong,
          isError: !ok,
        );
      }
    }
  }

  Future<void> _callCustomer(BuildContext context) async {
    final phone = enquiry.userPhone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (phone.isEmpty) {
      showAppSnackBar(context, 'Customer phone number not available',
          isError: true);
      return;
    }
    final uri = Uri.parse('tel:$phone');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        showAppSnackBar(context, 'Could not initiate call', isError: true);
      }
    }
  }

  void _whatsappCustomer(BuildContext context) {
    if (enquiry.userPhone.isEmpty) {
      showAppSnackBar(context, 'Customer phone number not available',
          isError: true);
      return;
    }
    final ref = enquiry.id.length >= 6
        ? enquiry.id.substring(0, 6).toUpperCase()
        : enquiry.id.toUpperCase();
    final msg =
        'Hello ${enquiry.userName}! Thank you for reaching out to us regarding enquiry #$ref. Here is the quote and update for your requested jewellery piece.';
    WhatsAppService.open(phone: enquiry.userPhone, message: msg);
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Reference & Status Pill (Tappable to change)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    refId,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
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
              InkWell(
                onTap: () => _changeStatus(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusBg(enquiry.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        enquiry.statusDisplay,
                        style: TextStyle(
                          color: _getStatusTextColor(enquiry.status),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.edit_outlined,
                        size: 12,
                        color: _getStatusTextColor(enquiry.status),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Customer Info
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryLight,
                ),
                child: Center(
                  child: Text(
                    enquiry.userName.isNotEmpty
                        ? enquiry.userName[0].toUpperCase()
                        : 'C',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      enquiry.userName.isNotEmpty
                          ? enquiry.userName
                          : 'Customer',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      enquiry.userPhone.isNotEmpty
                          ? enquiry.userPhone
                          : enquiry.userEmail,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              // Quick Actions
              IconButton(
                icon: const Icon(AppIcons.phone,
                    size: 20, color: AppColors.primary),
                tooltip: 'Call Customer',
                onPressed: () => _callCustomer(context),
              ),
              IconButton(
                icon: const Icon(AppIcons.whatsapp,
                    size: 20, color: Color(0xFF25D366)),
                tooltip: 'WhatsApp Customer',
                onPressed: () => _whatsappCustomer(context),
              ),
            ],
          ),
          const Divider(height: 20),

          // Requested Items
          Column(
            children: enquiry.items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: item.productImage.isNotEmpty
                            ? AppImage(
                                imageUrl: item.productImage,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: AppColors.primaryLight,
                                child: const Icon(Icons.diamond_outlined,
                                    size: 16, color: AppColors.primary),
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      'Qty ${item.quantity} • ${Formatters.price(item.productPrice)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const Divider(height: 16),

          // Total and Update Status Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ${Formatters.price(enquiry.totalAmount)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.sync_rounded, size: 16),
                label: const Text('Change Status',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                onPressed: () => _changeStatus(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
