import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/utils/formatters.dart';
import 'package:jewel_ora/core/utils/image_url.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/models/metal_rate_model.dart';
import 'package:jewel_ora/models/product_model.dart';
import 'package:jewel_ora/providers/metal_rate_provider.dart';
import 'package:jewel_ora/providers/product_provider.dart';
import 'package:jewel_ora/providers/settings_provider.dart';
import 'package:jewel_ora/providers/shop_filter_provider.dart';
import 'package:jewel_ora/providers/user_nav_provider.dart';
import 'package:jewel_ora/screens/user/product_detail_screen.dart';
import 'package:jewel_ora/services/whatsapp_service.dart';
import 'package:provider/provider.dart';

class GiftFinderSheet extends StatefulWidget {
  const GiftFinderSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const GiftFinderSheet(),
    );
  }

  @override
  State<GiftFinderSheet> createState() => _GiftFinderSheetState();
}

class _GiftFinderSheetState extends State<GiftFinderSheet> {
  int _currentStep = 0; // 0 = Recipient, 1 = Occasion, 2 = Budget, 3 = Results

  // Step 1: Recipients
  static const List<(String, String, String, List<String>)> _recipients = [
    ('For Her (Wife / Partner)', '👩', 'Wife / Girlfriend', ['ring', 'pendant', 'necklace', 'solitaire', 'diamond', 'rose gold']),
    ('For Him (Husband / Partner)', '👨', 'Husband / Boyfriend', ['chain', 'bracelet', 'kada', 'ring', 'men']),
    ('Mother / Elders', '👵', 'Mother', ['bangle', 'gold', 'temple', 'antique', 'necklace', '22k']),
    ('Sister / Daughter', '👧', 'Sister', ['earring', 'stud', 'bracelet', 'silver', 'dainty', 'pendant']),
    ('Best Friend', '👯', 'Best Friend', ['silver', 'pendant', 'earring', 'charm', 'gift']),
    ('Treat Myself', '✨', 'Myself', <String>[]),
  ];

  // Step 2: Occasions
  static const List<(String, String, String, List<String>)> _occasions = [
    ('Birthday Celebration', '🎂', 'Birthday', ['pendant', 'earring', 'ring']),
    ('Anniversary & Love', '💍', 'Anniversary', ['solitaire', 'diamond', 'ring', 'necklace']),
    ('Wedding & Engagement', '💒', 'Wedding', ['bridal', 'necklace', 'choker', 'gold', 'solitaire']),
    ('Festive & Diwali', '🪔', 'Festive', ['gold', 'temple', 'coin', 'bangle', 'traditional']),
    ('Daily Wear Elegance', '💼', 'Everyday Wear', ['lightweight', 'daily', 'chain', 'stud', 'dainty']),
  ];

  // Step 3: Budgets: (label, emoji, min, max, subtitle)
  static const List<(String, String, double?, double?, String)> _budgets = [
    ('Under ₹15,000', '🌸', 0.0, 15000.0, 'Silver & Minimalist Gold'),
    ('₹15,000 – ₹35,000', '💎', 15000.0, 35000.0, 'Dailywear 14K/18K Diamonds'),
    ('₹35,000 – ₹75,000', '👑', 35000.0, 75000.0, 'Solitaires & Fine Gold'),
    ('₹75,000 & Above', '🌟', 75000.0, null, 'Bridal & Heirloom Luxury'),
    ('Any Budget', '🌈', null, null, 'Show All Recommendations'),
  ];

  int _selectedRecipientIdx = 0;
  int _selectedOccasionIdx = 1; // Default to Anniversary
  int _selectedBudgetIdx = 1;   // Default to 15k-35k

  List<ProductModel> _getMatchingProducts(List<ProductModel> all, MetalRateModel rates) {
    final recipient = _recipients[_selectedRecipientIdx];
    final budget = _budgets[_selectedBudgetIdx];
    final occasion = _occasions[_selectedOccasionIdx];

    return GiftFinderHelper.filterAndScore(
      products: all,
      rates: rates,
      recipientKeywords: recipient.$4,
      occasionKeywords: occasion.$4,
      minPrice: budget.$3,
      maxPrice: budget.$4,
      limit: 8,
    );
  }

