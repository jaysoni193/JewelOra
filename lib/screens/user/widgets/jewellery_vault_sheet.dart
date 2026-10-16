import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/utils/formatters.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/empty_state.dart';
import 'package:jewel_ora/models/metal_rate_model.dart';
import 'package:jewel_ora/models/vault_item_model.dart';
import 'package:jewel_ora/providers/jewellery_vault_provider.dart';
import 'package:jewel_ora/providers/metal_rate_provider.dart';
import 'package:jewel_ora/providers/settings_provider.dart';
import 'package:jewel_ora/services/certificate_verifier.dart';
import 'package:provider/provider.dart';

class JewelleryVaultSheet extends StatefulWidget {
  final String? initialCertNumber;
  final int initialTab;

  const JewelleryVaultSheet({
    super.key,
    this.initialCertNumber,
    this.initialTab = 0,
  });

  static Future<void> show(
    BuildContext context, {
    String? initialCertNumber,
    int initialTab = 0,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => JewelleryVaultSheet(
        initialCertNumber: initialCertNumber,
        initialTab: initialTab,
      ),
    );
  }

  @override
  State<JewelleryVaultSheet> createState() => _JewelleryVaultSheetState();
}

class _JewelleryVaultSheetState extends State<JewelleryVaultSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Verifier State
  bool _isHuidMode = true; // true = BIS HUID, false = Diamond Cert
  final _certInputController = TextEditingController();
  VerificationResult? _verificationResult;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );

    if (widget.initialCertNumber != null && widget.initialCertNumber!.isNotEmpty) {
      _certInputController.text = widget.initialCertNumber!;
      _tabController.index = 1;
      _runVerification();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _certInputController.dispose();
    super.dispose();
  }

  void _runVerification() {
    final query = _certInputController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      if (_isHuidMode) {
        _verificationResult = CertificateVerifier.verifyHuid(query);
      } else {
        _verificationResult = CertificateVerifier.verifyDiamondCert(query);
      }
    });
  }

  void _openAddPieceDialog(BuildContext context, [VerificationResult? prefillCert]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddVaultItemSheet(prefillCert: prefillCert),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rates = context.watch<MetalRateProvider>().rates;
    final vault = context.watch<JewelleryVaultProvider>();
    final settings = context.watch<SettingsProvider>().settings;

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
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
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
                          AppStrings.jewelleryVault,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          AppStrings.jewelleryVaultSubtitle,
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined, size: 16),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          AppStrings.myVault,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (vault.items.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${vault.items.length}',
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_outlined, size: 16),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          AppStrings.verifyHallmark,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
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
                  // Tab 1: My Vault Portfolio
                  _buildVaultTab(context, vault, rates, settings.whatsappNumber),

                  // Tab 2: Certificate & Hallmark Verifier
                  _buildVerifierTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // Tab 1: Vault Portfolio
  // ----------------------------------------------------
  Widget _buildVaultTab(
    BuildContext context,
    JewelleryVaultProvider vault,
    MetalRateModel rates,
    String storePhone,
  ) {
    if (vault.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              EmptyState(
                title: AppStrings.vaultEmpty,
                subtitle: AppStrings.vaultEmptySubtitle,
                icon: Icons.shield_outlined,
              ),
              const SizedBox(height: 16),
              AppButton(
                title: 'Add First Piece ➕',
                onPressed: () => _openAddPieceDialog(context),
              ),
            ],
          ),
        ),
      );
    }

    final totalValuation = vault.getTotalValuation(rates);
    final totalGold = vault.getTotalNetGoldWeight();
    final totalGain = vault.getTotalGain(rates);
    final totalGainPct = vault.getTotalGainPercent(rates);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        // Portfolio Summary Card (Luxury Gold Gradient)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2C241E), Color(0xFF171310)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
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
                    AppStrings.portfolioValue.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Live Rate Priced',
                      style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                Formatters.currency(totalValuation),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Net Gold', style: TextStyle(color: Colors.white60, fontSize: 11)),
                      const SizedBox(height: 2),
                      Text(
                        '${totalGold.toStringAsFixed(2)} g',
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Value Appreciation', style: TextStyle(color: Colors.white60, fontSize: 11)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            totalGain >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                            size: 16,
                            color: totalGain >= 0 ? AppColors.success : AppColors.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${totalGain >= 0 ? '+' : ''}${Formatters.currency(totalGain)} (${totalGainPct >= 0 ? '+' : ''}${totalGainPct.toStringAsFixed(1)}%)',
                            style: TextStyle(
                              color: totalGain >= 0 ? const Color(0xFF66BB6A) : const Color(0xFFEF5350),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Action Buttons Row: Add Piece & Share
        Row(
          children: [
            Expanded(
              child: AppButton(
                title: AppStrings.addToVault,
                icon: Icons.add_circle_outline_rounded,
                onPressed: () => _openAddPieceDialog(context),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              tooltip: 'Share Portfolio on WhatsApp',
              icon: const Icon(Icons.share_rounded, color: AppColors.primary),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(14),
              ),
              onPressed: () => vault.sharePortfolioWhatsApp(rates: rates, storePhone: storePhone),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Items List
        const Text(
          'Your Registered Vault Items',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),

        ...vault.items.map((item) {
          final currentVal = item.getCurrentValuation(rates);
          final gain = item.getGain(rates);
          final gainPct = item.getGainPercent(rates);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(Icons.diamond_outlined, color: AppColors.primary, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.metalLabel,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${item.netWeight.toStringAsFixed(2)} g net',
                                style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.textGrey),
                      onPressed: () {
                        vault.removeItem(item.id);
                        showAppSnackBar(context, 'Piece removed from vault');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Current Valuation', style: TextStyle(fontSize: 10, color: AppColors.textGrey)),
                        Text(
                          Formatters.currency(currentVal),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Purchase Price', style: TextStyle(fontSize: 10, color: AppColors.textGrey)),
                        Text(
                          Formatters.currency(item.purchasePrice),
                          style: const TextStyle(fontSize: 12, color: AppColors.textDark),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Gain / Growth', style: TextStyle(fontSize: 10, color: AppColors.textGrey)),
                        Text(
                          '${gain >= 0 ? '+' : ''}${Formatters.currency(gain)} (${gainPct >= 0 ? '+' : ''}${gainPct.toStringAsFixed(1)}%)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: gain >= 0 ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (item.huidOrCert != null && item.huidOrCert!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      _certInputController.text = item.huidOrCert!;
                      _tabController.animateTo(1);
                      _runVerification();
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_rounded, size: 12, color: AppColors.accent),
                          const SizedBox(width: 4),
                          Text(
                            'Cert/HUID: ${item.huidOrCert} · Tap to Verify',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  // ----------------------------------------------------
  // Tab 2: Certificate & Hallmark Verifier
  // ----------------------------------------------------
  Widget _buildVerifierTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        // Mode Selector: BIS Hallmark vs Diamond Cert
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(
              value: true,
              label: Text('BIS Hallmark (HUID)', style: TextStyle(fontSize: 12)),
              icon: Icon(Icons.verified_outlined, size: 16),
            ),
            ButtonSegment(
              value: false,
              label: Text('Diamond Dossier', style: TextStyle(fontSize: 12)),
              icon: Icon(Icons.diamond_outlined, size: 16),
            ),
          ],
          selected: {_isHuidMode},
          onSelectionChanged: (set) {
            setState(() {
              _isHuidMode = set.first;
              _verificationResult = null;
            });
          },
        ),

        const SizedBox(height: 16),

        // Input Field
        Text(
          _isHuidMode ? 'Enter 6-Character BIS Hallmark HUID' : 'Enter Diamond Certificate Number',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _certInputController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: _isHuidMode ? 'e.g. HA8492' : 'e.g. IGI-LG592810',
                  prefixIcon: Icon(
                    _isHuidMode ? Icons.qr_code_rounded : Icons.card_membership_rounded,
                    color: AppColors.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                onSubmitted: (_) => _runVerification(),
              ),
            ),
            const SizedBox(width: 8),
            AppButton(
              title: 'Verify 🔍',
              onPressed: _runVerification,
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Sample Quick Fill Chips
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            const Text('Sample numbers:', style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
            _buildSampleChip('HA8492', '22K HUID', true),
            _buildSampleChip('H7K92P', '18K HUID', true),
            _buildSampleChip('IGI-LG592810', 'IGI Diamond', false),
            _buildSampleChip('GIA-22194820', 'GIA Solitaire', false),
          ],
        ),

        const SizedBox(height: 20),

        // Verification Card
        if (_verificationResult != null) _buildResultCard(context, _verificationResult!),
      ],
    );
  }

  Widget _buildSampleChip(String code, String label, bool isHuid) {
    return ActionChip(
      label: Text('$label ($code)'),
      labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary),
      backgroundColor: AppColors.primaryLight,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      side: BorderSide.none,
      onPressed: () {
        setState(() {
          _isHuidMode = isHuid;
          _certInputController.text = code;
          _runVerification();
        });
      },
    );
  }

  Widget _buildResultCard(BuildContext context, VerificationResult res) {
    if (!res.isValid) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    res.title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.error),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    res.errorMessage ?? 'Verification failed',
                    style: const TextStyle(fontSize: 12, color: AppColors.textDark),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.accent, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seal Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_rounded, color: AppColors.accent, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      res.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      AppStrings.certVerified,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Details List
          ...res.details.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      entry.key,
                      style: const TextStyle(fontSize: 12, color: AppColors.textGrey, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Text(
                      entry.value,
                      style: const TextStyle(fontSize: 12, color: AppColors.textDark, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Add to Vault CTA
          AppButton.outlined(
            title: 'Save to My Jewellery Vault 📥',
            icon: Icons.shield_outlined,
            onPressed: () => _openAddPieceDialog(context, res),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// Sub-Sheet: Add Piece to Vault
// ----------------------------------------------------
class _AddVaultItemSheet extends StatefulWidget {
  final VerificationResult? prefillCert;

  const _AddVaultItemSheet({this.prefillCert});

  @override
  State<_AddVaultItemSheet> createState() => _AddVaultItemSheetState();
}

class _AddVaultItemSheetState extends State<_AddVaultItemSheet> {
  final _nameController = TextEditingController();
  final _grossWeightController = TextEditingController();
  final _stoneWeightController = TextEditingController(text: '0.0');
  final _purchasePriceController = TextEditingController();
  final _certController = TextEditingController();
  String _metalType = 'gold_22k';
  String _category = 'Necklace';

  static const _categories = ['Necklace', 'Ring', 'Bangles', 'Earrings', 'Chain', 'Coin', 'Bracelet', 'Other'];
  static const _metals = [
    ('gold_24k', '24K Pure Gold'),
    ('gold_22k', '22K Hallmark Gold'),
    ('gold_18k', '18K Diamond Gold'),
    ('gold_14k', '14K Fine Gold'),
    ('silver', '925 Fine Silver'),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.prefillCert != null) {
      _certController.text = widget.prefillCert!.code;
      if (widget.prefillCert!.purity.contains('18K')) {
        _metalType = 'gold_18k';
      } else if (widget.prefillCert!.purity.contains('24K')) {
        _metalType = 'gold_24k';
      } else {
        _metalType = 'gold_22k';
      }
      _nameController.text = widget.prefillCert!.certType == 'DIAMOND_CERT'
          ? 'Certified Diamond Piece'
          : 'BIS Hallmarked Gold Piece';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _grossWeightController.dispose();
    _stoneWeightController.dispose();
    _purchasePriceController.dispose();
    _certController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final gross = double.tryParse(_grossWeightController.text.trim()) ?? 0.0;
    final stone = double.tryParse(_stoneWeightController.text.trim()) ?? 0.0;
    final price = double.tryParse(_purchasePriceController.text.trim()) ?? 0.0;
    final cert = _certController.text.trim();

    if (name.isEmpty) {
      showAppSnackBar(context, 'Please enter a piece name', isError: true);
      return;
    }
    if (gross <= 0) {
      showAppSnackBar(context, 'Please enter gross weight', isError: true);
      return;
    }

    final item = VaultItemModel(
      id: 'vault_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      category: _category,
      metalType: _metalType,
      grossWeight: gross,
      stoneWeight: stone,
      purchasePrice: price,
      purchaseDate: DateTime.now(),
      huidOrCert: cert.isNotEmpty ? cert : null,
    );

    await context.read<JewelleryVaultProvider>().addItem(item);

    if (mounted) {
      showAppSnackBar(context, 'Added to your Jewellery Vault!');
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.shield_outlined, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Add Piece to Jewellery Vault',
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

            // Item Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Piece Name (e.g. 22K Royal Gold Choker)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Category & Metal
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _category = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _metalType,
                    decoration: const InputDecoration(labelText: 'Metal Purity', border: OutlineInputBorder()),
                    items: _metals.map((m) => DropdownMenuItem(value: m.$1, child: Text(m.$2, style: const TextStyle(fontSize: 12)))).toList(),
                    onChanged: (v) => setState(() => _metalType = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Weights: Gross & Stone
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _grossWeightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}'))],
                    decoration: const InputDecoration(
                      labelText: 'Gross Wt (grams)',
                      suffixText: 'g',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _stoneWeightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}'))],
                    decoration: const InputDecoration(
                      labelText: 'Stone Wt (grams)',
                      suffixText: 'g',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Purchase Price & HUID/Cert
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _purchasePriceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Purchase Price (₹)',
                      prefixText: '₹ ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _certController,
                    decoration: const InputDecoration(
                      labelText: 'HUID / Cert No.',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            AppButton(
              title: 'Save to Vault 🛡️',
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
