import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/utils/formatters.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/models/diamond_guide_model.dart';
import 'package:jewel_ora/providers/settings_provider.dart';
import 'package:jewel_ora/providers/shop_filter_provider.dart';
import 'package:jewel_ora/providers/user_nav_provider.dart';
import 'package:jewel_ora/services/whatsapp_service.dart';
import 'package:provider/provider.dart';

class DiamondGuideSheet extends StatefulWidget {
  final double initialCarat;

  const DiamondGuideSheet({
    super.key,
    this.initialCarat = 1.00,
  });

  static Future<void> show(BuildContext context, {double initialCarat = 1.00}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DiamondGuideSheet(initialCarat: initialCarat),
    );
  }

  @override
  State<DiamondGuideSheet> createState() => _DiamondGuideSheetState();
}

class _DiamondGuideSheetState extends State<DiamondGuideSheet> {
  late double _carat;
  String _selectedCut = 'excellent';
  String _selectedColor = 'g_h';
  String _selectedClarity = 'vs';

  @override
  void initState() {
    super.initState();
    _carat = widget.initialCarat.clamp(0.20, 3.00);
  }

  @override
  Widget build(BuildContext context) {
    final cut = DiamondCut.getById(_selectedCut);
    final color = DiamondColor.getById(_selectedColor);
    final clarity = DiamondClarity.getById(_selectedClarity);

    final diameterMm = DiamondGuideCalculator.calculateDiameterMm(_carat);
    final estPrice = DiamondGuideCalculator.estimateBenchmarkPrice(
      carat: _carat,
      cutId: _selectedCut,
      colorId: _selectedColor,
      clarityId: _selectedClarity,
    );
    final sparkleRating = DiamondGuideCalculator.calculateSparkleRating(
      _selectedCut,
      _selectedClarity,
    );

    // Visual scale: map 0.20ct - 3.00ct to physical pixel size 45px - 100px
    final previewSize = (40.0 + (_carat * 22.0)).clamp(44.0, 105.0);

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
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
            padding: const EdgeInsets.fromLTRB(20, 4, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('💎', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.diamondGuide,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppStrings.diamondGuideSubtitle,
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
          const Divider(height: 1, color: AppColors.border),

          // Scrollable Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Luxury Solitaire Visualizer Showcase
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1E2638),
                          AppColors.primary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Animated / Scaled Diamond Centerpiece
                        Container(
                          height: 110,
                          alignment: Alignment.center,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutBack,
                            width: previewSize,
                            height: previewSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(color.colorHex),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: AppColors.accent.withValues(alpha: 0.5),
                                  blurRadius: 10,
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.8),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '💎',
                                style: TextStyle(
                                  fontSize: (previewSize * 0.55).clamp(20, 52),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Carat & Dimensions Header
                        Text(
                          '${_carat.toStringAsFixed(2)} Carat Round Brilliant',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${cut.label} • ${color.grade} • ${clarity.grade}',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white24, height: 1),
                        const SizedBox(height: 14),

                        // Metric Trio: Diameter, Sparkle & Benchmark Value
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMetricItem(
                              label: AppStrings.diamondMillimeter,
                              value: '~${diameterMm.toStringAsFixed(2)} mm',
                              icon: Icons.straighten_rounded,
                            ),
                            Container(width: 1, height: 32, color: Colors.white24),
                            _buildMetricItem(
                              label: 'Brilliance & Fire',
                              value: '$sparkleRating% ✨',
                              icon: Icons.auto_awesome_rounded,
                            ),
                            Container(width: 1, height: 32, color: Colors.white24),
                            _buildMetricItem(
                              label: AppStrings.estDiamondValue,
                              value: Formatters.compactPrice(estPrice),
                              icon: Icons.currency_rupee_rounded,
                              highlight: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // 1. CARAT WEIGHT (SIZE)
                  _buildSectionHeader('1. ${AppStrings.caratWeight}', '${_carat.toStringAsFixed(2)} ct'),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: DiamondGuideCalculator.popularCarats.map((c) {
                      final isSelected = (_carat - c).abs() < 0.02;
                      return ChoiceChip(
                        label: Text('${c.toStringAsFixed(2)} ct'),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.background,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textDark,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 11,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onSelected: (_) => setState(() => _carat = c),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 6),

                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: AppColors.border,
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primary.withValues(alpha: 0.15),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: _carat,
                      min: 0.20,
                      max: 3.00,
                      divisions: 56, // 0.05 step
                      label: '${_carat.toStringAsFixed(2)} ct',
                      onChanged: (val) => setState(() => _carat = val),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. CUT QUALITY
                  _buildSectionHeader('2. ${AppStrings.cut} (Fire & Light Reflection)', cut.label),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: DiamondCut.all.map((item) {
                      final isSelected = _selectedCut == item.id;
                      return ChoiceChip(
                        label: Text(item.label),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.background,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textDark,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 11,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onSelected: (_) => setState(() => _selectedCut = item.id),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 6),
                  _buildDescriptionBox(cut.description),
                  const SizedBox(height: 18),

                  // 3. COLOR GRADE
                  _buildSectionHeader('3. ${AppStrings.color} (Whiteness)', color.label),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: DiamondColor.all.map((item) {
                      final isSelected = _selectedColor == item.id;
                      return ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Color(item.colorHex),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black26),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(item.label),
                          ],
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.background,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textDark,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 11,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onSelected: (_) => setState(() => _selectedColor = item.id),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 6),
                  _buildDescriptionBox(color.description),
                  const SizedBox(height: 18),

                  // 4. CLARITY (INCLUSIONS)
                  _buildSectionHeader('4. ${AppStrings.clarity} (Purity under 10x)', clarity.label),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: DiamondClarity.all.map((item) {
                      final isSelected = _selectedClarity == item.id;
                      return ChoiceChip(
                        label: Text(item.label),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.background,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textDark,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 11,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onSelected: (_) => setState(() => _selectedClarity = item.id),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 6),
                  _buildDescriptionBox(clarity.description),
                  const SizedBox(height: 20),

                  // Jeweller Secret / Smart Buyer Tip
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('💡', style: TextStyle(fontSize: 20)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Smart Buyer Recommendation',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Cut is king! Prioritize an Excellent Cut first. Combining an Excellent Cut with G-H Color and VS Clarity looks 100% identical to flawless stones to the naked eye, while saving up to 40%!',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textDark,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Action Buttons
                  AppButton(
                    title: AppStrings.exploreSolitaires,
                    icon: Icons.diamond_outlined,
                    onPressed: () {
                      Navigator.pop(context);
                      context.read<ShopFilterProvider>().setQuery('Diamond');
                      context.read<UserNavProvider>().setIndex(UserNavProvider.shopTab);
                    },
                  ),
                  const SizedBox(height: 10),

                  AppButton.outlined(
                    title: 'Enquire for this Diamond on WhatsApp',
                    icon: Icons.chat_rounded,
                    foregroundColor: AppColors.whatsapp,
                    onPressed: () => _chatSolitaireWhatsApp(
                      carat: _carat,
                      diameterMm: diameterMm,
                      cut: cut,
                      color: color,
                      clarity: clarity,
                      estPrice: estPrice,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String activeValue) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        Text(
          activeValue,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionBox(String desc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        desc,
        style: const TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.3),
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required IconData icon,
    bool highlight = false,
  }) {
    return Column(
      children: [
        Icon(icon, size: 14, color: highlight ? AppColors.accent : Colors.white70),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: highlight ? AppColors.accent : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 10),
        ),
      ],
    );
  }

  void _chatSolitaireWhatsApp({
    required double carat,
    required double diameterMm,
    required DiamondCut cut,
    required DiamondColor color,
    required DiamondClarity clarity,
    required double estPrice,
  }) async {
    final settings = context.read<SettingsProvider>();
    final storePhone = settings.settings.whatsappNumber;

    final msg = StringBuffer()
      ..writeln('Namaste Jewel Ora team, 💎')
      ..writeln('I am interested in a certified Diamond Solitaire with the following specifications:')
      ..writeln()
      ..writeln('• Carat Weight: ${carat.toStringAsFixed(2)} ct (~${diameterMm.toStringAsFixed(2)} mm)')
      ..writeln('• Cut Quality: ${cut.label}')
      ..writeln('• Color Grade: ${color.label}')
      ..writeln('• Clarity Grade: ${clarity.label}')
      ..writeln('• Est. Budget: ${Formatters.price(estPrice)}')
      ..writeln()
      ..writeln('Please share certified IGI/GIA loose solitaires or mounting ring designs in this specification.');

    try {
      await WhatsAppService.open(
        phone: storePhone,
        message: msg.toString(),
      );
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, e.toString(), isError: true);
      }
    }
  }
}
