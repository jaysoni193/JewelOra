import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/utils/formatters.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/widgets/app_bottom_sheet.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/empty_state.dart';
import 'package:jewel_ora/models/metal_rate_model.dart';
import 'package:jewel_ora/providers/metal_rate_provider.dart';
import 'package:jewel_ora/providers/price_alert_provider.dart';
import 'package:jewel_ora/providers/shop_filter_provider.dart';
import 'package:jewel_ora/providers/user_nav_provider.dart';
import 'package:provider/provider.dart';

class PriceAlertDialog extends StatefulWidget {
  const PriceAlertDialog({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show(
      context,
      child: const PriceAlertDialog(),
    );
  }

  @override
  State<PriceAlertDialog> createState() => _PriceAlertDialogState();
}

class _PriceAlertDialogState extends State<PriceAlertDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedMetal = 'gold_22k';
  final _targetRateController = TextEditingController();

  static const _metals = [
    ('gold_24k', '24K Pure Gold', 'Investment Coins & Bars', '🥇'),
    ('gold_22k', '22K Hallmark', 'Traditional Jewellery', '👑'),
    ('gold_18k', '18K Gold', 'Diamond & Modern Designs', '💎'),
    ('silver', '999 Fine Silver', 'Silver Jewellery & Utensils', '🥈'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyDefaultTarget();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _targetRateController.dispose();
    super.dispose();
  }

  double _getCurrentRate(MetalRateModel rates) {
    switch (_selectedMetal) {
      case 'gold_24k':
        return rates.gold24k;
      case 'gold_22k':
        return rates.gold22k;
      case 'gold_18k':
        return rates.gold18k;
      case 'silver':
        return rates.silver1g;
      default:
        return rates.gold22k;
    }
  }

  void _applyDefaultTarget([double percentDrop = 2.0]) {
    final rates = context.read<MetalRateProvider>().rates;
    final current = _getCurrentRate(rates);
    if (current > 0) {
      final target = (current * (1.0 - percentDrop / 100.0)).roundToDouble();
      _targetRateController.text = target.toStringAsFixed(0);
      setState(() {});
    }
  }

  Future<void> _createAlert() async {
    final val = double.tryParse(_targetRateController.text.trim());
    if (val == null || val <= 0) {
      showAppSnackBar(context, 'Please enter a valid target rate', isError: true);
      return;
    }

    final provider = context.read<PriceAlertProvider>();
    await provider.addAlert(
      metalType: _selectedMetal,
      targetRate: val,
    );

    if (mounted) {
      showAppSnackBar(context, AppStrings.alertCreated);
      _tabController.animateTo(1); // Switch to active alerts tab
    }
  }

  @override
  Widget build(BuildContext context) {
    final rates = context.watch<MetalRateProvider>().rates;
    final alertProvider = context.watch<PriceAlertProvider>();
    final currentRate = _getCurrentRate(rates);
    final targetRate = double.tryParse(_targetRateController.text) ?? 0.0;
    final dropNeeded = currentRate > 0 && targetRate > 0
        ? currentRate - targetRate
        : 0.0;
    final pctDrop = currentRate > 0 && targetRate > 0
        ? (dropNeeded / currentRate) * 100.0
        : 0.0;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
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
                      color: AppColors.accent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: AppColors.accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.priceAlerts,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          AppStrings.priceAlertsSubtitle,
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
                      const Icon(Icons.add_alert_rounded, size: 16),
                      const SizedBox(width: 6),
                      Text(AppStrings.setRateAlert),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.list_alt_rounded, size: 16),
                      const SizedBox(width: 6),
                      Text(AppStrings.activeAlerts),
                      if (alertProvider.alerts.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: alertProvider.getActiveTriggeredAlerts().isNotEmpty
                                ? AppColors.accent
                                : AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${alertProvider.alerts.length}',
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
              ],
            ),

            const Divider(height: 1),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Create New Target Alert
                  _buildSetAlertTab(context, rates, currentRate, targetRate, dropNeeded, pctDrop),

