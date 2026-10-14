import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/errors/app_exception.dart';
import 'package:jewel_ora/core/storage/local_storage.dart';
import 'package:jewel_ora/core/utils/formatters.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/app_card.dart';
import 'package:jewel_ora/core/widgets/app_loader.dart';
import 'package:jewel_ora/core/widgets/empty_state.dart';
import 'package:jewel_ora/core/widgets/favorite_button.dart';
import 'package:jewel_ora/core/widgets/view_tracker.dart';
import 'package:jewel_ora/models/enquiry_model.dart';
import 'package:jewel_ora/models/product_model.dart';
import 'package:jewel_ora/providers/auth_provider.dart';
import 'package:jewel_ora/providers/cart_provider.dart';
import 'package:jewel_ora/providers/enquiry_provider.dart';
import 'package:jewel_ora/providers/metal_rate_provider.dart';
import 'package:jewel_ora/providers/product_provider.dart';
import 'package:jewel_ora/providers/settings_provider.dart';
import 'package:jewel_ora/screens/user/widgets/jewellery_care_dialog.dart';
import 'package:jewel_ora/screens/user/widgets/product_image_slider.dart';
import 'package:jewel_ora/screens/user/widgets/ring_size_guide_dialog.dart';
import 'package:jewel_ora/services/share_service.dart';
import 'package:jewel_ora/services/stats_service.dart';
import 'package:jewel_ora/services/whatsapp_service.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? _selectedSize;

  @override
  void initState() {
    super.initState();
    // Record recently viewed (0 Firestore read cost)
    LocalStorage.instance.addRecentlyViewed(widget.productId);
  }

  Future<void> _chatOnWhatsApp(
    BuildContext context,
    ProductModel p,
    double effectivePrice,
  ) async {
    final phone = context.read<SettingsProvider>().settings.whatsappNumber;
    final user = context.read<AuthProvider>().user;
    final name = user?.name ?? '';
    StatsService.recordEnquiry(p.id);

    // Record in Enquiry History
    if (user != null) {
      context.read<EnquiryProvider>().recordEnquiry(
        EnquiryModel(
          id: '',
          userId: user.uid,
          userName: user.name,
          userPhone: user.phone,
          userEmail: user.email,
          items: [
            EnquiryItemModel(
              productId: p.id,
              productName: p.name,
              productPrice: effectivePrice,
              productImage: p.firstImage,
              quantity: 1,
              size: _selectedSize,
            ),
          ],
          totalAmount: effectivePrice,
          message: 'Enquired about ${p.name} (${_selectedSize ?? 'Standard'})',
          status: 'submitted',
          createdAt: DateTime.now(),
        ),
      );
    }

    try {
      await WhatsAppService.open(
        phone: phone,
        message: WhatsAppService.buildProductMessage(
          p,
          customerName: name,
          selectedSize: _selectedSize,
        ),
      );
    } on AppException catch (e) {
      if (context.mounted) showAppSnackBar(context, e.message, isError: true);
    }
  }

  Future<void> _share(BuildContext context, ProductModel p) async {
    final settings = context.read<SettingsProvider>().settings;

    try {
      await ShareService.shareProduct(
        p,
        shopName: settings.appName,
        whatsappNumber: settings.whatsappNumber,
      );
    } on AppException catch (e) {
      if (context.mounted) showAppSnackBar(context, e.message, isError: true);
    }
  }

  Future<void> _addToCart(BuildContext context, ProductModel p) async {
    final cart = context.read<CartProvider>();
    final quantity = await cart.add(p.id, size: _selectedSize);
    if (!context.mounted) return;

    if (quantity == null) {
      showAppSnackBar(
        context,
        cart.errorMessage ?? AppStrings.somethingWentWrong,
        isError: true,
      );
    } else {
      showAppSnackBar(
        context,
        quantity == 1
            ? 'Added to your bag'
            : 'Updated quantity to $quantity in your bag',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productP = context.watch<ProductProvider>();
    final ratesP = context.watch<MetalRateProvider>();
    final p = productP.findById(widget.productId);

    if (productP.isLoading && p == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: AppLoader(size: 50)),
      );
    }

    if (p == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(),
        body: const EmptyState(
          title: 'Piece Not Found',
          subtitle: 'This item might have been removed or is no longer available.',
          icon: Icons.diamond_outlined,
        ),
      );
    }

    final effectivePrice = p.getEffectivePrice(ratesP.rates);
    final sizes = p.effectiveSizes;
    _selectedSize ??= sizes.isNotEmpty ? sizes.first : null;

    final specs = <(String, String)>[
      if (p.categoryName.isNotEmpty) ('Category', p.categoryName),
      if (p.material.isNotEmpty) ('Material', p.material),
      if (p.metalType != null && p.metalType!.isNotEmpty)
        ('Purity', p.metalType!.replaceAll('_', ' ').toUpperCase()),
      if (p.weight.isNotEmpty) ('Gross Weight', p.weight),
      if (p.metalWeight != null) ('Net Metal Weight', '${p.metalWeight} g'),
      if (p.makingCharges != null)
        ('Making Charges', Formatters.price(p.makingCharges!)),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          FavoriteButton(productId: p.id),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _share(context, p),
          ),
        ],
      ),
      body: Stack(
        children: [
          ViewTracker(productId: p.id),
          ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              // Product Images
              ProductImageSlider(images: p.images),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (p.isAvailable)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'IN STOCK',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.errorLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'OUT OF STOCK',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      if (p.offerTag != null && p.offerTag!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            p.offerTag!.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      if (p.useDynamicRate)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bolt_rounded, size: 14, color: AppColors.primary),
                              SizedBox(width: 2),
                              Text(
                                'Live Rate Priced',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Product Name
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      letterSpacing: -0.3,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Price & Discount Wrap
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    runSpacing: 6,
                    children: [
                      Text(
                        Formatters.price(effectivePrice),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: -0.4,
                        ),
                      ),
                      if (p.hasDiscount) ...[
                        Text(
                          Formatters.price(p.mrp!),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textLight,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            'Save ${Formatters.price(p.savings)} (${p.discountPercent}% OFF)',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Size Selection Chips
                  if (sizes.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.selectSize,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => RingSizeGuideSheet.show(context),
                          icon: const Icon(Icons.straighten_rounded, size: 15),
                          label: Text(
                            AppStrings.ringSizeGuide,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: sizes.map((size) {
                        final isSel = _selectedSize == size;
                        return ChoiceChip(
                          label: Text(size),
                          selected: isSel,
                          onSelected: (_) => setState(() => _selectedSize = size),
                          selectedColor: AppColors.primaryLight,
                          backgroundColor: AppColors.surface,
                          labelStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            color: isSel ? AppColors.primaryDark : AppColors.textDark,
                          ),
                          side: BorderSide(
                            color: isSel ? AppColors.primary : AppColors.border,
                            width: isSel ? 1.2 : 1.0,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Specifications Card
                  if (specs.isNotEmpty) ...[
                    Text(
                      AppStrings.specifications,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      child: Column(
                        children: [
                          for (var i = 0; i < specs.length; i++) ...[
                            if (i > 0) const Divider(height: 18),
                            _SpecRow(label: specs[i].$1, value: specs[i].$2),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Description
                  if (p.description.isNotEmpty) ...[
                    Text(
                      AppStrings.description,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p.description,
                      style: const TextStyle(
                        height: 1.6,
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Authenticity & Care Tips
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _TrustBadge(icon: Icons.verified_outlined, title: AppStrings.certified100),
                            _TrustBadge(icon: Icons.autorenew_rounded, title: AppStrings.lifetimeExchange),
                            _TrustBadge(icon: Icons.local_shipping_outlined, title: AppStrings.insuredDelivery),
                          ],
                        ),
                        const Divider(height: 20),
                        InkWell(
                          onTap: () => JewelleryCareSheet.show(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  AppStrings.careAndCleaningTips,
                                  style: const TextStyle(
                                    fontSize: 12,
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
                  ),
                ],
              ),
            ),
          ],
        ),
        ],
      ),

      // Pinned Action Buttons
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: AppButton.outlined(
                  title: AppStrings.addToCart,
                  icon: Icons.shopping_bag_outlined,
                  onPressed: p.isAvailable ? () => _addToCart(context, p) : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  title: AppStrings.whatsappEnquiry,
                  icon: Icons.chat_rounded,
                  backgroundColor: AppColors.whatsapp,
                  onPressed: () => _chatOnWhatsApp(context, p, effectivePrice),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;

  const _SpecRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String title;

  const _TrustBadge({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 22, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }
}
