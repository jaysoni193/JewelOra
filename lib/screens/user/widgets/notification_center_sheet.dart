import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/widgets/app_bottom_sheet.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/app_loader.dart';
import 'package:jewel_ora/core/widgets/empty_state.dart';
import 'package:jewel_ora/models/app_notification_model.dart';
import 'package:jewel_ora/services/notification_service.dart';

class NotificationCenterSheet extends StatefulWidget {
  const NotificationCenterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show(
      context,
      child: const NotificationCenterSheet(),
    );
  }

  @override
  State<NotificationCenterSheet> createState() => _NotificationCenterSheetState();
}

class _NotificationCenterSheetState extends State<NotificationCenterSheet> {
  String _selectedFilter = 'all'; // 'all', 'rate_drop', 'new_product', 'offer'

  @override
  Widget build(BuildContext context) {
    return CommonBottomSheetContainer(
      title: AppStrings.notificationCenter,
      subtitle: 'Live alerts, rate drops & collection launches',
      icon: Icons.notifications_active_rounded,
      trailing: IconButton(
        icon: const Icon(Icons.tune_rounded, color: AppColors.primary),
        tooltip: AppStrings.notificationSettings,
        onPressed: () => _openNotificationSettings(context),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'All Alerts', Icons.all_inbox_rounded),
                const SizedBox(width: 8),
                _buildFilterChip('rate_drop', 'Price Drops', Icons.trending_down_rounded),
                const SizedBox(width: 8),
                _buildFilterChip('new_product', 'New Arrivals', Icons.auto_awesome_rounded),
                const SizedBox(width: 8),
                _buildFilterChip('offer', 'Festive Deals', Icons.card_giftcard_rounded),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Notifications Stream
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.52,
            ),
            child: StreamBuilder<List<AppNotificationModel>>(
              stream: NotificationService.instance.watchNotifications(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: AppLoader(size: 38)),
                  );
                }

                final allList = snapshot.data ?? [];
                final filtered = _selectedFilter == 'all'
                    ? allList
                    : allList.where((n) => n.type == _selectedFilter).toList();

                if (filtered.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    child: EmptyState(
                      icon: Icons.notifications_none_rounded,
                      title: AppStrings.noNotificationsYet,
                      message: 'You\'re up to date! Stay tuned for gold price drops and seasonal collection launches.',
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return _buildNotificationCard(context, item);
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 16),
          // Action Buttons Footer
          Row(
            children: [
              Expanded(
                child: AppButton.outlined(
                  title: AppStrings.markAllAsRead,
                  height: 44,
                  onPressed: () async {
                    await NotificationService.instance.markAllAsRead();
                    if (context.mounted) {
                      showAppSnackBar(context, 'All notifications marked as read');
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  title: AppStrings.notificationSettings,
                  height: 44,
                  onPressed: () => _openNotificationSettings(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label, IconData icon) {
    final isSelected = _selectedFilter == key;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = key),
      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : AppColors.textMedium,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, AppNotificationModel item) {
    IconData icon;
    Color iconColor;
    Color iconBg;

    switch (item.type) {
      case 'rate_drop':
        icon = Icons.trending_down_rounded;
        iconColor = Colors.green.shade700;
        iconBg = Colors.green.shade50;
        break;
      case 'new_product':
        icon = Icons.diamond_outlined;
        iconColor = AppColors.primary;
        iconBg = AppColors.primary.withValues(alpha: 0.1);
        break;
      case 'offer':
        icon = Icons.card_giftcard_rounded;
        iconColor = AppColors.accentGold;
        iconBg = AppColors.accentGold.withValues(alpha: 0.15);
        break;
      default:
        icon = Icons.campaign_rounded;
        iconColor = AppColors.primary;
        iconBg = AppColors.primary.withValues(alpha: 0.1);
    }

    final diff = DateTime.now().difference(item.timestamp);
    String timeStr;
    if (diff.inMinutes < 60) {
      timeStr = '${diff.inMinutes.clamp(1, 60)}m ago';
    } else if (diff.inHours < 24) {
      timeStr = '${diff.inHours}h ago';
    } else {
      timeStr = '${diff.inDays}d ago';
    }

    return InkWell(
      onTap: () {
        NotificationService.instance.markAsRead(item.id);
      },
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: item.isRead ? AppColors.cardBg : AppColors.primary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(
            color: item.isRead ? AppColors.border : AppColors.primary.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        timeStr,
                        style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: TextStyle(
                      fontSize: 12,
                      color: item.isRead ? AppColors.textMedium : AppColors.textDark,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (!item.isRead) ...[
              const SizedBox(width: 6),
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openNotificationSettings(BuildContext context) {
    AppBottomSheet.show(
      context,
      child: const _NotificationPreferencesSheet(),
    );
  }
}

class _NotificationPreferencesSheet extends StatefulWidget {
  const _NotificationPreferencesSheet();

  @override
  State<_NotificationPreferencesSheet> createState() => _NotificationPreferencesSheetState();
}

class _NotificationPreferencesSheetState extends State<_NotificationPreferencesSheet> {
  bool _goldDrops = true;
  bool _newCollections = true;
  bool _festiveOffers = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await NotificationService.instance.getNotificationPreferences();
    if (mounted) {
      setState(() {
        _goldDrops = prefs[NotificationService.topicGoldDrop] ?? true;
        _newCollections = prefs[NotificationService.topicNewCollection] ?? true;
        _festiveOffers = prefs[NotificationService.topicFestiveOffers] ?? true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonBottomSheetContainer(
      title: AppStrings.notificationSettings,
      icon: Icons.settings_suggest_rounded,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isLoading)
            const SizedBox(height: 150, child: Center(child: AppLoader(size: 36)))
          else ...[
            _buildSwitchTile(
              title: AppStrings.goldDropAlerts,
              subtitle: AppStrings.goldDropAlertsDesc,
              icon: Icons.trending_down_rounded,
              value: _goldDrops,
              onChanged: (val) async {
                setState(() => _goldDrops = val);
                await NotificationService.instance.setTopicPreference(NotificationService.topicGoldDrop, val);
              },
            ),
            const Divider(height: 20),
            _buildSwitchTile(
              title: AppStrings.newCollectionAlerts,
              subtitle: AppStrings.newCollectionAlertsDesc,
              icon: Icons.diamond_outlined,
              value: _newCollections,
              onChanged: (val) async {
                setState(() => _newCollections = val);
                await NotificationService.instance.setTopicPreference(NotificationService.topicNewCollection, val);
              },
            ),
            const Divider(height: 20),
            _buildSwitchTile(
              title: AppStrings.festiveOffersAlerts,
              subtitle: AppStrings.festiveOffersAlertsDesc,
              icon: Icons.card_giftcard_rounded,
              value: _festiveOffers,
              onChanged: (val) async {
                setState(() => _festiveOffers = val);
                await NotificationService.instance.setTopicPreference(NotificationService.topicFestiveOffers, val);
              },
            ),
          ],
          const SizedBox(height: 20),
          AppButton(
            title: AppStrings.ok,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.textLight, height: 1.3),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
