import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/utils/formatters.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/empty_state.dart';
import 'package:jewel_ora/models/gold_savings_scheme_model.dart';
import 'package:jewel_ora/providers/auth_provider.dart';
import 'package:jewel_ora/providers/gold_savings_provider.dart';
import 'package:jewel_ora/providers/metal_rate_provider.dart';
import 'package:jewel_ora/providers/settings_provider.dart';
import 'package:jewel_ora/services/whatsapp_service.dart';
import 'package:provider/provider.dart';

class GoldSavingsSchemeSheet extends StatefulWidget {
  const GoldSavingsSchemeSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const GoldSavingsSchemeSheet(),
    );
  }

  @override
  State<GoldSavingsSchemeSheet> createState() => _GoldSavingsSchemeSheetState();
}

class _GoldSavingsSchemeSheetState extends State<GoldSavingsSchemeSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double _monthlyDeposit = 5000.0;
  final TextEditingController _customDepositCtrl =
      TextEditingController(text: '5000');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // If customer already has an active plan, jump directly to Tab 2
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final savings = context.read<GoldSavingsProvider>();
      if (savings.hasActivePlan && mounted) {
        _tabController.animateTo(1);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _customDepositCtrl.dispose();
    super.dispose();
  }

  void _onSelectPreset(double amount) {
    setState(() {
      _monthlyDeposit = amount;
      _customDepositCtrl.text = amount.toInt().toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final metalRates = context.watch<MetalRateProvider>();
    final rate22k = metalRates.rates.gold22k;
    final savings = context.watch<GoldSavingsProvider>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 16, 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('🪙', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.goldSavingsScheme,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppStrings.goldSavingsSubtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

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
                    const Icon(Icons.calculate_outlined, size: 18),
                    const SizedBox(width: 6),
                    Text(AppStrings.schemeCalculator),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined, size: 18),
                    const SizedBox(width: 6),
                    Text(AppStrings.myActivePlan),
                    if (savings.hasActivePlan) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 1, color: AppColors.border),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCalculatorTab(rate22k),
                _buildActivePlanTab(rate22k, savings),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: SCHEME CALCULATOR
  // ==========================================
  Widget _buildCalculatorTab(double rate22k) {
    final customerTotal =
        GoldSavingsCalculator.calculateCustomerTotal(_monthlyDeposit, 11);
    final storeBonus = GoldSavingsCalculator.calculateBonus(_monthlyDeposit);
    final totalMaturity =
        GoldSavingsCalculator.calculateTotalMaturity(_monthlyDeposit, 11);
    final estGrams =
        GoldSavingsCalculator.calculateEstGrams(_monthlyDeposit, rate22k, 11);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Highlight Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryLight,
                  AppColors.accent.withValues(alpha: 0.12),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Text('🎁', style: TextStyle(fontSize: 26)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.savingsBenefitBadge,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Deposit 11 installments. Jewel Ora adds the 12th month installment for free, plus special making charge discounts upon maturity!',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textDark,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Monthly Deposit Presets
          Text(
            AppStrings.monthlyDeposit,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: GoldSavingsCalculator.presetAmounts.map((amount) {
              final isSelected = _monthlyDeposit == amount;
              return ChoiceChip(
                label: Text(Formatters.price(amount)),
                selected: isSelected,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.background,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textDark,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onSelected: (_) => _onSelectPreset(amount),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Custom Input Field
          TextFormField(
            controller: _customDepositCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.currency_rupee_rounded, size: 20),
              labelText: 'Enter Custom Monthly Amount (₹)',
              labelStyle: const TextStyle(fontSize: 12),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
            onChanged: (val) {
              final parsed = double.tryParse(val) ?? 0.0;
              if (parsed > 0) {
                setState(() => _monthlyDeposit = parsed);
              }
            },
          ),
          const SizedBox(height: 20),

          // Live Benchmark Rate Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bolt_rounded, size: 16, color: AppColors.accent),
                    SizedBox(width: 6),
                    Text(
                      'Live 22K Gold Rate',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${Formatters.price(rate22k)} / g',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Luxury Breakdown Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.88),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Top Row: You Pay
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.customerPays,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    Text(
                      Formatters.price(customerTotal),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Middle Row: Jewel Ora Bonus
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.celebration_rounded,
                              size: 16, color: AppColors.accent),
                          const SizedBox(width: 6),
                          Text(
                            AppStrings.storeBonus,
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '+ ${Formatters.price(storeBonus)}',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 12),

                // Total Jewellery Value
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.totalMaturity,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              Formatters.price(totalMaturity),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            AppStrings.accumulatedGold,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 10),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '~${estGrams.toStringAsFixed(2)} g',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Primary Button: Enroll Now
          AppButton(
            title: AppStrings.enrollScheme,
            icon: Icons.check_circle_outline_rounded,
            onPressed: () => _openEnrollDialog(context, _monthlyDeposit),
          ),
          const SizedBox(height: 10),

          // Secondary: Enquire WhatsApp
          AppButton.outlined(
            title: AppStrings.followUpWhatsApp,
            icon: Icons.chat_rounded,
            foregroundColor: AppColors.whatsapp,
            onPressed: () => _chatSchemeWhatsApp(
              monthlyDeposit: _monthlyDeposit,
              customerTotal: customerTotal,
              storeBonus: storeBonus,
              totalMaturity: totalMaturity,
              estGrams: estGrams,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: MY ACTIVE PLAN
  // ==========================================
  Widget _buildActivePlanTab(double rate22k, GoldSavingsProvider savings) {
    final plan = savings.activePlan;

    if (plan == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: EmptyState(
            icon: Icons.account_balance_wallet_outlined,
            title: AppStrings.noActivePlan,
            subtitle: AppStrings.noActivePlanSubtitle,
            actionLabel: AppStrings.schemeCalculator,
            onAction: () => _tabController.animateTo(0),
          ),
        ),
      );
    }

    final estGramsMaturity = plan.calculateAccumulatedGrams(rate22k);
    final estGramsSoFar = plan.calculateGramsSoFar(rate22k);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Plan Header Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      plan.planName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: plan.isMatured
                            ? AppColors.success
                            : AppColors.accent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        plan.isMatured ? 'Matured! 🎉' : 'In Progress',
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${Formatters.price(plan.monthlyDeposit)} / month • 11+1 Scheme',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 14),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Maturity Value',
                            style: TextStyle(color: Colors.white70, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text(
                          Formatters.price(plan.totalMaturityValue),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Est. Gold at Maturity',
                            style: TextStyle(color: Colors.white70, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text(
                          '~${estGramsMaturity.toStringAsFixed(2)} g',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Progress Row: Month X of 11
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppStrings.installmentProgress}: ${plan.monthsPaid} / ${plan.totalTenureMonths} Paid',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                '${((plan.monthsPaid / plan.totalTenureMonths) * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Linear Progress
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: plan.monthsPaid / plan.totalTenureMonths,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),

          // 12-Month Installment Step Grid
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(12, (index) {
              final monthNum = index + 1;
              final is12thBonus = monthNum == 12;
              final isPaid = monthNum <= plan.monthsPaid;
              final isNext = monthNum == plan.monthsPaid + 1;

              Color bg;
              Color border;
              Color text;

              if (is12thBonus) {
                bg = isPaid ? AppColors.accent : AppColors.accent.withValues(alpha: 0.15);
                border = AppColors.accent;
                text = AppColors.textDark;
              } else if (isPaid) {
                bg = AppColors.success.withValues(alpha: 0.15);
                border = AppColors.success;
                text = AppColors.success;
              } else if (isNext) {
                bg = AppColors.primaryLight;
                border = AppColors.primary;
                text = AppColors.primary;
              } else {
                bg = AppColors.background;
                border = AppColors.border;
                text = AppColors.textGrey;
              }

              return Container(
                width: (MediaQuery.of(context).size.width - 40 - 24) / 4,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: border, width: isNext ? 1.5 : 1),
                ),
                child: Column(
                  children: [
                    Text(
                      is12thBonus ? '🎁 12' : 'M$monthNum',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      is12thBonus
                          ? 'FREE'
                          : isPaid
                              ? 'Paid ✓'
                              : isNext
                                  ? 'Due'
                                  : 'Pending',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: text,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          // Financial Summary List
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildSummaryRow(
                  'Amount Deposited So Far',
                  Formatters.price(plan.amountPaidSoFar),
                ),
                const Divider(height: 16, color: AppColors.border),
                _buildSummaryRow(
                  'Remaining Deposit Needed',
                  Formatters.price(plan.remainingAmount),
                ),
                const Divider(height: 16, color: AppColors.border),
                _buildSummaryRow(
                  'Gold Accumulated So Far',
                  '~${estGramsSoFar.toStringAsFixed(2)} g',
                ),
                const Divider(height: 16, color: AppColors.border),
                _buildSummaryRow(
                  'Next Installment Due Date',
                  plan.isMatured
                      ? 'Plan Completed! ✨'
                      : '${plan.nextDueDate.day}/${plan.nextDueDate.month}/${plan.nextDueDate.year}',
                  highlight: !plan.isMatured,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Actions
          if (!plan.isMatured) ...[
            AppButton(
              title: AppStrings.payInstallment,
              icon: Icons.payments_rounded,
              onPressed: () => _confirmPayInstallment(context, plan),
            ),
            const SizedBox(height: 10),
          ] else ...[
            AppButton(
              title: 'Redeem Jewellery at Showroom',
              icon: Icons.storefront_rounded,
              onPressed: () => _chatRedeemWhatsApp(plan),
            ),
            const SizedBox(height: 10),
          ],

          Center(
            child: TextButton.icon(
              icon: const Icon(Icons.delete_outline_rounded,
                  size: 16, color: AppColors.error),
              label: const Text(
                'Cancel & Close Plan',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => _confirmCancelPlan(context, plan.id),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: highlight ? AppColors.primary : AppColors.textDark,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // ENROLL DIALOG
  // ==========================================
  void _openEnrollDialog(BuildContext context, double deposit) {
    final auth = context.read<AuthProvider>();
    final nameCtrl = TextEditingController(text: auth.user?.name ?? '');
    final phoneCtrl = TextEditingController(text: auth.user?.phone ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Text('🪙', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.enrollScheme,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Confirm your enrolment for ${Formatters.price(deposit)}/month (11+1 Plan). First installment starts today.',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                final newPlan = GoldSavingsSchemeModel(
                  id: 'GSS-${DateTime.now().millisecondsSinceEpoch}',
                  monthlyDeposit: deposit,
                  totalTenureMonths: 11,
                  monthsPaid: 1, // first installment paid upon enrolment
                  startDate: DateTime.now(),
                  lastPaymentDate: DateTime.now(),
                  customerName: nameCtrl.text.trim(),
                  customerPhone: phoneCtrl.text.trim(),
                );

                await context.read<GoldSavingsProvider>().enrollPlan(newPlan);
                if (ctx.mounted) Navigator.pop(ctx);
                _tabController.animateTo(1);

                if (context.mounted) {
                  showAppSnackBar(
                    context,
                    '🎉 Enrolled in Swarna Nidhi Plan! Installment 1/11 recorded.',
                  );
                }
              },
              child: const Text('Confirm & Start'),
            ),
          ],
        );
      },
    );
  }

  void _confirmPayInstallment(
      BuildContext context, GoldSavingsSchemeModel plan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Record Monthly Installment'),
        content: Text(
          'Mark installment #${plan.monthsPaid + 1} of ${Formatters.price(plan.monthlyDeposit)} as paid?',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await context.read<GoldSavingsProvider>().payInstallment(plan.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                showAppSnackBar(
                  context,
                  '✓ Installment #${plan.monthsPaid + 1} recorded successfully!',
                );
              }
            },
            child: const Text('Confirm Payment'),
          ),
        ],
      ),
    );
  }

  void _confirmCancelPlan(BuildContext context, String planId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Savings Plan'),
        content: const Text(
          'Are you sure you want to cancel your savings plan? You can visit our showroom anytime to settle refunds or redeem available credits.',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Plan'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await context.read<GoldSavingsProvider>().cancelPlan(planId);
              if (ctx.mounted) Navigator.pop(ctx);
              _tabController.animateTo(0);
              if (context.mounted) {
                showAppSnackBar(context, 'Plan cancelled.');
              }
            },
            child: const Text('Cancel Plan'),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WHATSAPP LAUNCHERS
  // ==========================================
  void _chatSchemeWhatsApp({
    required double monthlyDeposit,
    required double customerTotal,
    required double storeBonus,
    required double totalMaturity,
    required double estGrams,
  }) async {
    final settings = context.read<SettingsProvider>();
    final phone = settings.settings.whatsappNumber;

    final msg = StringBuffer()
      ..writeln('Namaste Jewel Ora team, 🪙')
      ..writeln('I am interested in your Monthly Gold Savings Scheme (11+1 Swarna Nidhi Plan):')
      ..writeln()
      ..writeln('• Monthly Deposit: ${Formatters.price(monthlyDeposit)}')
      ..writeln('• My Contribution (11 Months): ${Formatters.price(customerTotal)}')
      ..writeln('• Jewel Ora Bonus (Month 12): ${Formatters.price(storeBonus)} FREE')
      ..writeln('• Total Redemption Value: ${Formatters.price(totalMaturity)}')
      ..writeln('• Est. Gold Accumulated: ~${estGrams.toStringAsFixed(2)} g')
      ..writeln()
      ..writeln('Please guide me on enrolment procedures and payment methods.');

    try {
      await WhatsAppService.open(
        phone: phone,
        message: msg.toString(),
      );
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, e.toString(), isError: true);
      }
    }
  }

  void _chatRedeemWhatsApp(GoldSavingsSchemeModel plan) async {
    final settings = context.read<SettingsProvider>();
    final phone = settings.settings.whatsappNumber;

    final msg = StringBuffer()
      ..writeln('Namaste Jewel Ora team, 🎉')
      ..writeln('My Swarna Nidhi Gold Savings Scheme is fully matured and ready to redeem!')
      ..writeln()
      ..writeln('• Plan ID: ${plan.id}')
      ..writeln('• Monthly Deposit: ${Formatters.price(plan.monthlyDeposit)}')
      ..writeln('• Total Maturity Value: ${Formatters.price(plan.totalMaturityValue)}')
      ..writeln()
      ..writeln('I would like to visit the showroom to pick my jewellery. Please let me know the best time to visit.');

    try {
      await WhatsAppService.open(
        phone: phone,
        message: msg.toString(),
      );
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, e.toString(), isError: true);
      }
    }
  }
}
