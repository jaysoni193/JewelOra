import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/widgets/app_bottom_sheet.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/models/ring_size_model.dart';
import 'package:jewel_ora/providers/ring_size_provider.dart';
import 'package:provider/provider.dart';

class RingSizeGuideSheet extends StatefulWidget {
  final int initialTab;

  const RingSizeGuideSheet({super.key, this.initialTab = 0});

  static Future<void> show(BuildContext context, {int initialTab = 0}) {
    return AppBottomSheet.show(
      context,
      child: RingSizeGuideSheet(initialTab: initialTab),
    );
  }

  @override
  State<RingSizeGuideSheet> createState() => _RingSizeGuideSheetState();
}

class _RingSizeGuideSheetState extends State<RingSizeGuideSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  // Standalone fallback when provider is not mounted in widget tests
  late RingSizeProvider _fallbackSizer;

  // Ring Sizer state
  double _ringDiameter = 17.3; // Default Indian Size 14 (17.3 mm)

  // Bangle Sizer state
  double _bangleDiameter = 60.3; // Default Indian Bangle 2-6 (60.3 mm)

  // Calibration state
  int _calibrationMode = 0; // 0 = Credit Card, 1 = ₹5 Coin
  double _calibratingWidth = 85.6 * ScreenCalibrationConstants.defaultPixelsPerMm;

  @override
  void initState() {
    super.initState();
    _fallbackSizer = RingSizeProvider();
    _selectedTab = widget.initialTab.clamp(0, 3);
    _tabController = TabController(length: 4, vsync: this, initialIndex: _selectedTab);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && _selectedTab != _tabController.index) {
        setState(() => _selectedTab = _tabController.index);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        RingSizeProvider? sizer;
        try {
          sizer = context.read<RingSizeProvider>();
        } catch (_) {
          sizer = _fallbackSizer;
        }
        setState(() {
          _calibratingWidth = (ScreenCalibrationConstants.creditCardWidthMm * sizer!.pixelsPerMm).clamp(250.0, 650.0);
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  RingSizeProvider _getSizer(BuildContext context) {
    try {
      return context.watch<RingSizeProvider>();
    } catch (_) {
      return _fallbackSizer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizer = _getSizer(context);

    return Material(
      color: AppColors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.90,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 12, 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.straighten_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.ringBangleSizer,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            sizer.isCalibrated
                                ? 'Physical 1:1 Scale Calibrated ✓'
                                : 'Place ring/bangle on screen to measure',
                            style: TextStyle(
                              fontSize: 11,
                              color: sizer.isCalibrated ? AppColors.success : AppColors.textGrey,
                              fontWeight: sizer.isCalibrated ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textGrey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Tab Bar (Ring Chart, Visual Sizer, Bangles, Calibrate)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  onTap: (index) => setState(() => _selectedTab = index),
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 2.5,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textGrey,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  tabs: const [
                    Tab(text: 'Ring Chart'),
                    Tab(text: 'Visual Sizer'),
                    Tab(text: 'Bangles'),
                    Tab(text: 'Calibrate 📏'),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Active Tab Content
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: _buildActiveTabContent(sizer),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTabContent(RingSizeProvider sizer) {
    switch (_selectedTab) {
      case 1:
        return _buildVisualSizerTab(sizer);
      case 2:
        return _buildBanglesTab(sizer);
      case 3:
        return _buildCalibrationTab(sizer);
      case 0:
      default:
        return _buildRingChartTab();
    }
  }

  // =========================================================================
  // TAB 0: Ring Chart
  // =========================================================================
  Widget _buildRingChartTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Most popular Indian ring size for women is 12-14, and for men is 18-20.',
                    style: TextStyle(fontSize: 11.5, color: AppColors.primaryDark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Table(
            border: TableBorder.all(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(8),
            ),
            children: [
              const TableRow(
                decoration: BoxDecoration(color: AppColors.surfaceVariant),
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                    child: Text('India Size', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                    child: Text('US Size', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                    child: Text('Diameter', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                    child: Text('Circumf.', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
                ],
              ),
              for (final r in RingSizeData.all)
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Text(r.indiaSize, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Text(r.usSize, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Text('${r.diameterMm} mm', style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Text('${r.circumferenceMm} mm', style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 1: Visual Sizer (Physical Scaled Ring Target + Steppers)
  // =========================================================================
  Widget _buildVisualSizerTab(RingSizeProvider sizer) {
    final ring = RingSizeData.findClosest(_ringDiameter);
    final circlePx = _ringDiameter * sizer.pixelsPerMm;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Calibration status prompt
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => _tabController.animateTo(3),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: sizer.isCalibrated ? AppColors.successLight : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: sizer.isCalibrated
                      ? AppColors.success.withValues(alpha: 0.3)
                      : AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    sizer.isCalibrated ? Icons.verified_rounded : Icons.info_outline_rounded,
                    size: 16,
                    color: sizer.isCalibrated ? AppColors.success : AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      sizer.isCalibrated
                          ? 'Physical 1:1 Scale Active (${sizer.pixelsPerMm.toStringAsFixed(2)} px/mm)'
                          : 'Tip: Tap to calibrate with a credit card for 100% exact scale ↗',
                      style: TextStyle(
                        fontSize: 11,
                        color: sizer.isCalibrated ? AppColors.success : AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          const Text(
            'Place your existing ring on the circle below and move the slider until the circle fits the inside edge of your ring.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textGrey, height: 1.4),
          ),
          const SizedBox(height: 16),

          // Digital Ring Target Box
          Container(
            height: 175,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Container(
                width: circlePx,
                height: circlePx,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryLight,
                  border: Border.all(color: AppColors.primary, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_ringDiameter.toStringAsFixed(1)} mm',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Text(
                        'Size ${ring.indiaSize}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Slider + Steppers Row
          Row(
            children: [
              IconButton(
                style: IconButton.styleFrom(backgroundColor: AppColors.surfaceVariant),
                icon: const Icon(Icons.remove_rounded, size: 18),
                onPressed: () {
                  if (_ringDiameter > 14.1) {
                    setState(() => _ringDiameter = (_ringDiameter - 0.1).clamp(14.0, 22.0));
                  }
                },
              ),
              const Text('14 mm', style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
              Expanded(
                child: Slider(
                  value: _ringDiameter,
                  min: 14.0,
                  max: 22.0,
                  divisions: 80,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.border,
                  onChanged: (v) => setState(() => _ringDiameter = v),
                ),
              ),
              const Text('22 mm', style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
              IconButton(
                style: IconButton.styleFrom(backgroundColor: AppColors.surfaceVariant),
                icon: const Icon(Icons.add_rounded, size: 18),
                onPressed: () {
                  if (_ringDiameter < 21.9) {
                    setState(() => _ringDiameter = (_ringDiameter + 0.1).clamp(14.0, 22.0));
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Size Stats Row
          Row(
            children: [
              _buildSizeStatPill('Indian Size', 'Size ${ring.indiaSize}', isHighlighted: true),
              const SizedBox(width: 8),
              _buildSizeStatPill('US Size', ring.usSize),
              const SizedBox(width: 8),
              _buildSizeStatPill('UK Size', ring.ukSize),
              const SizedBox(width: 8),
              _buildSizeStatPill('Circumf.', '${ring.circumferenceMm} mm'),
            ],
          ),
          const SizedBox(height: 16),

          // Action: Save to Profile
          AppButton(
            title: sizer.savedRingSize == ring.indiaSize
                ? 'Saved as My Ring Size ✓'
                : 'Save Size ${ring.indiaSize} to My Profile',
            icon: Icons.check_circle_outline_rounded,
            onPressed: () async {
              await sizer.saveUserRingSize(ring.indiaSize);
              if (mounted) {
                showAppSnackBar(context, 'Saved Indian Ring Size ${ring.indiaSize} to your profile! 💍');
              }
            },
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 2: Bangles Sizer & Table
  // =========================================================================
  Widget _buildBanglesTab(RingSizeProvider sizer) {
    final bangle = BangleSizeData.findClosest(_bangleDiameter);
    final circlePx = _bangleDiameter * sizer.pixelsPerMm;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.accentTealLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.tips_and_updates_outlined, size: 16, color: AppColors.accentTeal),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Place your existing bangle on the screen or use the chart below to find your fit.',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF0F766E)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Digital Bangle Circle Target
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Container(
                width: circlePx,
                height: circlePx,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withValues(alpha: 0.08),
                  border: Border.all(color: AppColors.accent, width: 2.5),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_bangleDiameter.toStringAsFixed(1)} mm',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textDark),
                      ),
                      Text(
                        'Size ${bangle.notation}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent),
                      ),
                      Text('Fit: ${bangle.fitDescription}', style: const TextStyle(fontSize: 10, color: AppColors.textGrey)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Bangle Slider
          Slider(
            value: _bangleDiameter,
            min: 52.0,
            max: 72.0,
            divisions: 40,
            activeColor: AppColors.accent,
            inactiveColor: AppColors.border,
            onChanged: (v) => setState(() => _bangleDiameter = v),
          ),
          const SizedBox(height: 6),

          AppButton.outlined(
            title: sizer.savedBangleSize == bangle.notation
                ? 'Saved Bangle Size ${bangle.notation} ✓'
                : 'Save Size ${bangle.notation} to Profile',
            icon: Icons.check_circle_outline_rounded,
            onPressed: () async {
              await sizer.saveUserBangleSize(bangle.notation);
              if (mounted) {
                showAppSnackBar(context, 'Saved Bangle Size ${bangle.notation} to profile! ✨');
              }
            },
          ),
          const SizedBox(height: 16),

          const Text(
            'Standard Indian Bangle Sizes',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),

          for (final b in BangleSizeData.all)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Size ${b.notation}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(b.fitDescription, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${b.diameterMm} mm',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(b.inches, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 3: Screen Calibration Tool (Credit Card or Coin)
  // =========================================================================
  Widget _buildCalibrationTab(RingSizeProvider sizer) {
    final standardTargetMm = _calibrationMode == 0
        ? ScreenCalibrationConstants.creditCardWidthMm
        : ScreenCalibrationConstants.coin5RupeeDiameterMm;

    final calculatedPpi = _calibratingWidth / standardTargetMm;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.credit_card_rounded, size: 14),
                      SizedBox(width: 6),
                      Text('Credit / Debit Card'),
                    ],
                  ),
                  selected: _calibrationMode == 0,
                  onSelected: (_) {
                    setState(() {
                      _calibrationMode = 0;
                      _calibratingWidth = (ScreenCalibrationConstants.creditCardWidthMm * sizer.pixelsPerMm).clamp(250.0, 650.0);
                    });
                  },
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _calibrationMode == 0 ? Colors.white : AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.monetization_on_outlined, size: 14),
                      SizedBox(width: 6),
                      Text('₹5 Coin'),
                    ],
                  ),
                  selected: _calibrationMode == 1,
                  onSelected: (_) {
                    setState(() {
                      _calibrationMode = 1;
                      _calibratingWidth = (ScreenCalibrationConstants.coin5RupeeDiameterMm * sizer.pixelsPerMm).clamp(75.0, 250.0);
                    });
                  },
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _calibrationMode == 1 ? Colors.white : AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            _calibrationMode == 0
                ? 'Place any standard credit or debit card against the outline below. Drag the slider until the outline matches the width of your card (85.6 mm).'
                : 'Place an Indian ₹5 coin on the circular outline below. Drag the slider until the circle matches the exact coin diameter (23.0 mm).',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11.5, color: AppColors.textGrey, height: 1.4),
          ),
          const SizedBox(height: 18),

          Builder(
            builder: (context) {
              final double sliderMin = _calibrationMode == 0 ? 250.0 : 75.0;
              final double sliderMax = _calibrationMode == 0 ? 650.0 : 250.0;
              final double safeSliderVal = _calibratingWidth.clamp(sliderMin, sliderMax);

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _calibrationMode == 0
                            ? Container(
                                width: safeSliderVal,
                                height: (safeSliderVal * (53.98 / 85.60)),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.primary, width: 2.0),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Place Card Here\n(Standard 85.6 mm)',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                width: safeSliderVal,
                                height: safeSliderVal,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary.withValues(alpha: 0.08),
                                  border: Border.all(color: AppColors.primary, width: 2.0),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Place ₹5 Coin\n(23.0 mm)',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Slider(
                    value: safeSliderVal,
                    min: sliderMin,
                    max: sliderMax,
                    divisions: 100,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.border,
                    onChanged: (v) => setState(() => _calibratingWidth = v),
                  ),
                ],
              );
            },
          ),

          Center(
            child: Text(
              'Calibrated Scale: ${calculatedPpi.toStringAsFixed(2)} pixels per mm',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),

          AppButton(
            title: 'Lock & Save Screen Calibration ✓',
            icon: Icons.lock_outline_rounded,
            onPressed: () async {
              if (_calibrationMode == 0) {
                await sizer.calibrateWithCreditCard(_calibratingWidth);
              } else {
                await sizer.calibrateWithCoin(_calibratingWidth);
              }
              if (mounted) {
                showAppSnackBar(context, AppStrings.calibratedSuccess);
                _tabController.animateTo(1);
              }
            },
          ),
          const SizedBox(height: 10),

          TextButton(
            onPressed: () async {
              await sizer.resetCalibration();
              setState(() {
                _calibratingWidth = ScreenCalibrationConstants.creditCardWidthMm * sizer.pixelsPerMm;
              });
              if (mounted) {
                showAppSnackBar(context, 'Reset to standard device scale');
              }
            },
            child: const Text('Reset to Factory Default Scale', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeStatPill(String title, String val, {bool isHighlighted = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isHighlighted ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 9.5,
                color: isHighlighted ? Colors.white70 : AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              val,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: isHighlighted ? Colors.white : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

typedef RingSizeGuideDialog = RingSizeGuideSheet;
