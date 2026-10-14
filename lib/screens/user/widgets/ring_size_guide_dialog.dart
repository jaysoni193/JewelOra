import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';

class RingSizeGuideSheet extends StatefulWidget {
  const RingSizeGuideSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const RingSizeGuideSheet(),
    );
  }

  @override
  State<RingSizeGuideSheet> createState() => _RingSizeGuideSheetState();
}

class _RingSizeGuideSheetState extends State<RingSizeGuideSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;
  double _testDiameter = 17.3; // Default Indian Size 14 (17.3 mm)

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging &&
          _selectedTab != _tabController.index) {
        setState(() => _selectedTab = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  static const _ringData = [
    ('6', '3.5', '14.5 mm', '45.6 mm'),
    ('8', '4.5', '15.3 mm', '48.0 mm'),
    ('10', '5.5', '16.0 mm', '50.3 mm'),
    ('12', '6.0', '16.5 mm', '51.8 mm'),
    ('14', '7.0', '17.3 mm', '54.3 mm'),
    ('16', '7.5', '17.7 mm', '55.6 mm'),
    ('18', '8.5', '18.5 mm', '58.1 mm'),
    ('20', '9.5', '19.2 mm', '60.3 mm'),
    ('22', '10.0', '19.8 mm', '62.2 mm'),
    ('24', '11.0', '20.6 mm', '64.7 mm'),
  ];

  static const _bangleData = [
    ('2.2 (2-2/16)', '2.125 in', '54.0 mm', 'Extra Small'),
    ('2.4 (2-4/16)', '2.250 in', '57.2 mm', 'Small'),
    ('2.6 (2-6/16)', '2.375 in', '60.3 mm', 'Medium / Standard'),
    ('2.8 (2-8/16)', '2.500 in', '63.5 mm', 'Large'),
    ('2.10 (2-10/16)', '2.625 in', '66.7 mm', 'Extra Large'),
  ];

  String _closestSize(double mm) {
    if (mm < 15.0) return 'Size 6';
    if (mm < 15.7) return 'Size 8';
    if (mm < 16.3) return 'Size 10';
    if (mm < 16.9) return 'Size 12';
    if (mm < 17.5) return 'Size 14 (Standard)';
    if (mm < 18.1) return 'Size 16';
    if (mm < 18.9) return 'Size 18';
    if (mm < 19.5) return 'Size 20';
    if (mm < 20.2) return 'Size 22';
    return 'Size 24+';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
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
                      child: const Icon(Icons.straighten_rounded,
                          color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.ringSizeGuide,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            AppStrings.ringSizeGuideSubtitle,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textGrey),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.textGrey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Tab Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TabBar(
                  controller: _tabController,
                  onTap: (index) => setState(() => _selectedTab = index),
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 2.5,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textGrey,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13),
                  tabs: const [
                    Tab(text: 'Ring Chart'),
                    Tab(text: 'Visual Sizer'),
                    Tab(text: 'Bangles'),
                  ],
                ),
              ),

              // Active Tab Content directly as a shrink-wrapped child
              _buildActiveTabContent(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTabContent() {
    switch (_selectedTab) {
      case 1:
        return _buildVisualSizerTab();
      case 2:
        return _buildBanglesTab();
      case 0:
      default:
        return _buildRingChartTab();
    }
  }

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
                    style: TextStyle(
                        fontSize: 11.5, color: AppColors.primaryDark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Table(
            border: TableBorder.all(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(8)),
            children: [
              const TableRow(
                decoration: BoxDecoration(color: AppColors.surfaceVariant),
                children: [
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                      child: Text('India Size',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 12))),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                      child: Text('US Size',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 12))),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                      child: Text('Diameter',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 12))),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                      child: Text('Circumf.',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 12))),
                ],
              ),
              for (final r in _ringData)
                TableRow(
                  children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        child: Text(r.$1,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 12))),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        child: Text(r.$2,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textGrey))),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        child: Text(r.$3,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textGrey))),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        child: Text(r.$4,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textGrey))),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisualSizerTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Place your existing ring on the circle below and move the slider until the circle fits the inside edge of your ring.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12, color: AppColors.textGrey, height: 1.4),
          ),
          const SizedBox(height: 18),
          Center(
            child: Container(
              width: _testDiameter * 6.5,
              height: _testDiameter * 6.5,
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
                      '${_testDiameter.toStringAsFixed(1)} mm',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    Text(
                      _closestSize(_testDiameter),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentCoral,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Text('14 mm',
                  style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
              Expanded(
                child: Slider(
                  value: _testDiameter,
                  min: 14.0,
                  max: 22.0,
                  divisions: 80,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.border,
                  onChanged: (v) => setState(() => _testDiameter = v),
                ),
              ),
              const Text('22 mm',
                  style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBanglesTab() {
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
                Icon(Icons.tips_and_updates_outlined,
                    size: 16, color: AppColors.accentTeal),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Measure the inner diameter of a bangle that fits you well.',
                    style:
                        TextStyle(fontSize: 11.5, color: Color(0xFF0F766E)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final b in _bangleData)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                        'Size ${b.$1}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppColors.textDark),
                      ),
                      Text(b.$4,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textGrey)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(b.$3,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppColors.primary)),
                      Text(b.$2,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textGrey)),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

typedef RingSizeGuideDialog = RingSizeGuideSheet;
