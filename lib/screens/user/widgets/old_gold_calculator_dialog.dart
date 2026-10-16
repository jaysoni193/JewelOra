import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/utils/formatters.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/widgets/app_bottom_sheet.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/models/metal_rate_model.dart';
import 'package:jewel_ora/providers/metal_rate_provider.dart';
import 'package:jewel_ora/providers/settings_provider.dart';
import 'package:jewel_ora/screens/user/book_visit_dialog.dart';
import 'package:jewel_ora/services/whatsapp_service.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class OldGoldCalculatorSheet extends StatefulWidget {
  const OldGoldCalculatorSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show(
      context,
      child: const OldGoldCalculatorSheet(),
    );
  }

  @override
  State<OldGoldCalculatorSheet> createState() => _OldGoldCalculatorSheetState();
}

class _OldGoldCalculatorSheetState extends State<OldGoldCalculatorSheet> {
  // Purities list: (label, purityPct, karatNum, hallmarkTag, description)
  static const _purities = [
    ('22K Gold', 0.9167, 22, '916 BIS Hallmark', 'Standard Indian Jewellery'),
    ('24K Gold', 0.9990, 24, '999 Pure Gold', 'Coins, Biscuits & Bars'),
    ('20K Gold', 0.8333, 20, '833 Hallmark', 'Traditional / Vintage Pieces'),
    ('18K Gold', 0.7500, 18, '750 Hallmark', 'Diamond & Studded Jewellery'),
    ('14K Gold', 0.5833, 14, '585 Hallmark', 'Modern & Lightweight Wear'),
    ('925 Silver', 0.9250, 0, '925 Fine Silver', 'Payal, Utensils & Silver Coins'),
  ];

  int _selectedPurityIndex = 0; // Default to 22K (916)
  late final TextEditingController _grossWeightCtrl;
  late final TextEditingController _stoneWeightCtrl;
  bool _hasStones = false;
  int _deductionScheme = 0; // 0 = 100% Exchange (0%), 1 = Melting test (2%), 2 = Cash buyback (3%)

  @override
  void initState() {
    super.initState();
    _grossWeightCtrl = TextEditingController(text: '10.0');
    _stoneWeightCtrl = TextEditingController(text: '0.0');
  }

  @override
  void dispose() {
    _grossWeightCtrl.dispose();
    _stoneWeightCtrl.dispose();
    super.dispose();
  }

  double _getBenchmarkRatePerGram(MetalRateModel rates) {
    final sel = _purities[_selectedPurityIndex];
    if (sel.$3 == 0) {
      // Silver
      return rates.silver1g * 0.925;
    } else if (sel.$3 == 24) {
      return rates.gold24k;
    } else if (sel.$3 == 22) {
      return rates.gold22k;
    } else if (sel.$3 == 18) {
      return rates.gold18k;
    } else {
      // 20K or 14K proportional to 24K
      return rates.gold24k * sel.$2;
    }
  }

  double get _grossWeight => double.tryParse(_grossWeightCtrl.text) ?? 0.0;
  double get _stoneWeight => _hasStones ? (double.tryParse(_stoneWeightCtrl.text) ?? 0.0) : 0.0;
  double get _netWeight => (_grossWeight - _stoneWeight).clamp(0.0, 100000.0);

  double _calculateValuation(MetalRateModel rates) {
    final ratePerGram = _getBenchmarkRatePerGram(rates);
    final rawValue = _netWeight * ratePerGram;

    final deductionPercent = switch (_deductionScheme) {
      1 => 2.0, // 2% melting testing allowance
      2 => 3.0, // 3% cash buyback fee
      _ => 0.0, // 0% 100% exchange
    };

    return (rawValue * (1.0 - (deductionPercent / 100.0))).clamp(0.0, double.infinity);
  }

  double _calculatePureGoldEquivalent() {
    final sel = _purities[_selectedPurityIndex];
    return _netWeight * sel.$2;
  }

  void _addWeight(double grams) {
    final current = _grossWeight;
    final updated = (current + grams).clamp(0.1, 1000.0);
    setState(() {
      _grossWeightCtrl.text = updated.toStringAsFixed(1);
    });
  }