                  // Tab 2: My Active Alerts
                  _buildAlertsListTab(context, alertProvider, rates),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetAlertTab(
    BuildContext context,
    MetalRateModel rates,
    double currentRate,
    double targetRate,
    double dropNeeded,
    double pctDrop,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        // Metal Type Selection
        const Text(
          'Select Metal Purity',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _metals.map((m) {
            final isSelected = _selectedMetal == m.$1;
            return ChoiceChip(
              avatar: Text(m.$4, style: const TextStyle(fontSize: 14)),
              label: Text(m.$2),
              selected: isSelected,
              selectedColor: AppColors.primaryLight,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textDark,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 1.5 : 1,
              ),
              onSelected: (_) {
                setState(() {
                  _selectedMetal = m.$1;
                  _applyDefaultTarget();
                });
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // Live Rate Reference Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.currentRate.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.currency(currentRate),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text(
                      'per gram live market benchmark',
                      style: TextStyle(fontSize: 11, color: AppColors.textGrey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.fiber_manual_record_rounded, size: 10, color: AppColors.success),
                    SizedBox(width: 4),
                    Text(
                      'Live Rates',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Target Rate Input
        Text(
          AppStrings.alertWhenBelow,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),

        // Quick Percentage Drop Shortcuts
        Row(
          children: [
            _buildPercentChip('-1%', 1.0),
            const SizedBox(width: 8),
            _buildPercentChip('-2%', 2.0),
            const SizedBox(width: 8),
            _buildPercentChip('-3%', 3.0),
            const SizedBox(width: 8),
            _buildPercentChip('-5%', 5.0),
          ],
        ),

        const SizedBox(height: 12),

        // Custom Numeric Text Field
        TextField(
          controller: _targetRateController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            prefixIcon: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Text(
                '₹',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
            suffixText: '/ gram',
            suffixStyle: const TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.w500),
            hintText: 'Enter target rate',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Savings Projection Card
        if (targetRate > 0 && currentRate > 0)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: dropNeeded > 0
                  ? AppColors.primaryLight.withValues(alpha: 0.4)
                  : AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              border: Border.all(
                color: dropNeeded > 0
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.accent.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  dropNeeded > 0 ? Icons.trending_down_rounded : Icons.check_circle_rounded,
                  color: dropNeeded > 0 ? AppColors.primary : AppColors.accent,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dropNeeded > 0
                            ? 'Requires ₹${dropNeeded.toStringAsFixed(0)} (${pctDrop.toStringAsFixed(1)}%) drop'
                            : 'Target is already reached at current rate!',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: dropNeeded > 0 ? AppColors.primary : AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dropNeeded > 0
                            ? 'You will save ~₹${(dropNeeded * 10).toStringAsFixed(0)} on a 10-gram piece when this rate hits.'
                            : 'You can purchase jewellery immediately at this rate.',
                        style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 20),

        // Submit Button
        AppButton(
          title: 'Save Price Alert 🔔',
          onPressed: _createAlert,
        ),
      ],
    );
  }

  Widget _buildPercentChip(String label, double percent) {
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: AppColors.surface,
        ),
        onPressed: () => _applyDefaultTarget(percent),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildAlertsListTab(
    BuildContext context,
    PriceAlertProvider alertProvider,
    MetalRateModel rates,
  ) {
    final alerts = alertProvider.alerts;

    if (alerts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: EmptyState(
            title: AppStrings.noActiveAlerts,
            subtitle: AppStrings.noAlertsSubtitle,
            icon: Icons.notifications_none_rounded,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: alerts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final alert = alerts[i];
        final current = alert.getCurrentRate(rates);
        final isHit = alert.checkHit(rates);
        final drop = current - alert.targetRate;
        final pctDiff = alert.percentageDiff(current);

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isHit
                ? AppColors.accent.withValues(alpha: 0.08)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(
              color: isHit
                  ? AppColors.accent.withValues(alpha: 0.5)
                  : AppColors.border,
              width: isHit ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Metal name & Switch / Delete
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      alert.metalLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Active Toggle Switch
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: alert.isActive,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) => alertProvider.toggleAlert(alert.id, val),
                    ),
                  ),
                  // Delete Button
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                    tooltip: 'Delete alert',
                    onPressed: () {
                      alertProvider.removeAlert(alert.id);
                      showAppSnackBar(context, AppStrings.alertDeleted);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Rates Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.targetRate.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textGrey,
                          ),
                        ),
                        Text(
                          Formatters.currency(alert.targetRate),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.currentRate.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textGrey,
                          ),
                        ),
                        Text(
                          Formatters.currency(current),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isHit ? AppColors.accent : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Status Banner
              if (isHit)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.celebration_rounded, size: 18, color: AppColors.accent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppStrings.targetReached,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.read<ShopFilterProvider>().clearFilters();
                          context.read<UserNavProvider>().setIndex(UserNavProvider.shopTab);
                        },
                        child: const Text(
                          'Shop Now →',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Row(
                  children: [
                    const Icon(Icons.timelapse_rounded, size: 14, color: AppColors.textGrey),
                    const SizedBox(width: 6),
                    Text(
                      'Needs ₹${drop.toStringAsFixed(0)} (${pctDiff.abs().toStringAsFixed(1)}%) drop to trigger',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textGrey,
                        fontWeight: FontWeight.w500,
                      ),
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