  void _applyFiltersAndGoToShop() {
    final budget = _budgets[_selectedBudgetIdx];
    final shopFilter = context.read<ShopFilterProvider>();
    shopFilter.clearFilters();
    shopFilter.setPriceRange(budget.$3, budget.$4);

    context.read<UserNavProvider>().setIndex(UserNavProvider.shopTab);
    Navigator.of(context).pop();
  }

  Future<void> _chatStylistOnWhatsApp() async {
    final settings = context.read<SettingsProvider>().settings;
    final recipient = _recipients[_selectedRecipientIdx];
    final occasion = _occasions[_selectedOccasionIdx];
    final budget = _budgets[_selectedBudgetIdx];

    final message = '''
Hello Jewel Ora Stylist! 🎁

I just used the *Gift Finder Quiz* on your app:
• Gifting to: *${recipient.$3}*
• Occasion: *${occasion.$3}*
• Budget: *${budget.$1}*

Could you share your top curated designs and help me select the perfect piece? ✨
''';

    try {
      await WhatsAppService.open(phone: settings.whatsappNumber, message: message);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) showAppSnackBar(context, '$e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final productP = context.watch<ProductProvider>();
    final ratesP = context.watch<MetalRateProvider>();
    final matches = _getMatchingProducts(productP.products, ratesP.rates);

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

                // Top Progress indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: AppColors.accent,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentStep < 3 ? 'Gift Finder Quiz' : 'Curated Recommendations',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              _currentStep < 3 ? 'Step ${_currentStep + 1} of 3' : 'Handpicked for your occasion',
                              style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textGrey),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Step Progress Bar
                Row(
                  children: List.generate(3, (idx) {
                    final isDone = _currentStep > idx;
                    final isCurrent = _currentStep == idx;
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDone || isCurrent ? AppColors.accent : AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),

                // ---------------- STEP 0: RECIPIENT ----------------
                if (_currentStep == 0) ...[
                  const Text(
                    'Who is this beautiful gift for?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Select the lucky person to see designs tailored to their style.',
                    style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: List.generate(_recipients.length, (idx) {
                      final item = _recipients[idx];
                      final isSel = _selectedRecipientIdx == idx;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setState(() {
                              _selectedRecipientIdx = idx;
                              _currentStep = 1;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSel ? AppColors.accent.withValues(alpha: 0.1) : AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSel ? AppColors.accent : AppColors.border,
                                width: isSel ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(item.$2, style: const TextStyle(fontSize: 22)),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    item.$1,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                                      color: isSel ? AppColors.accent : AppColors.textDark,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: isSel ? AppColors.accent : AppColors.textLight,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],

                // ---------------- STEP 1: OCCASION ----------------
                if (_currentStep == 1) ...[
                  const Text(
                    "What's the special celebration?",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Jewellery carries emotions. Let us align with the moment.',
                    style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: List.generate(_occasions.length, (idx) {
                      final item = _occasions[idx];
                      final isSel = _selectedOccasionIdx == idx;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setState(() {
                              _selectedOccasionIdx = idx;
                              _currentStep = 2;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSel ? AppColors.primaryLight : AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSel ? AppColors.primary : AppColors.border,
                                width: isSel ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(item.$2, style: const TextStyle(fontSize: 22)),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    item.$1,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                                      color: isSel ? AppColors.primary : AppColors.textDark,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: isSel ? AppColors.primary : AppColors.textLight,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    icon: const Icon(Icons.arrow_back_rounded, size: 16),
                    label: const Text('Back to Recipient'),
                    onPressed: () => setState(() => _currentStep = 0),
                  ),
                ],

                // ---------------- STEP 2: BUDGET ----------------
                if (_currentStep == 2) ...[
                  const Text(
                    'What is your ideal budget range?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'We offer stunning fine jewellery at every price tier.',
                    style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: List.generate(_budgets.length, (idx) {
                      final item = _budgets[idx];
                      final isSel = _selectedBudgetIdx == idx;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setState(() {
                              _selectedBudgetIdx = idx;
                              _currentStep = 3; // Go to results
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSel ? AppColors.primaryLight : AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSel ? AppColors.primary : AppColors.border,
                                width: isSel ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(item.$2, style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.$1,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                                          color: isSel ? AppColors.primary : AppColors.textDark,
                                        ),
                                      ),
                                      Text(
                                        item.$5,
                                        style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: isSel ? AppColors.primary : AppColors.textLight,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    icon: const Icon(Icons.arrow_back_rounded, size: 16),
                    label: const Text('Back to Occasion'),
                    onPressed: () => setState(() => _currentStep = 1),
                  ),
                ],

                // ---------------- STEP 3: RESULTS VIEW ----------------
                if (_currentStep == 3) ...[
                  // Match Summary Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_recipients[_selectedRecipientIdx].$3} • ${_occasions[_selectedOccasionIdx].$3} • ${_budgets[_selectedBudgetIdx].$1}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => setState(() => _currentStep = 0),
                          child: const Text(
                            'Change',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.accent),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (matches.isEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          const Icon(Icons.search_off_rounded, size: 40, color: AppColors.textLight),
                          const SizedBox(height: 10),
                          const Text(
                            'No exact pieces found in this specific budget.',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Try expanding your budget range or chatting with our live stylist.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Found ${matches.length} Curated Gift Matches ✨',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 12),

                    // Product Cards Grid / List
                    SizedBox(
                      height: 220,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: matches.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 12),
                        itemBuilder: (ctx, i) {
                          final item = matches[i];
                          final price = item.getEffectivePrice(ratesP.rates);

                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailScreen(productId: item.id),
                                ),
                              );
                            },
                            child: Container(
                              width: 140,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: item.firstImage.isNotEmpty
                                          ? Image.network(
                                              ImageUrl.optimized(item.firstImage, width: 250),
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              errorBuilder: (c, e, s) => Container(
                                                color: AppColors.surface,
                                                child: const Icon(Icons.diamond_outlined, color: AppColors.textLight),
                                              ),
                                            )
                                          : Container(
                                              color: AppColors.surface,
                                              child: const Icon(Icons.diamond_outlined, color: AppColors.textLight),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    Formatters.price(price),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  if (item.hasDiscount)
                                    Text(
                                      '${item.discountPercent}% OFF',
                                      style: const TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.w700),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Action Buttons
                  AppButton(
                    title: 'Explore All Gifts in Shop',
                    icon: Icons.storefront_rounded,
                    onPressed: _applyFiltersAndGoToShop,
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: AppButton.outlined(
                          title: 'Ask Showroom Stylist',
                          icon: Icons.chat_rounded,
                          foregroundColor: AppColors.whatsapp,
                          onPressed: _chatStylistOnWhatsApp,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        tooltip: 'Retake Quiz',
                        icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.all(14),
                        ),
                        onPressed: () => setState(() => _currentStep = 0),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GiftFinderHelper {
  static List<ProductModel> filterAndScore({
    required List<ProductModel> products,
    required MetalRateModel rates,
    required List<String> recipientKeywords,
    required List<String> occasionKeywords,
    double? minPrice,
    double? maxPrice,
    int limit = 8,
  }) {
    // Filter available products by budget
    final candidates = products.where((p) {
      if (!p.isAvailable) return false;
      final effPrice = p.getEffectivePrice(rates);
      if (minPrice != null && effPrice < minPrice) return false;
      if (maxPrice != null && effPrice > maxPrice) return false;
      return true;
    }).toList();

    // Score based on recipient & occasion keywords + featured boost
    final scored = candidates.map((p) {
      final text = '${p.name} ${p.categoryName} ${p.material} ${p.description}'.toLowerCase();
      var score = 0;
      for (final kw in recipientKeywords) {
        if (text.contains(kw.toLowerCase())) score += 3;
      }
      for (final kw in occasionKeywords) {
        if (text.contains(kw.toLowerCase())) score += 2;
      }
      if (p.isFeatured) score += 1;
      return (product: p, score: score);
    }).toList();

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.map((e) => e.product).take(limit).toList();
  }
}
