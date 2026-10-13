import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/utils/formatters.dart';
import 'package:jewel_ora/models/metal_rate_model.dart';
import 'package:jewel_ora/providers/metal_rate_provider.dart';
import 'package:provider/provider.dart';

class TodayRatesStrip extends StatelessWidget {
  const TodayRatesStrip({super.key});

  void _openCalculator(BuildContext context, MetalRateModel rates) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _RateCalculatorSheet(rates: rates),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MetalRateProvider>();
    final rates = provider.rates;

    if (!rates.isEnabled) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.border),
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
              const Text(
                "TODAY'S METAL RATES",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => _openCalculator(context, rates),
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    children: [
                      Icon(Icons.calculate_outlined, size: 14, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text(
                        'Calculate',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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

class _RateCalculatorSheet extends StatefulWidget {
  final MetalRateModel rates;
  const _RateCalculatorSheet({required this.rates});

  @override
  State<_RateCalculatorSheet> createState() => _RateCalculatorSheetState();
}

class _RateCalculatorSheetState extends State<_RateCalculatorSheet> {
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
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Live Gold & Silver Calculator',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
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
              ButtonSegment(value: '24K', label: Text('24K Gold')),
              ButtonSegment(value: '22K', label: Text('22K Gold')),
              ButtonSegment(value: '18K', label: Text('18K Gold')),
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
                      'Rate: ${Formatters.price(_currentRate)} / gram',
                      style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Estimated Metal Value',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    ),
                  ],
                ),
                Text(
                  Formatters.price(_calculatedTotal),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
