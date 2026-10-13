import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_icon_options.dart';
import 'package:jewel_ora/providers/settings_provider.dart';
import 'package:provider/provider.dart';

/// The shop logo shown everywhere in the app (login, home, admin...).
///
/// It is the SAME picture as the icon the admin selected, so choosing a
/// festival icon in the Admin panel changes the logo on every screen at once.
/// Pass [iconKey] only to preview a choice that is not saved yet.
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
    final saved = context.select<SettingsProvider, String>(
      (s) => s.settings.appIcon,
    );
    final option = AppIconOptions.byKey(iconKey ?? saved);
    final radius = BorderRadius.circular(size * 0.24);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(option.key),
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
            option.asset,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, error, stack) => Container(
              color: AppColors.primaryLight,
              child: Icon(Icons.diamond_outlined,
                  size: size * 0.5, color: AppColors.primary),
            ),
          ),
        ),
      ),
    );
  }
}
