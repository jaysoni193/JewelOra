import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_icon_options.dart';
import 'package:jewel_ora/providers/settings_provider.dart';
import 'package:provider/provider.dart';

/// The shop logo shown across the app (login, home, admin...).
///
/// By default, it dynamically reflects the active app icon chosen by the Admin in App Branding.
/// Pass [iconKey] to override or preview a specific festival launcher icon.
class BrandLogo extends StatelessWidget {
  final double size;
  final String? iconKey;
  final bool showShadow;

  const BrandLogo({
    super.key,
    this.size = 44,
    this.iconKey,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    String currentKey = iconKey ?? '';
    if (currentKey.isEmpty) {
      try {
        final settings = context.watch<SettingsProvider>().settings;
        currentKey = settings.appIcon;
      } catch (_) {
        currentKey = 'default';
      }
    }

    final assetPath = AppIconOptions.byKey(currentKey).asset;
    final radius = BorderRadius.circular(size * 0.24);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(assetPath),
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: showShadow
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    blurRadius: size * 0.22,
                    offset: Offset(0, size * 0.06),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Image.asset(
            assetPath,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, error, stack) => Container(
              color: AppColors.primaryLight,
              child: Icon(
                Icons.diamond_outlined,
                size: size * 0.5,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