  String _buildSummaryText(MetalRateModel rates) {
    final sel = _purities[_selectedPurityIndex];
    final ratePerGram = _getBenchmarkRatePerGram(rates);
    final val = _calculateValuation(rates);
    final pureGold = _calculatePureGoldEquivalent();

    return '''
*Old Gold Valuation Summary - Jewel Ora*
• Purity: ${sel.$1} (${sel.$4})
• Today's Benchmark Rate: ${Formatters.price(ratePerGram)}/g
• Gross Weight: ${_grossWeight.toStringAsFixed(2)} g
${_hasStones ? '• Stone/Wax Deduction: ${_stoneWeight.toStringAsFixed(2)} g\n' : ''}• Net Weight: ${_netWeight.toStringAsFixed(2)} g
• 24K Pure Equivalent: ${pureGold.toStringAsFixed(2)} g
• Estimated Trade-In Value: *${Formatters.price(val)}*
(100% Exchange Value valid when upgrading to new jewellery at Jewel Ora)
''';
  }

  Future<void> _chatShowroom(MetalRateModel rates) async {
    final settings = context.read<SettingsProvider>().settings;
    final summary = _buildSummaryText(rates);
    final message = '''
Hello Jewel Ora! I checked my Old Gold Valuation on your app:

$summary
I would like to bring my jewellery to your showroom for verification and exchange against new pieces.
''';

    try {
      await WhatsAppService.open(phone: settings.whatsappNumber, message: message);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) showAppSnackBar(context, '$e', isError: true);
    }
  }

  Future<void> _shareValuation(MetalRateModel rates) async {
    final text = _buildSummaryText(rates);
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          subject: 'Old Gold Exchange Valuation - Jewel Ora',
        ),
      );
    } catch (e) {
      if (mounted) showAppSnackBar(context, 'Sharing failed: $e', isError: true);
    }
  }

  void _openBookingSheet() {
    final sel = _purities[_selectedPurityIndex];
    Navigator.of(context).pop();
    BookVisitSheet.show(
      context,
      initialCategory: 'Old Gold Exchange & Valuation',
      initialNotes:
          'Old Gold Trade-in: ${_netWeight.toStringAsFixed(2)}g ${sel.$1}. Ready for showroom karatmeter test.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final ratesP = context.watch<MetalRateProvider>();
    final rates = ratesP.rates;
    final currentPurity = _purities[_selectedPurityIndex];
    final benchmarkRate = _getBenchmarkRatePerGram(rates);
    final valuation = _calculateValuation(rates);
    final pureEquivalent = _calculatePureGoldEquivalent();

    return Material(
      color: AppColors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.scale_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Old Gold Valuation',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '100% Exchange Value at Today’s Live Rate',
                            style: TextStyle(
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
                const SizedBox(height: 16),

                // Benchmark Rate Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Today's Benchmark ${currentPurity.$1} Rate",
                              style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${Formatters.price(benchmarkRate)} / gram',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_rounded, size: 14, color: AppColors.success),
                            SizedBox(width: 4),
                            Text(
                              'Live Verified',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDark),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 1. Select Purity
                const Text(
                  'Select Gold / Silver Purity',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(_purities.length, (idx) {
                    final item = _purities[idx];
                    final isSel = _selectedPurityIndex == idx;
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(() => _selectedPurityIndex = idx),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSel ? AppColors.primary : AppColors.border,
                            width: isSel ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.$1,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isSel ? Colors.white : AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.$4,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: isSel ? Colors.white70 : AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 18),

                // 2. Gross Weight Input
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Gross Weight (Grams)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                    ),
                    Text(
                      '${_grossWeight.toStringAsFixed(2)} g',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _grossWeightCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.scale_outlined, size: 20),
                    suffixText: 'Grams',
                    hintText: 'Enter jewellery weight in grams',
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 8),

                // Quick weight increment buttons (+1g, +5g, +10g, +20g)
                Wrap(
                  spacing: 6,
                  children: [
                    ActionChip(
                      label: const Text('+1g', style: TextStyle(fontSize: 11)),
                      onPressed: () => _addWeight(1.0),
                    ),
                    ActionChip(
                      label: const Text('+5g', style: TextStyle(fontSize: 11)),
                      onPressed: () => _addWeight(5.0),
                    ),
                    ActionChip(
                      label: const Text('+10g', style: TextStyle(fontSize: 11)),
                      onPressed: () => _addWeight(10.0),
                    ),
                    ActionChip(
                      label: const Text('+20g', style: TextStyle(fontSize: 11)),
                      onPressed: () => _addWeight(20.0),
                    ),
                    ActionChip(
                      label: const Text('Reset', style: TextStyle(fontSize: 11, color: AppColors.error)),
                      onPressed: () => setState(() => _grossWeightCtrl.text = '10.0'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 3. Stone / Wax Deductions Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contains Stones, Pearls or Wax?',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                          ),
                          Text(
                            'Deduct non-gold weight for exact net gold',
                            style: TextStyle(fontSize: 11, color: AppColors.textGrey),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _hasStones,
                      activeThumbColor: AppColors.accent,
                      onChanged: (val) => setState(() => _hasStones = val),
                    ),
                  ],
                ),
                if (_hasStones) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _stoneWeightCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Stone / Wax Deduction (Grams)',
                      prefixIcon: const Icon(Icons.remove_circle_outline_rounded, size: 20, color: AppColors.accent),
                      suffixText: 'Grams',
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
                const SizedBox(height: 18),

                // 4. Exchange Scheme
                const Text(
                  'Choose Exchange Option',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => setState(() => _deductionScheme = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          decoration: BoxDecoration(
                            color: _deductionScheme == 0 ? AppColors.successLight : AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _deductionScheme == 0 ? AppColors.success : AppColors.border,
                              width: _deductionScheme == 0 ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Store Exchange',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _deductionScheme == 0 ? AppColors.success : AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                '100% Full Value',
                                style: TextStyle(fontSize: 10, color: AppColors.textGrey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => setState(() => _deductionScheme = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          decoration: BoxDecoration(
                            color: _deductionScheme == 1 ? AppColors.primaryLight : AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _deductionScheme == 1 ? AppColors.primary : AppColors.border,
                              width: _deductionScheme == 1 ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Melting Test',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _deductionScheme == 1 ? AppColors.primary : AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                '2% Melting Loss',
                                style: TextStyle(fontSize: 10, color: AppColors.textGrey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => setState(() => _deductionScheme = 2),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          decoration: BoxDecoration(
                            color: _deductionScheme == 2 ? AppColors.accent.withValues(alpha: 0.12) : AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _deductionScheme == 2 ? AppColors.accent : AppColors.border,
                              width: _deductionScheme == 2 ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Cash Payout',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _deductionScheme == 2 ? AppColors.accent : AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                '3% Bank Handling',
                                style: TextStyle(fontSize: 10, color: AppColors.textGrey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Luxury Valuation Result Card
                Container(
                  padding: const EdgeInsets.all(16),
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
                        color: AppColors.primary.withValues(alpha: 0.25),
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
                          const Text(
                            'Estimated Trade-In Value',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _deductionScheme == 0 ? '100% Exchange' : (_deductionScheme == 1 ? 'Melting Allowance' : 'Cash Payout'),
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        Formatters.price(valuation),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Colors.white24, height: 1),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Net Metal Weight', style: TextStyle(color: Colors.white60, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(
                                '${_netWeight.toStringAsFixed(2)} g',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text('24K Fine Equivalent', style: TextStyle(color: Colors.white60, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(
                                '${pureEquivalent.toStringAsFixed(2)} g',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Rate Applied', style: TextStyle(color: Colors.white60, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(
                                '${Formatters.price(benchmarkRate)}/g',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Transparency Trust Note
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.shield_outlined, size: 16, color: AppColors.primary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Jewel Ora Karatmeter Promise: Free computerised purity test & zero melting loss on BIS 916 jewellery exchange.',
                          style: TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Primary Action: Book Showroom Evaluation
                AppButton(
                  title: 'Book Showroom Evaluation',
                  icon: Icons.calendar_month_rounded,
                  onPressed: _openBookingSheet,
                ),
                const SizedBox(height: 10),

                // Secondary Actions: WhatsApp & Share
                Row(
                  children: [
                    Expanded(
                      child: AppButton.outlined(
                        title: 'Enquire on WhatsApp',
                        icon: Icons.chat_rounded,
                        foregroundColor: AppColors.whatsapp,
                        onPressed: () => _chatShowroom(rates),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filledTonal(
                      tooltip: 'Share Valuation Breakdown',
                      icon: const Icon(Icons.share_rounded, color: AppColors.primary),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.all(14),
                      ),
                      onPressed: () => _shareValuation(rates),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
