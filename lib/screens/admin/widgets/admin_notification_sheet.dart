import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/widgets/app_bottom_sheet.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/app_dropdown.dart';
import 'package:jewel_ora/core/widgets/app_text_field.dart';
import 'package:jewel_ora/services/notification_service.dart';

class AdminNotificationSheet extends StatefulWidget {
  const AdminNotificationSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show(
      context,
      child: const AdminNotificationSheet(),
    );
  }

  @override
  State<AdminNotificationSheet> createState() => _AdminNotificationSheetState();
}

class _AdminNotificationSheetState extends State<AdminNotificationSheet> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _serverKeyCtrl = TextEditingController();

  String _selectedTopic = NotificationService.topicGeneral;
  bool _isSending = false;
  bool _showKeySettings = false;

  @override
  void initState() {
    super.initState();
    _loadFcmConfig();
    _applyPreset('gold_drop');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _serverKeyCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFcmConfig() async {
    final cfg = await NotificationService.instance.getFcmConfig();
    if (mounted) {
      _serverKeyCtrl.text = cfg['serverKey'] as String? ?? '';
    }
  }

  void _applyPreset(String key) {
    setState(() {
      switch (key) {
        case 'gold_drop':
          _selectedTopic = NotificationService.topicGoldDrop;
          _titleCtrl.text = '⚡ Gold Rate Dropped! Special Buying Window';
          _bodyCtrl.text =
              'Today\'s 22K gold rate dropped by ₹45/g. Book your festive jewellery pieces now before rates surge!';
          break;
        case 'new_collection':
          _selectedTopic = NotificationService.topicNewCollection;
          _titleCtrl.text = '✨ New Arrival: Royal Kundan & Solitaire Line';
          _bodyCtrl.text =
              'Explore our exquisite new bridal necklace sets and solitaires, handcrafted with 100% BIS hallmark authenticity.';
          break;
        case 'festive_offer':
          _selectedTopic = NotificationService.topicFestiveOffers;
          _titleCtrl.text = '🎁 Festive Mahotsav: 0% Making Charges';
          _bodyCtrl.text =
              'Celebrate this season with zero making charges on all 24K gold coins and up to 25% off diamond jewellery!';
          break;
      }
    });
  }

  Future<void> _sendNotification() async {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();

    if (title.isEmpty || body.isEmpty) {
      showAppSnackBar(context, 'Please enter both title and message', isError: true);
      return;
    }

    setState(() => _isSending = true);

    final success = await NotificationService.instance.broadcastNotification(
      title: title,
      body: body,
      topic: _selectedTopic,
      type: _selectedTopic == NotificationService.topicGoldDrop
          ? 'rate_drop'
          : _selectedTopic == NotificationService.topicNewCollection
              ? 'new_product'
              : _selectedTopic == NotificationService.topicFestiveOffers
                  ? 'offer'
                  : 'announcement',
    );

    if (!mounted) return;
    setState(() => _isSending = false);

    if (success) {
      Navigator.pop(context);
      showAppSnackBar(context, AppStrings.pushNotificationSent);
    } else {
      showAppSnackBar(context, AppStrings.somethingWentWrong, isError: true);
    }
  }

  Future<void> _saveServerKey() async {
    await NotificationService.instance.saveFcmConfig(
      serverKey: _serverKeyCtrl.text.trim(),
    );
    if (!mounted) return;
    showAppSnackBar(context, 'FCM Server Key saved successfully');
    setState(() => _showKeySettings = false);
  }

  @override
  Widget build(BuildContext context) {
    return CommonBottomSheetContainer(
      title: AppStrings.broadcastPushNotification,
      subtitle: 'Broadcast live alerts to all customer devices',
      icon: Icons.campaign_rounded,
      trailing: IconButton(
        icon: Icon(
          _showKeySettings ? Icons.close_fullscreen_rounded : Icons.vpn_key_outlined,
          color: AppColors.primary,
        ),
        tooltip: AppStrings.fcmServerKey,
        onPressed: () => setState(() => _showKeySettings = !_showKeySettings),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // Server key settings panel (collapsible)
          if (_showKeySettings) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.key_rounded, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.fcmServerKey,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.fcmServerKeyDesc,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMedium),
                  ),
                  const SizedBox(height: 10),
                  AppTextField(
                    controller: _serverKeyCtrl,
                    label: AppStrings.fcmServerKey,
                    hintText: 'Paste Firebase Cloud Messaging Server Key...',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AppButton(
                      title: 'Save Key',
                      height: 36,
                      onPressed: _saveServerKey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Quick Presets
          Text(
            AppStrings.presets,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPresetChip('gold_drop', '⚡ Gold Rate Drop', Icons.trending_down_rounded),
                const SizedBox(width: 8),
                _buildPresetChip('new_collection', '✨ New Collection', Icons.diamond_outlined),
                const SizedBox(width: 8),
                _buildPresetChip('festive_offer', '🎁 Festive Deal', Icons.card_giftcard_rounded),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Topic / Audience Selector
          AppDropdown<String>(
            label: AppStrings.targetAudience,
            value: _selectedTopic,
            items: const [
              DropdownMenuItem(
                value: NotificationService.topicGeneral,
                child: Text('All Customers (General Broadcast)'),
              ),
              DropdownMenuItem(
                value: NotificationService.topicGoldDrop,
                child: Text('Gold & Silver Rate Drop Subscribers'),
              ),
              DropdownMenuItem(
                value: NotificationService.topicNewCollection,
                child: Text('New Collection Launch Subscribers'),
              ),
              DropdownMenuItem(
                value: NotificationService.topicFestiveOffers,
                child: Text('Festive & Seasonal Deals Subscribers'),
              ),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _selectedTopic = val);
            },
          ),
          const SizedBox(height: 12),

          // Title
          AppTextField(
            controller: _titleCtrl,
            label: AppStrings.notificationTitle,
            hintText: 'E.g. ✨ New Collection Launched...',
          ),
          const SizedBox(height: 12),

          // Body
          AppTextField(
            controller: _bodyCtrl,
            label: AppStrings.notificationMessage,
            hintText: 'Enter notification message details...',
            maxLines: 3,
          ),
          const SizedBox(height: 18),

          // Send Action
          AppButton(
            title: AppStrings.sendPushNotification,
            isLoading: _isSending,
            onPressed: _sendNotification,
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String key, String label, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 15, color: AppColors.primary),
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      backgroundColor: AppColors.primary.withValues(alpha: 0.08),
      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
      onPressed: () => _applyPreset(key),
    );
  }
}
