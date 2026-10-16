import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/utils/formatters.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/app_card.dart';
import 'package:jewel_ora/core/widgets/app_text_field.dart';
import 'package:jewel_ora/models/bridal_planner_model.dart';
import 'package:jewel_ora/providers/bridal_planner_provider.dart';
import 'package:jewel_ora/providers/settings_provider.dart';
import 'package:jewel_ora/screens/user/widgets/video_shopping_sheet.dart';
import 'package:jewel_ora/services/whatsapp_service.dart';
import 'package:provider/provider.dart';

class BridalPlannerSheet extends StatefulWidget {
  const BridalPlannerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const BridalPlannerSheet(),
    );
  }

  @override
  State<BridalPlannerSheet> createState() => _BridalPlannerSheetState();
}

class _BridalPlannerSheetState extends State<BridalPlannerSheet> {
  String _selectedCeremonyFilter = 'all';

  // Wizard State (when no profile exists)
  final _brideNameCtrl = TextEditingController(text: 'Bride');
  final _budgetCtrl = TextEditingController(text: '1000000');
  DateTime? _wizardWeddingDate;
  bool _loadHeritageTemplate = true;

  @override
  void dispose() {
    _brideNameCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final planner = context.watch<BridalPlannerProvider>();
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Container(
      height: MediaQuery.of(context).size.height * (isKeyboardOpen ? 0.95 : 0.88),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.favorite_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.bridalPlanner,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        AppStrings.bridalPlannerSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (planner.hasProfile) ...[
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, size: 20, color: AppColors.textMuted),
                    tooltip: 'Reset Trousseau Plan',
                    onPressed: () => _confirmReset(context),
                  ),
                ],
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 22, color: AppColors.textGrey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Body
          Expanded(
            child: planner.isLoading
                ? const Center(child: CircularProgressIndicator())
                : planner.hasProfile
                    ? _buildPlannerView(context, planner.profile!)
                    : _buildOnboardingWizard(context),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Onboarding Wizard (Create Bridal Profile)
  // -------------------------------------------------------------
  Widget _buildOnboardingWizard(BuildContext context) {
    final quickBudgets = [500000.0, 1000000.0, 1500000.0, 2500000.0];

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
      children: [
        // Welcome Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.08),
                AppColors.accent.withValues(alpha: 0.06),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('👑', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 8),
                  Text(
                    'Plan Your Royal Wedding Trousseau',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Text(
                'Organize your wedding jewellery budget ceremony-by-ceremony (Engagement, Haldi, Sangeet, Wedding & Reception). Keep spend in control and ensure no heirloom piece is missed!',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textDark,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Bride / Couple Name
        AppTextField(
          controller: _brideNameCtrl,
          label: "Bride's Name / Couple Name",
          hintText: 'e.g. Aanya & Rohan',
          prefixIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 14),

        // Wedding Date Picker
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now().add(const Duration(days: 90)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 1000)),
            );
            if (picked != null) {
              setState(() => _wizardWeddingDate = picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Wedding Date (Optional for Countdown)',
                        style: TextStyle(fontSize: 11, color: AppColors.textGrey),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _wizardWeddingDate != null
                            ? '${_wizardWeddingDate!.day}/${_wizardWeddingDate!.month}/${_wizardWeddingDate!.year}'
                            : 'Tap to select wedding date',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _wizardWeddingDate != null ? AppColors.textDark : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_wizardWeddingDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () => setState(() => _wizardWeddingDate = null),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Total Jewellery Budget
        AppTextField(
          controller: _budgetCtrl,
          label: AppStrings.totalWeddingBudget,
          hintText: '1000000',
          keyboardType: TextInputType.number,
          prefixIcon: Icons.currency_rupee_rounded,
        ),
        const SizedBox(height: 8),

        // Quick Budget Preset Chips
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: quickBudgets.map((amt) {
            final isSel = double.tryParse(_budgetCtrl.text) == amt;
            return ChoiceChip(
              label: Text(Formatters.price(amt)),
              selected: isSel,
              onSelected: (_) => setState(() => _budgetCtrl.text = amt.toInt().toString()),
              selectedColor: AppColors.primaryLight,
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                fontSize: 11,
                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                color: isSel ? AppColors.primary : AppColors.textDark,
              ),
              side: BorderSide(
                color: isSel ? AppColors.primary : AppColors.border,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Checkbox: Pre-load Starter Template
        CheckboxListTile(
          value: _loadHeritageTemplate,
          onChanged: (val) => setState(() => _loadHeritageTemplate = val ?? true),
          title: const Text(
            'Pre-load Royal Heritage Checklist',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
          ),
          subtitle: const Text(
            '12 recommended heirloom pieces across 5 wedding ceremonies',
            style: TextStyle(fontSize: 11, color: AppColors.textGrey),
          ),
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
        ),
        const SizedBox(height: 20),

        // Submit Button
        AppButton(
          title: 'Start My Wedding Planner ✨',
          icon: Icons.auto_awesome_rounded,
          onPressed: () async {
            final budget = double.tryParse(_budgetCtrl.text.replaceAll(',', '')) ?? 1000000.0;
            await context.read<BridalPlannerProvider>().createOrUpdateProfile(
                  brideName: _brideNameCtrl.text,
                  totalBudget: budget,
                  weddingDate: _wizardWeddingDate,
                  includeStarterTemplate: _loadHeritageTemplate,
                );
            if (context.mounted) {
              showAppSnackBar(context, 'Wedding Trousseau Planner initialized! 👰');
            }
          },
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // Planner Main Dashboard View
  // -------------------------------------------------------------
  Widget _buildPlannerView(BuildContext context, BridalPlannerProfile profile) {
    final filteredItems = _selectedCeremonyFilter == 'all'
        ? profile.items
        : profile.itemsForCeremony(_selectedCeremonyFilter);

    return Column(
      children: [
        // Analytics & Budget Progress Card
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          child: _buildBudgetCard(context, profile),
        ),

        // Ceremony Horizontal Filter Chips
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildCeremonyFilterChip(id: 'all', label: 'All Pieces (${profile.items.length})'),
              ...BridalCeremony.all.map((c) {
                final count = profile.itemsForCeremony(c.id).length;
                return _buildCeremonyFilterChip(id: c.id, label: '${c.title} ($count)');
              }),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Items Checklist
        Expanded(
          child: filteredItems.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                  itemCount: filteredItems.length,
                  itemBuilder: (ctx, index) {
                    final item = filteredItems[index];
                    return _buildItemTile(context, item);
                  },
                ),
        ),

        // Sticky Bottom Action Bar
        _buildBottomActionBar(context, profile),
      ],
    );
  }

  Widget _buildBudgetCard(BuildContext context, BridalPlannerProfile profile) {
    final util = profile.budgetUtilizationPercentage;
    final isOver = profile.isOverBudget;
    final progressColor = isOver ? AppColors.error : AppColors.primary;

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bride Name & Wedding Countdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('👑', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    profile.brideName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              if (profile.daysUntilWedding != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite_rounded, size: 12, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(
                        profile.daysUntilWedding! > 0
                            ? '${profile.daysUntilWedding} ${AppStrings.daysLeft} 💍'
                            : profile.daysUntilWedding == 0
                                ? 'Wedding Day Today! 💖'
                                : 'Happily Married 🌟',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Budget Numbers Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.totalWeddingBudget,
                      style: const TextStyle(fontSize: 10, color: AppColors.textGrey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.price(profile.totalBudget),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.budgetSpent,
                      style: const TextStyle(fontSize: 10, color: AppColors.textGrey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.price(profile.totalPurchasedSpend),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isOver ? AppColors.error : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppStrings.budgetRemaining,
                      style: const TextStyle(fontSize: 10, color: AppColors.textGrey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.price(profile.remainingBudget),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: profile.remainingBudget >= 0 ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Linear Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: util,
              minHeight: 7,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 8),

          // Sub-stats (Pieces Purchased + Gold Grams)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${profile.purchasedCount}/${profile.totalItemsCount} pieces acquired (${(profile.completionPercentage * 100).toInt()}%)',
                style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w500),
              ),
              Text(
                'Gold Weight: ${profile.purchasedGoldGrams.toStringAsFixed(1)}g / ${profile.totalGoldGrams.toStringAsFixed(1)}g',
                style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCeremonyFilterChip({required String id, required String label}) {
    final isSel = _selectedCeremonyFilter == id;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: isSel,
        onSelected: (_) => setState(() => _selectedCeremonyFilter = id),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
          color: isSel ? Colors.white : AppColors.textDark,
        ),
        side: BorderSide(
          color: isSel ? AppColors.primary : AppColors.border,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }

  Widget _buildItemTile(BuildContext context, BridalItem item) {
    final ceremony = BridalCeremony.getById(item.ceremonyId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: item.isPurchased ? AppColors.surface.withValues(alpha: 0.6) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.isPurchased ? AppColors.success.withValues(alpha: 0.4) : AppColors.border,
            width: item.isPurchased ? 1.2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _toggleItem(context, item),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Custom Checkbox
                Icon(
                  item.isPurchased ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: item.isPurchased ? AppColors.success : AppColors.textMuted,
                  size: 22,
                ),
                const SizedBox(width: 12),

                // Item Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: item.isPurchased ? AppColors.textMuted : AppColors.textDark,
                          decoration: item.isPurchased ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              ceremony.title.split(' ').first,
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          if (item.targetGoldGrams != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${item.targetGoldGrams}g Gold',
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          if (item.notes != null && item.notes!.isNotEmpty)
                            Text(
                              item.notes!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Spend Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Formatters.price(item.effectiveSpend),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: item.isPurchased ? AppColors.success : AppColors.textDark,
                      ),
                    ),
                    Text(
                      item.isPurchased ? 'Purchased ✓' : 'Est. Budget',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: item.isPurchased ? AppColors.success : AppColors.textGrey,
                      ),
                    ),
                  ],
                ),

                // Popup Options
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textMuted),
                  onSelected: (action) {
                    if (action == 'edit') {
                      _showEditItemDialog(context, item);
                    } else if (action == 'delete') {
                      context.read<BridalPlannerProvider>().deleteItem(item.id);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit Details')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete Piece')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 40, color: AppColors.textMuted),
            const SizedBox(height: 10),
            const Text(
              'No pieces in this ceremony yet',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tap "+ Add Piece" below to add a jewellery piece to your wedding trousseau.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Bottom Action Bar
  // -------------------------------------------------------------
  Widget _buildBottomActionBar(BuildContext context, BridalPlannerProfile profile) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          // Add Piece Button
          Expanded(
            flex: 2,
            child: AppButton(
              title: '+ Add Piece',
              icon: Icons.add_rounded,
              onPressed: () => _showAddItemDialog(context),
            ),
          ),
          const SizedBox(width: 8),

          // WhatsApp Trousseau Export
          Expanded(
            flex: 3,
            child: AppButton.outlined(
              title: 'Share Trousseau',
              icon: Icons.chat_rounded,
              foregroundColor: AppColors.whatsapp,
              onPressed: () => _exportToWhatsApp(context, profile),
            ),
          ),
          const SizedBox(width: 8),

          // Stylist Consult
          IconButton(
            tooltip: 'Book Bridal Stylist',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              padding: const EdgeInsets.all(12),
            ),
            icon: const Icon(Icons.video_call_rounded, color: AppColors.primary, size: 20),
            onPressed: () {
              Navigator.pop(context);
              VideoShoppingSheet.show(context);
            },
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Add / Edit Item Dialog
  // -------------------------------------------------------------
  void _showAddItemDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final budgetCtrl = TextEditingController(text: '75000');
    final goldCtrl = TextEditingController(text: '10.0');
    final notesCtrl = TextEditingController();
    var selectedCeremony = _selectedCeremonyFilter != 'all' ? _selectedCeremonyFilter : 'wedding_day';
    var selectedCategory = 'Necklace';

    final categories = ['Necklace', 'Earrings', 'Bangles', 'Rings', 'Maang Tikka', 'Nath', 'Kamarbandh', 'Payal', 'Groom Jewellery'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Trousseau Piece', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ceremony Picker
                DropdownButtonFormField<String>(
                  initialValue: selectedCeremony,
                  decoration: const InputDecoration(labelText: 'Wedding Ceremony', border: OutlineInputBorder()),
                  items: BridalCeremony.all
                      .map((c) => DropdownMenuItem(value: c.id, child: Text(c.title)))
                      .toList(),
                  onChanged: (val) => setDlgState(() => selectedCeremony = val ?? 'wedding_day'),
                ),
                const SizedBox(height: 12),

                // Category Picker
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Jewellery Category', border: OutlineInputBorder()),
                  items: categories
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (val) => setDlgState(() => selectedCategory = val ?? 'Necklace'),
                ),
                const SizedBox(height: 12),

                // Item Name
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Piece Name',
                    hintText: 'e.g. Royal Polki Bridal Choker',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Budget & Gold Grams Row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: budgetCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Est. Budget (₹)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: goldCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Est. Gold (g)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Notes
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Notes / Gemstone preferences (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                final budget = double.tryParse(budgetCtrl.text) ?? 50000.0;
                final gold = double.tryParse(goldCtrl.text);

                final newItem = BridalItem(
                  id: 'bi_${DateTime.now().millisecondsSinceEpoch}',
                  ceremonyId: selectedCeremony,
                  name: name,
                  category: selectedCategory,
                  estimatedBudget: budget,
                  targetGoldGrams: gold,
                  notes: notesCtrl.text.trim().isNotEmpty ? notesCtrl.text.trim() : null,
                );

                context.read<BridalPlannerProvider>().addItem(newItem);
                Navigator.pop(ctx);
                showAppSnackBar(context, 'Added "$name" to your bridal trousseau!');
              },
              child: const Text('Add Piece'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditItemDialog(BuildContext context, BridalItem item) {
    final nameCtrl = TextEditingController(text: item.name);
    final budgetCtrl = TextEditingController(text: item.estimatedBudget.toInt().toString());
    final actualCtrl = TextEditingController(
      text: item.actualSpend != null ? item.actualSpend!.toInt().toString() : '',
    );
    final goldCtrl = TextEditingController(
      text: item.targetGoldGrams != null ? item.targetGoldGrams.toString() : '',
    );
    final notesCtrl = TextEditingController(text: item.notes ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Jewellery Piece', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Piece Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: budgetCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Budget (₹)', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: actualCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Actual Spend (₹)', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: goldCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Gold Grams (g)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () {
              final updated = item.copyWith(
                name: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : item.name,
                estimatedBudget: double.tryParse(budgetCtrl.text) ?? item.estimatedBudget,
                actualSpend: double.tryParse(actualCtrl.text),
                targetGoldGrams: double.tryParse(goldCtrl.text),
                notes: notesCtrl.text.trim().isNotEmpty ? notesCtrl.text.trim() : null,
              );
              context.read<BridalPlannerProvider>().updateItem(updated);
              Navigator.pop(ctx);
              showAppSnackBar(context, 'Updated "${updated.name}"');
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _toggleItem(BuildContext context, BridalItem item) {
    if (!item.isPurchased) {
      // Ask if actual price differs from estimate
      showDialog(
        context: context,
        builder: (ctx) {
          final spendCtrl = TextEditingController(text: item.estimatedBudget.toInt().toString());
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Mark as Purchased 🎉', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Confirm purchase of "${item.name}". Enter the final invoice / purchase amount:',
                  style: const TextStyle(fontSize: 13, color: AppColors.textDark),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: spendCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Actual Amount Paid (₹)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.currency_rupee_rounded, size: 18),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                onPressed: () {
                  final actual = double.tryParse(spendCtrl.text) ?? item.estimatedBudget;
                  context.read<BridalPlannerProvider>().togglePurchased(item.id, actualSpend: actual);
                  Navigator.pop(ctx);
                  showAppSnackBar(context, 'Marked "${item.name}" as acquired! ✨');
                },
                child: const Text('Confirm Purchase'),
              ),
            ],
          );
        },
      );
    } else {
      context.read<BridalPlannerProvider>().togglePurchased(item.id);
    }
  }

  // -------------------------------------------------------------
  // WhatsApp Trousseau Export
  // -------------------------------------------------------------
  Future<void> _exportToWhatsApp(BuildContext context, BridalPlannerProfile profile) async {
    final storePhone = context.read<SettingsProvider>().settings.storePhone;

    final buffer = StringBuffer();
    buffer.writeln('👰 *Jewel Ora - Bridal Jewellery Trousseau Plan* 💍');
    buffer.writeln('Bride / Couple: *${profile.brideName}*');
    if (profile.weddingDate != null) {
      buffer.writeln('Wedding Date: ${profile.weddingDate!.day}/${profile.weddingDate!.month}/${profile.weddingDate!.year} (${profile.daysUntilWedding ?? 0} days to go)');
    }
    buffer.writeln('');
    buffer.writeln('📊 *BUDGET OVERVIEW*');
    buffer.writeln('• Total Budget: ${Formatters.price(profile.totalBudget)}');
    buffer.writeln('• Total Spent / Acquired: ${Formatters.price(profile.totalPurchasedSpend)}');
    buffer.writeln('• Remaining Balance: ${Formatters.price(profile.remainingBudget)}');
    buffer.writeln('• Acquired Pieces: ${profile.purchasedCount}/${profile.totalItemsCount}');
    buffer.writeln('• Total Gold Weight: ${profile.totalGoldGrams.toStringAsFixed(1)} grams');
    buffer.writeln('');
    buffer.writeln('✨ *CEREMONY BREAKDOWN*');

    for (final ceremony in BridalCeremony.all) {
      final ceremonyItems = profile.itemsForCeremony(ceremony.id);
      if (ceremonyItems.isEmpty) continue;

      buffer.writeln('\n📍 *${ceremony.title.toUpperCase()}*');
      for (final item in ceremonyItems) {
        final status = item.isPurchased ? '✅' : '⏳';
        final gold = item.targetGoldGrams != null ? ' (${item.targetGoldGrams}g)' : '';
        buffer.writeln('$status ${item.name}$gold - ${Formatters.price(item.effectiveSpend)}');
      }
    }

    buffer.writeln('');
    buffer.writeln('Sent from Jewel Ora Bridal Concierge App');

    try {
      await WhatsAppService.open(phone: storePhone, message: buffer.toString());
    } catch (e) {
      if (context.mounted) {
        showAppSnackBar(context, 'Unable to open WhatsApp: $e', isError: true);
      }
    }
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Bridal Planner?'),
        content: const Text(
          'This will clear your current bridal trousseau profile and all custom items. You can start fresh or reload the starter checklist.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<BridalPlannerProvider>().resetPlanner();
            },
            child: const Text('Reset', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
