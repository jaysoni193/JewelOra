import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/widgets/app_bottom_sheet.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/app_dropdown.dart';
import 'package:jewel_ora/core/widgets/app_text_field.dart';
import 'package:jewel_ora/providers/auth_provider.dart';
import 'package:jewel_ora/providers/settings_provider.dart';
import 'package:jewel_ora/services/whatsapp_service.dart';
import 'package:provider/provider.dart';

class BookVisitSheet extends StatefulWidget {
  final String? initialCategory;
  final String? initialNotes;

  const BookVisitSheet({
    super.key,
    this.initialCategory,
    this.initialNotes,
  });

  static Future<void> show(
    BuildContext context, {
    String? initialCategory,
    String? initialNotes,
  }) {
    return AppBottomSheet.show(
      context,
      child: BookVisitSheet(
        initialCategory: initialCategory,
        initialNotes: initialNotes,
      ),
    );
  }

  @override
  State<BookVisitSheet> createState() => _BookVisitSheetState();
}

class _BookVisitSheetState extends State<BookVisitSheet> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedSlot = '11:30 AM';
  String _selectedCategory = 'Bridal & Wedding Sets';
  int _guests = 2;
  late final TextEditingController _notesCtrl;

  static const _slots = [
    '11:30 AM',
    '01:00 PM',
    '02:30 PM',
    '04:00 PM',
    '05:30 PM',
    '07:00 PM',
  ];

  static const _categories = [
    'Bridal & Wedding Sets',
    'Solitaire & Diamond Rings',
    'Daily Wear 22K Gold',
    'Antique & Temple Jewellery',
    '925 Sterling Silver Gifts',
    'Custom Design Consultation',
    'Old Gold Exchange & Valuation',
  ];

  @override
  void initState() {
    super.initState();
    _notesCtrl = TextEditingController(text: widget.initialNotes ?? '');
    if (widget.initialCategory != null &&
        _categories.contains(widget.initialCategory)) {
      _selectedCategory = widget.initialCategory!;
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _book() async {
    final phone = context.read<SettingsProvider>().settings.whatsappNumber;
    final user = context.read<AuthProvider>().user;
    final customerName = user?.name ?? '';

    final formattedDate =
        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';

    final message = WhatsAppService.buildBookVisitMessage(
      date: formattedDate,
      timeSlot: _selectedSlot,
      category: _selectedCategory,
      guests: _guests,
      notes: _notesCtrl.text.trim(),
      customerName: customerName,
    );

    try {
      await WhatsAppService.open(phone: phone, message: message);
      if (mounted) {
        Navigator.pop(context);
        showAppSnackBar(context, 'Store appointment request opened in WhatsApp!');
      }
    } catch (_) {
      if (mounted) {
        showAppSnackBar(context, 'Could not launch WhatsApp', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonBottomSheetContainer(
      title: AppStrings.bookVisitTitle,
      subtitle: AppStrings.bookVisitSubtitle,
      icon: Icons.event_available_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

              // Date Picker Button
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.selectDate,
                              style: const TextStyle(fontSize: 11, color: AppColors.textGrey, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Preferred Time Slot
              Text(
                AppStrings.selectTimeSlot,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _slots.map((slot) {
                  final isSel = slot == _selectedSlot;
                  return ChoiceChip(
                    label: Text(slot),
                    selected: isSel,
                    onSelected: (_) => setState(() => _selectedSlot = slot),
                    selectedColor: AppColors.primaryLight,
                    backgroundColor: AppColors.surface,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      color: isSel ? AppColors.primaryDark : AppColors.textDark,
                    ),
                    side: BorderSide(
                      color: isSel ? AppColors.primary : AppColors.border,
                      width: isSel ? 1.3 : 1.0,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Preferred Category
              AppDropdown<String>(
                label: 'Interest / Collection Focus',
                value: _selectedCategory,
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v ?? _selectedCategory),
              ),
              const SizedBox(height: 14),

              // Guests selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Number of Guests',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                  ),
                  Row(
                    children: [1, 2, 3, 4].map((g) {
                      final isSel = g == _guests;
                      return Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: InkWell(
                          onTap: () => setState(() => _guests = g),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 34,
                            height: 34,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSel ? AppColors.primary : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSel ? AppColors.primary : AppColors.border,
                              ),
                            ),
                            child: Text(
                              '$g',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isSel ? Colors.white : AppColors.textDark,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              AppTextField(
                controller: _notesCtrl,
                label: AppStrings.notesOptional,
                hintText: 'e.g. interested in 22K choker sets under 1.5L',
                prefixIcon: Icons.notes_rounded,
                maxLines: 2,
              ),
              const SizedBox(height: 22),

              AppButton(
                title: AppStrings.sendVisitRequestWhatsApp,
                icon: Icons.chat_rounded,
                backgroundColor: AppColors.whatsapp,
                onPressed: _book,
              ),
            ],
          ),
        );
      }
    }

typedef BookVisitDialog = BookVisitSheet;
