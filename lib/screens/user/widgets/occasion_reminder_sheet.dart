import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/empty_state.dart';
import 'package:jewel_ora/models/occasion_reminder_model.dart';
import 'package:jewel_ora/providers/occasion_reminder_provider.dart';
import 'package:jewel_ora/screens/user/widgets/gift_finder_sheet.dart';
import 'package:provider/provider.dart';

class OccasionReminderSheet extends StatefulWidget {
  const OccasionReminderSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const OccasionReminderSheet(),
    );
  }

  @override
  State<OccasionReminderSheet> createState() => _OccasionReminderSheetState();
}

class _OccasionReminderSheetState extends State<OccasionReminderSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _festiveDates = [
    (
      title: 'Dhanteras & Diwali Gold Muhurat',
      desc: 'Most auspicious day of the year to buy 24K pure gold coins, bars & bridal jewellery.',
      month: 11,
      day: 10,
      recipient: 'Self & Family',
      category: 'Coins & Gold',
      emoji: '🪔',
    ),
    (
      title: 'Akshaya Tritiya (Eternal Wealth Day)',
      desc: 'Buying gold on Akshaya Tritiya brings everlasting prosperity and blessings.',
      month: 5,
      day: 10,
      recipient: 'Family',
      category: 'Bangles & Gold',
      emoji: '✨',
    ),
    (
      title: 'Karwa Chauth Gifting',
      desc: 'Traditional love & devotion milestone: diamond mangalsutras, rings & solitaire gifting.',
      month: 10,
      day: 20,
      recipient: 'Spouse / Partner',
      category: 'Rings & Solitaires',
      emoji: '🌙',
    ),
    (
      title: 'Pushya Nakshatra Buying Muhurat',
      desc: 'Sacred planetary alignment for investing in precious metals and gemstones.',
      month: 11,
      day: 4,
      recipient: 'Self',
      category: 'Gold & Diamond',
      emoji: '⭐',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openAddMilestone(BuildContext context, [OccasionReminderModel? prefill]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddMilestoneDialog(prefill: prefill),
    );
  }

  void _findGiftForReminder(OccasionReminderModel reminder) {
    Navigator.of(context).pop();
    GiftFinderSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final reminderProvider = context.watch<OccasionReminderProvider>();
    final sortedReminders = reminderProvider.getSortedReminders();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Handle Bar
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // Sheet Title Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.event_note_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.occasionReminders,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          AppStrings.occasionRemindersSubtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textGrey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Tab Bar
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textGrey,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.favorite_outline_rounded, size: 16),
                      const SizedBox(width: 6),
                      Text(AppStrings.upcomingMilestones),
                      if (sortedReminders.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${sortedReminders.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome_rounded, size: 16),
                      const SizedBox(width: 6),
                      Text(AppStrings.festiveDates),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 1),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: My Saved Milestones
                  _buildMyMilestonesTab(context, reminderProvider, sortedReminders),

                  // Tab 2: Auspicious Gold Festive Dates
                  _buildFestiveTab(context, reminderProvider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // Tab 1: My Saved Milestones
  // ----------------------------------------------------
  Widget _buildMyMilestonesTab(
    BuildContext context,
    OccasionReminderProvider provider,
    List<OccasionReminderModel> sorted,
  ) {
    if (sorted.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              EmptyState(
                title: AppStrings.noReminders,
                subtitle: AppStrings.noRemindersSubtitle,
                icon: Icons.calendar_month_outlined,
              ),
              const SizedBox(height: 16),
              AppButton(
                title: 'Add First Milestone ➕',
                onPressed: () => _openAddMilestone(context),
              ),
            ],
          ),
        ),
      );
    }

    final nearest = sorted.first;
    final nearestDays = nearest.daysUntilNext(DateTime.now());

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        // Nearest Milestone Spotlight Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.08),
                AppColors.accent.withValues(alpha: 0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      nearestDays == 0 ? 'TODAY! 🎉' : '$nearestDays ${AppStrings.daysLeft}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Text(
                    nearest.recipient,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                nearest.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Occurs annually on ${nearest.formattedDate}',
                style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
              ),
              const SizedBox(height: 12),
              AppButton(
                title: 'Find Curated Gift for ${nearest.recipient} 🎁',
                icon: Icons.card_giftcard_rounded,
                onPressed: () => _findGiftForReminder(nearest),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Add Milestone Button
        AppButton.outlined(
          title: AppStrings.addMilestone,
          icon: Icons.add_rounded,
          onPressed: () => _openAddMilestone(context),
        ),

        const SizedBox(height: 18),

        // List of other reminders
        const Text(
          'All Saved Dates',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
        ),
        const SizedBox(height: 10),

        ...sorted.map((item) {
          final days = item.daysUntilNext(DateTime.now());
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '$days\ndays',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.recipient} · ${item.formattedDate}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.card_giftcard_rounded, color: AppColors.primary),
                  tooltip: 'Find gift',
                  onPressed: () => _findGiftForReminder(item),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textGrey, size: 20),
                  tooltip: 'Delete',
                  onPressed: () {
                    provider.removeReminder(item.id);
                    showAppSnackBar(context, 'Milestone removed');
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ----------------------------------------------------
  // Tab 2: Auspicious Festive Muhurat Dates
  // ----------------------------------------------------
  Widget _buildFestiveTab(
    BuildContext context,
    OccasionReminderProvider provider,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: _festiveDates.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final f = _festiveDates[i];
        final isAlreadyAdded = provider.reminders.any((r) => r.title == f.title);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(f.emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      f.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                f.desc,
                style: const TextStyle(fontSize: 12, color: AppColors.textGrey, height: 1.3),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Ideal for: ${f.category}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                  ),
                  if (isAlreadyAdded)
                    const Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                        SizedBox(width: 4),
                        Text('Added', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.success)),
                      ],
                    )
                  else
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        backgroundColor: AppColors.primaryLight,
                      ),
                      icon: const Icon(Icons.add_alert_rounded, size: 14, color: AppColors.primary),
                      label: const Text('Add Reminder', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      onPressed: () {
                        final reminder = OccasionReminderModel(
                          id: 'festive_${DateTime.now().millisecondsSinceEpoch}',
                          title: f.title,
                          recipient: f.recipient,
                          month: f.month,
                          day: f.day,
                          categoryHint: f.category,
                          notes: f.desc,
                        );
                        provider.addReminder(reminder);
                        showAppSnackBar(context, '${f.title} added to your reminders!');
                      },
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ----------------------------------------------------
// Sub-Sheet: Add Custom Milestone Form
// ----------------------------------------------------
class _AddMilestoneDialog extends StatefulWidget {
  final OccasionReminderModel? prefill;

  const _AddMilestoneDialog({this.prefill});

  @override
  State<_AddMilestoneDialog> createState() => _AddMilestoneDialogState();
}

class _AddMilestoneDialogState extends State<_AddMilestoneDialog> {
  final _titleController = TextEditingController();
  final _budgetController = TextEditingController();
  String _selectedRecipient = 'Spouse / Partner';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  String _preferredCategory = 'All Jewellery';

  static const _recipients = [
    'Spouse / Partner',
    'Mother',
    'Sister',
    'Daughter',
    'Self',
    'Best Friend',
  ];

  static const _categories = [
    'All Jewellery',
    'Rings & Solitaires',
    'Necklaces & Chokers',
    'Bangles & Kadas',
    'Earrings',
    'Gold Coins',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.prefill != null) {
      _titleController.text = widget.prefill!.title;
      _selectedRecipient = widget.prefill!.recipient;
      _selectedDate = DateTime(DateTime.now().year, widget.prefill!.month, widget.prefill!.day);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1970),
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      showAppSnackBar(context, 'Please enter a title for the occasion', isError: true);
      return;
    }

    final reminder = OccasionReminderModel(
      id: 'rem_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      recipient: _selectedRecipient,
      month: _selectedDate.month,
      day: _selectedDate.day,
      year: _selectedDate.year,
      categoryHint: _preferredCategory,
      budget: double.tryParse(_budgetController.text.trim()),
    );

    await context.read<OccasionReminderProvider>().addReminder(reminder);

    if (mounted) {
      showAppSnackBar(context, 'Milestone saved successfully!');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.favorite_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Add Special Milestone',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Occasion Title (e.g. 5th Wedding Anniversary)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Recipient Selector
            DropdownButtonFormField<String>(
              initialValue: _selectedRecipient,
              decoration: const InputDecoration(labelText: 'Gifting To', border: OutlineInputBorder()),
              items: _recipients.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (v) => setState(() => _selectedRecipient = v!),
            ),
            const SizedBox(height: 12),

            // Date Picker Row
            InkWell(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Occasion Date', style: TextStyle(fontSize: 10, color: AppColors.textGrey)),
                        Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Text('Change', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Preferred Category
            DropdownButtonFormField<String>(
              initialValue: _preferredCategory,
              decoration: const InputDecoration(labelText: 'Preferred Jewellery Category', border: OutlineInputBorder()),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _preferredCategory = v!),
            ),
            const SizedBox(height: 12),

            // Optional Budget
            TextField(
              controller: _budgetController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Target Budget (Optional)',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),

            AppButton(
              title: 'Save Milestone 💖',
              onPressed: _submit,
            ),
          ],
        ),
      ),
    ),
  );
  }
}
