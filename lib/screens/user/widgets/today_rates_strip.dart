import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/utils/formatters.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/models/metal_rate_model.dart';
import 'package:jewel_ora/providers/metal_rate_provider.dart';
import 'package:jewel_ora/providers/price_alert_provider.dart';
import 'package:jewel_ora/screens/user/widgets/gold_savings_scheme_sheet.dart';
import 'package:jewel_ora/screens/user/widgets/old_gold_calculator_dialog.dart';
import 'package:jewel_ora/screens/user/widgets/price_alert_dialog.dart';
import 'package:provider/provider.dart';

class TodayRatesStrip extends StatelessWidget {
  const TodayRatesStrip({super.key});

  void _openCalculator(BuildContext context, MetalRateModel rates) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RateCalculatorSheet(rates: rates),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MetalRateProvider>();
    final rates = provider.rates;
    final alertProvider = context.watch<PriceAlertProvider>();
    final triggeredAlerts = alertProvider.getActiveTriggeredAlerts();

    if (!rates.isEnabled) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(
          color: triggeredAlerts.isNotEmpty
              ? AppColors.accent.withValues(alpha: 0.5)
              : AppColors.border,
          width: triggeredAlerts.isNotEmpty ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  AppStrings.todayRates.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt_rounded, size: 11, color: AppColors.success),
                    SizedBox(width: 2),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Celebratory Triggered Alert Pill (if any alert target reached)
          if (triggeredAlerts.isNotEmpty) ...[
            const SizedBox(height: 8),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => PriceAlertDialog.show(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Text('🎉', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Target Reached! ${triggeredAlerts.first.metalLabel} is now ${Formatters.currency(triggeredAlerts.first.getCurrentRate(rates))}/g',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.accent),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),

          // Rates Cards Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _RateChip(
                  label: '24K Gold',
                  pricePerGram: rates.gold24k,
                  change: rates.gold24kChange,
                  isGold: true,
                ),
                const SizedBox(width: 8),
                _RateChip(
                  label: '22K Gold',
                  pricePerGram: rates.gold22k,
                  subtitle: 'Jewellery',
                  isGold: true,
                ),
                const SizedBox(width: 8),
                _RateChip(
                  label: '18K Gold',
                  pricePerGram: rates.gold18k,
                  subtitle: 'Diamond',
                  isGold: true,
                ),
                const SizedBox(width: 8),
                _RateChip(
                  label: 'Silver',
                  pricePerGram: rates.silver1g,
                  change: rates.silverChange,
                  isGold: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Quick Action Tools: Exchange | Price Alert | Calculator
          Row(
            children: [
              Expanded(
                child: _RatesActionButton(
                  icon: Icons.scale_rounded,
                  label: 'Exchange ⚖️',
                  color: AppColors.accent,
                  onTap: () => OldGoldCalculatorSheet.show(context),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _RatesActionButton(
                  icon: triggeredAlerts.isNotEmpty
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_none_rounded,
                  label: triggeredAlerts.isNotEmpty
                      ? 'Target Hit (${triggeredAlerts.length}) 🎉'
                      : 'Price Alert 🔔',
                  color: triggeredAlerts.isNotEmpty ? AppColors.accent : AppColors.primary,
                  onTap: () => PriceAlertDialog.show(context),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _RatesActionButton(
                  icon: Icons.calculate_outlined,
                  label: AppStrings.calculate,
                  color: AppColors.primary,
                  onTap: () => _openCalculator(context, rates),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => GoldSavingsSchemeSheet.show(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${AppStrings.goldSavingsScheme} (11+1 Plan) • 1 Month FREE!',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RateChip extends StatelessWidget {
  final String label;
  final double pricePerGram;
  final double? change;
  final String? subtitle;
  final bool isGold;

  const _RateChip({
    required this.label,
    required this.pricePerGram,
    this.change,
    this.subtitle,
    required this.isGold,
  });

  @override
  Widget build(BuildContext context) {
    final hasChange = change != null && change != 0;
    final isUp = hasChange && change! > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderAccent.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGrey,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(width: 4),
                Text(
                  '($subtitle)',
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${Formatters.price(pricePerGram)}/g',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              if (hasChange) ...[
                const SizedBox(width: 4),
                Icon(
                  isUp ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                  size: 16,
                  color: isUp ? AppColors.success : AppColors.error,
                ),
                Text(
                  '${isUp ? '+' : ''}${change!.abs().toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isUp ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _RatesActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _RatesActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: color.withValues(alpha: 0.22),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RateCalculatorSheet extends StatefulWidget {
  final MetalRateModel rates;
  const RateCalculatorSheet({super.key, required this.rates});

  @override
  State<RateCalculatorSheet> createState() => _RateCalculatorSheetState();
}

class _RateCalculatorSheetState extends State<RateCalculatorSheet> {
  String _selectedMetal = '22K';
  final TextEditingController _weightCtrl = TextEditingController(text: '10');

  double get _currentRate {
    switch (_selectedMetal) {
      case '24K':
        return widget.rates.gold24k;
      case '22K':
        return widget.rates.gold22k;
      case '18K':
        return widget.rates.gold18k;
      case 'Silver':
        return widget.rates.silver1g;
      default:
        return widget.rates.gold22k;
    }
  }

  double get _calculatedTotal {
    final weight = double.tryParse(_weightCtrl.text.trim()) ?? 0.0;
    return weight * _currentRate;
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Live Rate Calculator',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Metal Selector Chips
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: '24K', label: Text('24K')),
                  ButtonSegment(value: '22K', label: Text('22K')),
                  ButtonSegment(value: '18K', label: Text('18K')),
                  ButtonSegment(value: 'Silver', label: Text('Silver')),
                ],
                selected: {_selectedMetal},
                onSelectionChanged: (set) => setState(() => _selectedMetal = set.first),
              ),
              const SizedBox(height: 16),
              // Weight input
              TextField(
                controller: _weightCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Weight (in Grams)',
                  suffixText: 'Grams',
                  prefixIcon: const Icon(Icons.scale_rounded, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              // Estimated Total Display Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderAccent),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rate: ${Formatters.price(_currentRate)} / g',
                          style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Estimated Value',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      Formatters.price(_calculatedTotal),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                title: 'Close',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef RateCalculatorDialog = RateCalculatorSheet;
